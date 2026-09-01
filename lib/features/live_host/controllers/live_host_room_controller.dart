import 'dart:async';

import 'package:actpod_studio/api/response/story_response/batch_get_user_stories.dart';
import 'package:actpod_studio/features/live_host/models/live_host_enums.dart';
import 'package:actpod_studio/features/live_host/models/live_host_room_state.dart';
import 'package:actpod_studio/features/live_host/models/live_host_settings_state.dart';
import 'package:actpod_studio/features/live_host/services/live_host_ws_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web/web.dart';

class LiveHostRoomController extends Notifier<LiveHostRoomState> {
  StreamSubscription<Map<String, dynamic>>? _messageSub;
  StreamSubscription<bool>? _connectionSub;
  StreamSubscription<BeforeUnloadEvent>? _beforeUnloadSub;
  Timer? _openRoomTimer;
  bool _closeRoomSent = false;

  LiveHostWsService get _wsService => ref.read(liveHostWsServiceProvider);

  @override
  LiveHostRoomState build() {
    final service = ref.watch(liveHostWsServiceProvider);
    _messageSub = service.messages.listen(_handleWsMessage);
    _connectionSub = service.connectionState.listen((connected) {
      if (!connected && state.status == LiveHostStatus.connecting) {
        state = state.copyWith(
          status: LiveHostStatus.error,
          error: '直播伺服器連線中斷，請稍後再試。',
        );
      }
    });
    _beforeUnloadSub = EventStreamProviders.beforeUnloadEvent
        .forTarget(window)
        .listen((_) => _sendCloseRoomIfLive());
    ref.onDispose(() {
      _sendCloseRoomIfLive();
      _openRoomTimer?.cancel();
      unawaited(_messageSub?.cancel());
      unawaited(_connectionSub?.cancel());
      unawaited(_beforeUnloadSub?.cancel());
      unawaited(service.close());
    });
    return const LiveHostRoomState();
  }

  Future<void> openRoom({
    required String userId,
    required StoryItem? selectedStory,
    required LiveHostSettingsState settings,
  }) async {
    if (!settings.canSubmit(selectedStory) || userId.isEmpty) return;
    final story = selectedStory;
    if (story == null) return;

    state = state.copyWith(status: LiveHostStatus.connecting, error: null);
    try {
      await _wsService.close();
      _closeRoomSent = false;
      await _wsService.connect(userId);

      _wsService.sendJson({
        'cmd': 'openRoom',
        'from': userId,
        'content': settings.roomTitle.trim(),
        'storyId': story.storyId,
        'roomId': '',
        'params': [
          settings.roomTypeParam,
          settings.capacity.toString(),
          settings.notifyFans ? 'true' : 'false',
          settings.notyetOwnedStoryPrice.toString(),
          settings.alreadyOwnedStoryPrice.toString(),
        ],
      });
      _openRoomTimer = Timer(const Duration(seconds: 15), () async {
        if (state.status != LiveHostStatus.connecting) return;
        state = state.copyWith(
          status: LiveHostStatus.error,
          error: '直播伺服器沒有回應開房結果，請稍後再試。',
        );
        await _wsService.close();
      });
    } catch (error) {
      state = state.copyWith(
        status: LiveHostStatus.error,
        error: '直播伺服器連線失敗：$error',
      );
      await _wsService.close();
    }
  }

  Future<void> closeRoom() async {
    _openRoomTimer?.cancel();
    _openRoomTimer = null;
    _sendCloseRoomIfLive();
    await _wsService.close();
    state = state.copyWith(status: LiveHostStatus.closed);
  }

  void resetForNewLive() {
    _openRoomTimer?.cancel();
    _openRoomTimer = null;
    _closeRoomSent = false;
    state = const LiveHostRoomState();
  }

  void _handleWsMessage(Map<String, dynamic> message) {
    final cmd = message['cmd']?.toString() ?? '';
    if (cmd == 'roomReady') {
      final roomId = message['roomId']?.toString() ?? '';
      if (roomId.isEmpty) {
        state = state.copyWith(
          status: LiveHostStatus.error,
          error: '直播已回應，但沒有取得 roomId。',
        );
        return;
      }
      _openRoomTimer?.cancel();
      _openRoomTimer = null;
      _closeRoomSent = false;
      state = state.copyWith(
        status: LiveHostStatus.live,
        roomId: roomId,
        error: null,
      );
      return;
    }

    if (cmd == 'error') {
      _openRoomTimer?.cancel();
      _openRoomTimer = null;
      state = state.copyWith(
        status: LiveHostStatus.error,
        error: message['content']?.toString() ?? '直播伺服器發生錯誤。',
      );
    }
  }

  void _sendCloseRoomIfLive() {
    if (_closeRoomSent) return;
    if (state.status != LiveHostStatus.live &&
        state.status != LiveHostStatus.connecting) {
      return;
    }
    _closeRoomSent = true;
    _wsService.sendJson({'cmd': 'closeRoom'});
  }
}

final liveHostRoomControllerProvider =
    NotifierProvider<LiveHostRoomController, LiveHostRoomState>(
      LiveHostRoomController.new,
    );
