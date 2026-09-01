library;

import 'package:actpod_studio/api/response/story_response/batch_get_user_stories.dart';

import 'live_host_constants.dart';
import 'live_host_enums.dart';

class LiveHostRoomState {
  final LiveHostStatus status;
  final String? error;
  final String roomId;

  const LiveHostRoomState({
    this.status = LiveHostStatus.idle,
    this.error,
    this.roomId = '',
  });

  LiveHostRoomState copyWith({
    LiveHostStatus? status,
    Object? error = liveHostUnset,
    String? roomId,
  }) {
    return LiveHostRoomState(
      status: status ?? this.status,
      error: error == liveHostUnset ? this.error : error as String?,
      roomId: roomId ?? this.roomId,
    );
  }

  String shareUrl({
    required StoryItem? selectedStory,
    required LiveHostRoomType roomType,
  }) {
    final storyId = selectedStory?.storyId ?? '';
    if (roomId.isEmpty || storyId.isEmpty) return '';
    final roomTypeParam = switch (roomType) {
      LiveHostRoomType.listenOnly => 'listenOnly',
      LiveHostRoomType.interactive => 'interactive',
    };
    return 'https://web.actpodapp.com/live/$roomTypeParam/$roomId/$storyId?openExternalBrowser=1';
  }
}
