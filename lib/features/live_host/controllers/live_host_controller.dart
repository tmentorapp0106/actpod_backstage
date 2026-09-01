import 'dart:async';
import 'dart:convert';

import 'package:actpod_studio/api/response/story_response/batch_get_user_stories.dart';
import 'package:actpod_studio/api/story_system_api.dart';
import 'package:actpod_studio/features/live_host/models/live_host_state.dart';
import 'package:actpod_studio/features/live_host/services/live_host_ws_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:web/web.dart';

class LiveHostController extends Notifier<LiveHostState> {
  LiveHostWsService? _wsService;
  StreamSubscription<Map<String, dynamic>>? _messageSub;
  StreamSubscription<bool>? _connectionSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<BeforeUnloadEvent>? _beforeUnloadSub;
  Timer? _openRoomTimer;
  Timer? _playerSyncTimer;
  Timer? _playerCommandTimer;
  AudioPlayer? _player;
  LiveHostPlayerStatus? _rollbackPlayerStatus;
  Duration? _rollbackPlayerPosition;
  bool _closeRoomSent = false;

  @override
  LiveHostState build() {
    _beforeUnloadSub = EventStreamProviders.beforeUnloadEvent
        .forTarget(window)
        .listen((_) => _sendCloseRoomIfLive());
    ref.onDispose(() {
      _sendCloseRoomIfLive();
      unawaited(_disposeWs());
      unawaited(_disposePlayer());
      unawaited(_beforeUnloadSub?.cancel());
    });
    return const LiveHostState();
  }

  void startLiveFlow() {
    state = state.copyWith(step: LiveHostStep.storySelection);
  }

  Future<void> loadStories(String userId) async {
    if (userId.isEmpty || state.loadingStories) return;

    state = state.copyWith(loadingStories: true, error: null);
    try {
      final response = await StoryApi().getStoriesByUserId(
        userId,
        filterReviewStatus: false,
      );
      final stories = [...?response.storyList]
        ..sort((a, b) => b.releaseTime.compareTo(a.releaseTime));
      final selectedStory = state.selectedStory == null
          ? null
          : _findStory(stories, state.selectedStory!.storyId);

      state = state.copyWith(
        loadingStories: false,
        stories: stories,
        selectedStory: selectedStory,
      );
    } catch (e) {
      state = state.copyWith(loadingStories: false, error: e.toString());
    }
  }

  void updateSearchKeyword(String value) {
    state = state.copyWith(searchKeyword: value);
  }

  void selectStory(StoryItem story) {
    state = state.copyWith(
      selectedStory: story,
      roomTitle: state.roomTitle.trim().isEmpty ? story.storyName : null,
    );
  }

  void goToLiveSettings() {
    if (state.selectedStory == null) return;
    state = state.copyWith(
      step: LiveHostStep.liveSettings,
      roomTitle: state.roomTitle.trim().isEmpty
          ? state.selectedStory!.storyName
          : null,
    );
  }

  void updateRoomTitle(String value) {
    state = state.copyWith(roomTitle: value);
  }

  void updateRoomType(LiveHostRoomType value) {
    state = state.copyWith(
      roomType: value,
      capacity: value == LiveHostRoomType.listenOnly ? 100 : null,
    );
  }

  void updateCapacity(String value) {
    if (value.isEmpty) {
      state = state.copyWith(capacity: 0);
      return;
    }
    final next = int.tryParse(value);
    if (next == null) return;
    state = state.copyWith(capacity: next);
  }

  void updateNotifyFans(bool value) {
    state = state.copyWith(notifyFans: value);
  }

  void updateNotyetOwnedStoryPrice(String value) {
    final next = int.tryParse(value);
    if (next == null) return;
    state = state.copyWith(notyetOwnedStoryPrice: next);
  }

  void updateAlreadyOwnedStoryPrice(String value) {
    final next = int.tryParse(value);
    if (next == null) return;
    state = state.copyWith(alreadyOwnedStoryPrice: next);
  }

  Future<void> openRoom(String userId) async {
    if (!state.canSubmitLiveSettings || userId.isEmpty) return;

    final selectedStory = state.selectedStory;
    if (selectedStory == null) return;

    state = state.copyWith(status: LiveHostStatus.connecting, error: null);
    try {
      await _disposeWs();
      final wsService = LiveHostWsService();
      _wsService = wsService;

      _connectionSub = wsService.connectionState.listen((connected) {
        if (!connected && state.status == LiveHostStatus.connecting) {
          state = state.copyWith(
            status: LiveHostStatus.error,
            error: '直播伺服器連線中斷，請稍後再試。',
          );
        }
      });

      _messageSub = wsService.messages.listen(_handleWsMessage);
      await wsService.connect(userId);

      wsService.sendJson({
        'cmd': 'openRoom',
        'from': userId,
        'content': state.roomTitle.trim(),
        'storyId': selectedStory.storyId,
        'roomId': '',
        'params': [
          state.roomTypeParam,
          state.capacity.toString(),
          state.notifyFans ? 'true' : 'false',
          state.notyetOwnedStoryPrice.toString(),
          state.alreadyOwnedStoryPrice.toString(),
        ],
      });
      _openRoomTimer = Timer(const Duration(seconds: 15), () async {
        if (state.status != LiveHostStatus.connecting) return;
        state = state.copyWith(
          status: LiveHostStatus.error,
          error: '直播伺服器沒有回應開房結果，請稍後再試。',
        );
        await _disposeWs();
      });
    } catch (e) {
      state = state.copyWith(
        status: LiveHostStatus.error,
        error: '直播伺服器連線失敗：$e',
      );
      await _disposeWs();
    }
  }

  Future<void> closeRoom() async {
    _openRoomTimer?.cancel();
    _openRoomTimer = null;
    _sendCloseRoomIfLive();
    await _disposeWs();
    await _disposePlayer();
    state = state.copyWith(status: LiveHostStatus.closed);
  }

  void startNewLiveFlow() {
    state = state.copyWith(
      step: LiveHostStep.storySelection,
      status: LiveHostStatus.idle,
      error: null,
      selectedStory: null,
      roomTitle: '',
      roomType: LiveHostRoomType.listenOnly,
      capacity: 100,
      notifyFans: true,
      notyetOwnedStoryPrice: 0,
      alreadyOwnedStoryPrice: 0,
      roomId: '',
      members: const [],
      chatMessages: const [],
      playerStatus: LiveHostPlayerStatus.paused,
      pendingPlayerAction: LiveHostPlayerPendingAction.none,
      currentPosition: Duration.zero,
      duration: Duration.zero,
      onMicUserIds: const [],
    );
    _closeRoomSent = false;
  }

  void backToLanding() {
    state = state.copyWith(step: LiveHostStep.landing);
  }

  void backToStorySelection() {
    state = state.copyWith(step: LiveHostStep.storySelection);
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
      state = state.copyWith(
        step: LiveHostStep.liveRoom,
        status: LiveHostStatus.live,
        roomId: roomId,
        error: null,
        duration: Duration(milliseconds: state.selectedStory?.storyLength ?? 0),
      );
      _closeRoomSent = false;
      _initPlayer();
      _startPlayerSyncTimer();
      _openRoomTimer?.cancel();
      _openRoomTimer = null;
      return;
    }

    if (cmd == 'accessRoom') {
      _addMemberFromContent(message['content']);
      return;
    }

    if (cmd == 'leaveRoom') {
      _removeMemberFromContent(message['content']);
      return;
    }

    if (cmd == 'sendChat') {
      state = state.copyWith(
        chatMessages: [
          ...state.chatMessages,
          LiveHostChatMessage.fromJson(message),
        ],
      );
      return;
    }

    if (cmd == 'handUp') {
      _setMemberHandsUp(message['from']?.toString() ?? '', true);
      return;
    }

    if (cmd == 'handDown') {
      _setMemberHandsUp(message['from']?.toString() ?? '', false);
      return;
    }

    if (cmd == 'updateMic') {
      _updateOnMicUserIds(message['content']);
      return;
    }

    if (cmd == 'playPodcast') {
      unawaited(_handleRemotePlayPodcast(message));
      return;
    }

    if (cmd == 'pausePodcast') {
      unawaited(_handleRemotePausePodcast());
      return;
    }

    if (cmd == 'seekPosition') {
      unawaited(_handleRemoteSeekPosition(message['content']));
      return;
    }

    if (cmd == 'getRoomPlayer') {
      _sendRoomPlayerState();
      return;
    }

    if (cmd == 'initRoomPlayer') {
      _sendRoomPlayerState(to: message['from']?.toString());
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
    _wsService?.sendJson({'cmd': 'closeRoom'});
  }

  Future<void> _disposeWs() async {
    _openRoomTimer?.cancel();
    _openRoomTimer = null;
    _clearPendingPlayerCommand();
    await _messageSub?.cancel();
    _messageSub = null;
    await _connectionSub?.cancel();
    _connectionSub = null;
    await _wsService?.dispose();
    _wsService = null;
  }

  Future<void> playPodcast() async {
    if (state.status != LiveHostStatus.live) return;
    if (state.pendingPlayerAction != LiveHostPlayerPendingAction.none) return;
    final position = _player?.position ?? state.currentPosition;
    _startPendingPlayerCommand(LiveHostPlayerPendingAction.play);
    _wsService?.sendJson({
      'cmd': 'playPodcast',
      'params': [position.inMilliseconds.toString()],
    });
  }

  Future<void> pausePodcast() async {
    if (state.status != LiveHostStatus.live) return;
    if (state.pendingPlayerAction != LiveHostPlayerPendingAction.none) return;
    _startPendingPlayerCommand(LiveHostPlayerPendingAction.pause);
    _wsService?.sendJson({'cmd': 'pausePodcast'});
  }

  Future<void> seekPodcast(double milliseconds) async {
    if (state.status != LiveHostStatus.live) return;
    if (state.pendingPlayerAction != LiveHostPlayerPendingAction.none) return;
    final position = Duration(milliseconds: milliseconds.round());
    _startPendingPlayerCommand(LiveHostPlayerPendingAction.seek);
    _wsService?.sendJson({
      'cmd': 'seekPosition',
      'content': position.inMilliseconds.toString(),
    });
  }

  Future<void> _handleRemotePlayPodcast(Map<String, dynamic> message) async {
    final position = _positionFromParams(message['params']);
    try {
      await _playLocalPodcast(position ?? state.currentPosition);
      _clearPendingPlayerCommand();
    } catch (error) {
      _failPendingPlayerCommand('播放器操作失敗：$error');
    }
  }

  Future<void> _handleRemotePausePodcast() async {
    try {
      await _pauseLocalPodcast();
      _clearPendingPlayerCommand();
    } catch (error) {
      _failPendingPlayerCommand('播放器操作失敗：$error');
    }
  }

  Future<void> _handleRemoteSeekPosition(dynamic content) async {
    final milliseconds = int.tryParse(content?.toString() ?? '');
    if (milliseconds == null) return;
    try {
      await _seekLocalPodcast(Duration(milliseconds: milliseconds));
      _clearPendingPlayerCommand();
    } catch (error) {
      _failPendingPlayerCommand('播放器操作失敗：$error');
    }
  }

  void _startPendingPlayerCommand(LiveHostPlayerPendingAction action) {
    _rollbackPlayerStatus = state.playerStatus;
    _rollbackPlayerPosition = state.currentPosition;
    state = state.copyWith(pendingPlayerAction: action, error: null);
    _playerCommandTimer?.cancel();
    _playerCommandTimer = Timer(const Duration(seconds: 15), () {
      _failPendingPlayerCommand('播放器指令逾時，請稍後再試。');
    });
  }

  void _failPendingPlayerCommand(String message) {
    _playerCommandTimer?.cancel();
    _playerCommandTimer = null;
    state = state.copyWith(
      playerStatus: _rollbackPlayerStatus ?? state.playerStatus,
      currentPosition: _rollbackPlayerPosition ?? state.currentPosition,
      pendingPlayerAction: LiveHostPlayerPendingAction.none,
      error: message,
    );
    _rollbackPlayerStatus = null;
    _rollbackPlayerPosition = null;
  }

  void _clearPendingPlayerCommand() {
    _playerCommandTimer?.cancel();
    _playerCommandTimer = null;
    _rollbackPlayerStatus = null;
    _rollbackPlayerPosition = null;
    if (state.pendingPlayerAction != LiveHostPlayerPendingAction.none) {
      state = state.copyWith(
        pendingPlayerAction: LiveHostPlayerPendingAction.none,
      );
    }
  }

  Future<void> _playLocalPodcast(Duration position) async {
    if (state.status != LiveHostStatus.live) return;
    await _initPlayer();
    if (_player == null) return;
    await _player!.seek(position);
    unawaited(
      _player!.play().catchError((Object error) {
        state = state.copyWith(
          playerStatus: LiveHostPlayerStatus.paused,
          error: '播放器操作失敗：$error',
        );
      }),
    );
    state = state.copyWith(
      playerStatus: LiveHostPlayerStatus.playing,
      currentPosition: position,
    );
  }

  Future<void> _pauseLocalPodcast() async {
    final position = _player?.position ?? state.currentPosition;
    await _player?.pause();
    state = state.copyWith(
      playerStatus: LiveHostPlayerStatus.paused,
      currentPosition: position,
    );
  }

  Future<void> _seekLocalPodcast(Duration position) async {
    await _initPlayer();
    await _player?.seek(position);
    state = state.copyWith(currentPosition: position);
  }

  Duration? _positionFromParams(dynamic params) {
    if (params is! List || params.isEmpty) return null;
    final milliseconds = int.tryParse(params.first.toString());
    if (milliseconds == null) return null;
    return Duration(milliseconds: milliseconds);
  }

  void _sendRoomPlayerState({String? to}) {
    if (state.status != LiveHostStatus.live) return;
    final position = _player?.position ?? state.currentPosition;
    final status = state.playerStatus == LiveHostPlayerStatus.playing
        ? 'playing'
        : 'paused';
    _wsService?.sendJson({
      'cmd': 'initRoomPlayer',
      if (to != null && to.isNotEmpty) 'to': to,
      'roomId': state.roomId,
      'params': [status, position.inMilliseconds.toString(), ''],
    });
  }

  Future<void> _initPlayer() async {
    if (_player != null) return;
    final story = state.selectedStory;
    if (story == null || story.storyUrl.isEmpty) return;

    final player = AudioPlayer();
    _player = player;
    _positionSub = player.positionStream.listen((position) {
      state = state.copyWith(currentPosition: position);
    });
    _playerStateSub = player.playerStateStream.listen((playerState) {
      if (state.pendingPlayerAction != LiveHostPlayerPendingAction.none) {
        return;
      }
      state = state.copyWith(
        playerStatus: playerState.playing
            ? LiveHostPlayerStatus.playing
            : LiveHostPlayerStatus.paused,
      );
    });

    final duration = await player.setUrl(story.storyUrl);
    state = state.copyWith(
      duration: duration ?? Duration(milliseconds: story.storyLength),
    );
  }

  void _startPlayerSyncTimer() {
    _playerSyncTimer?.cancel();
    _playerSyncTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (state.status != LiveHostStatus.live) return;
      if (state.pendingPlayerAction != LiveHostPlayerPendingAction.none) return;
      final position = _player?.position ?? state.currentPosition;
      final status = state.playerStatus == LiveHostPlayerStatus.playing
          ? 'playing'
          : 'paused';
      _wsService?.sendJson({
        'cmd': 'updateRoomPlayer',
        'params': [status, position.inMilliseconds.toString()],
      });
    });
  }

  Future<void> _disposePlayer() async {
    _playerSyncTimer?.cancel();
    _playerSyncTimer = null;
    _clearPendingPlayerCommand();
    await _positionSub?.cancel();
    _positionSub = null;
    await _playerStateSub?.cancel();
    _playerStateSub = null;
    await _player?.dispose();
    _player = null;
  }

  void _addMemberFromContent(dynamic content) {
    final member = _memberFromContent(content);
    if (member == null || member.userId.isEmpty) return;
    if (state.members.any((item) => item.userId == member.userId)) return;
    state = state.copyWith(members: [...state.members, member]);
  }

  void _removeMemberFromContent(dynamic content) {
    final member = _memberFromContent(content);
    if (member == null || member.userId.isEmpty) return;
    state = state.copyWith(
      members: state.members
          .where((item) => item.userId != member.userId)
          .toList(),
      onMicUserIds: state.onMicUserIds
          .where((userId) => userId != member.userId)
          .toList(),
    );
  }

  LiveHostMember? _memberFromContent(dynamic content) {
    if (content == null) return null;
    try {
      final decoded = content is String ? jsonDecode(content) : content;
      if (decoded is Map<String, dynamic>) {
        return LiveHostMember.fromJson(decoded);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  void _setMemberHandsUp(String userId, bool isHandsUp) {
    if (userId.isEmpty) return;
    state = state.copyWith(
      members: [
        for (final member in state.members)
          if (member.userId == userId)
            member.copyWith(isHandsUp: isHandsUp)
          else
            member,
      ],
    );
  }

  void _updateOnMicUserIds(dynamic content) {
    try {
      final decoded = content is String ? jsonDecode(content) : content;
      if (decoded is List) {
        state = state.copyWith(
          onMicUserIds: decoded.map((item) => item.toString()).toList(),
        );
      }
    } catch (_) {
      return;
    }
  }

  StoryItem? _findStory(List<StoryItem> stories, String storyId) {
    for (final story in stories) {
      if (story.storyId == storyId) return story;
    }
    return null;
  }
}

final liveHostControllerProvider =
    NotifierProvider<LiveHostController, LiveHostState>(LiveHostController.new);
