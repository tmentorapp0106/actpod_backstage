library;

import 'live_host_constants.dart';
import 'live_host_enums.dart';

class LiveHostPlayerState {
  final LiveHostPlayerStatus playerStatus;
  final LiveHostPlayerPendingAction pendingAction;
  final Duration currentPosition;
  final Duration duration;
  final String? error;

  const LiveHostPlayerState({
    this.playerStatus = LiveHostPlayerStatus.paused,
    this.pendingAction = LiveHostPlayerPendingAction.none,
    this.currentPosition = Duration.zero,
    this.duration = Duration.zero,
    this.error,
  });

  LiveHostPlayerState copyWith({
    LiveHostPlayerStatus? playerStatus,
    LiveHostPlayerPendingAction? pendingAction,
    Duration? currentPosition,
    Duration? duration,
    Object? error = liveHostUnset,
  }) {
    return LiveHostPlayerState(
      playerStatus: playerStatus ?? this.playerStatus,
      pendingAction: pendingAction ?? this.pendingAction,
      currentPosition: currentPosition ?? this.currentPosition,
      duration: duration ?? this.duration,
      error: error == liveHostUnset ? this.error : error as String?,
    );
  }
}
