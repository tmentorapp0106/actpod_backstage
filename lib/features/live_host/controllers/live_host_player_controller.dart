import 'dart:async';

import 'package:actpod_studio/api/response/story_response/batch_get_user_stories.dart';
import 'package:actpod_studio/features/live_host/models/live_host_enums.dart';
import 'package:actpod_studio/features/live_host/models/live_host_player_state.dart';
import 'package:actpod_studio/features/live_host/services/live_host_ws_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

class LiveHostPlayerController extends Notifier<LiveHostPlayerState> {
  StreamSubscription<Map<String, dynamic>>? _messageSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _playerStateSub;
  Timer? _playerSyncTimer;
  Timer? _playerCommandTimer;
  AudioPlayer? _player;
  LiveHostPlayerStatus? _rollbackPlayerStatus;
  Duration? _rollbackPlayerPosition;
  StoryItem? _story;
  String _roomId = '';

  LiveHostWsService get _wsService => ref.read(liveHostWsServiceProvider);

  @override
  LiveHostPlayerState build() {
    final service = ref.watch(liveHostWsServiceProvider);
    _messageSub = service.messages.listen(_handleWsMessage);
    ref.onDispose(() {
      unawaited(_messageSub?.cancel());
      unawaited(disposePlayer());
    });
    return const LiveHostPlayerState();
  }

  Future<void> attachRoom({
    required String roomId,
    required StoryItem? story,
  }) async {
    _roomId = roomId;
    _story = story;
    state = state.copyWith(
      duration: Duration(milliseconds: story?.storyLength ?? 0),
      error: null,
    );
    await _initPlayer();
    _startPlayerSyncTimer();
  }

  Future<void> playPodcast() async {
    if (state.pendingAction != LiveHostPlayerPendingAction.none) return;
    final position = _player?.position ?? state.currentPosition;
    _startPendingPlayerCommand(LiveHostPlayerPendingAction.play);
    _wsService.sendJson({
      'cmd': 'playPodcast',
      'params': [position.inMilliseconds.toString()],
    });
  }

  Future<void> pausePodcast() async {
    if (state.pendingAction != LiveHostPlayerPendingAction.none) return;
    _startPendingPlayerCommand(LiveHostPlayerPendingAction.pause);
    _wsService.sendJson({'cmd': 'pausePodcast'});
  }

  Future<void> seekPodcast(double milliseconds) async {
    if (state.pendingAction != LiveHostPlayerPendingAction.none) return;
    final position = Duration(milliseconds: milliseconds.round());
    _startPendingPlayerCommand(LiveHostPlayerPendingAction.seek);
    _wsService.sendJson({
      'cmd': 'seekPosition',
      'content': position.inMilliseconds.toString(),
    });
  }

  Future<void> disposePlayer() async {
    _playerSyncTimer?.cancel();
    _playerSyncTimer = null;
    _clearPendingPlayerCommand();
    await _positionSub?.cancel();
    _positionSub = null;
    await _playerStateSub?.cancel();
    _playerStateSub = null;
    await _player?.dispose();
    _player = null;
    _story = null;
    _roomId = '';
    state = const LiveHostPlayerState();
  }

  void _handleWsMessage(Map<String, dynamic> message) {
    final cmd = message['cmd']?.toString() ?? '';
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
    }
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
    state = state.copyWith(pendingAction: action, error: null);
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
      pendingAction: LiveHostPlayerPendingAction.none,
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
    if (state.pendingAction != LiveHostPlayerPendingAction.none) {
      state = state.copyWith(pendingAction: LiveHostPlayerPendingAction.none);
    }
  }

  Future<void> _playLocalPodcast(Duration position) async {
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
    if (_roomId.isEmpty) return;
    final position = _player?.position ?? state.currentPosition;
    final status = state.playerStatus == LiveHostPlayerStatus.playing
        ? 'playing'
        : 'paused';
    _wsService.sendJson({
      'cmd': 'initRoomPlayer',
      if (to != null && to.isNotEmpty) 'to': to,
      'roomId': _roomId,
      'params': [status, position.inMilliseconds.toString(), ''],
    });
  }

  Future<void> _initPlayer() async {
    if (_player != null) return;
    final story = _story;
    if (story == null || story.storyUrl.isEmpty) return;

    final player = AudioPlayer();
    _player = player;
    _positionSub = player.positionStream.listen((position) {
      state = state.copyWith(currentPosition: position);
    });
    _playerStateSub = player.playerStateStream.listen((playerState) {
      if (state.pendingAction != LiveHostPlayerPendingAction.none) return;
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
      if (_roomId.isEmpty) return;
      if (state.pendingAction != LiveHostPlayerPendingAction.none) return;
      final position = _player?.position ?? state.currentPosition;
      final status = state.playerStatus == LiveHostPlayerStatus.playing
          ? 'playing'
          : 'paused';
      _wsService.sendJson({
        'cmd': 'updateRoomPlayer',
        'params': [status, position.inMilliseconds.toString()],
      });
    });
  }
}

final liveHostPlayerControllerProvider =
    NotifierProvider<LiveHostPlayerController, LiveHostPlayerState>(
      LiveHostPlayerController.new,
    );
