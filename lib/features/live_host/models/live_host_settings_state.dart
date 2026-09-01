library;

import 'package:actpod_studio/api/response/story_response/batch_get_user_stories.dart';

import 'live_host_constants.dart';
import 'live_host_enums.dart';

class LiveHostSettingsState {
  final String roomTitle;
  final LiveHostRoomType roomType;
  final int capacity;
  final bool notifyFans;
  final int notyetOwnedStoryPrice;
  final int alreadyOwnedStoryPrice;

  const LiveHostSettingsState({
    this.roomTitle = '',
    this.roomType = LiveHostRoomType.listenOnly,
    this.capacity = 100,
    this.notifyFans = true,
    this.notyetOwnedStoryPrice = 0,
    this.alreadyOwnedStoryPrice = 0,
  });

  LiveHostSettingsState copyWith({
    String? roomTitle,
    LiveHostRoomType? roomType,
    int? capacity,
    bool? notifyFans,
    int? notyetOwnedStoryPrice,
    int? alreadyOwnedStoryPrice,
  }) {
    return LiveHostSettingsState(
      roomTitle: roomTitle ?? this.roomTitle,
      roomType: roomType ?? this.roomType,
      capacity: capacity ?? this.capacity,
      notifyFans: notifyFans ?? this.notifyFans,
      notyetOwnedStoryPrice:
          notyetOwnedStoryPrice ?? this.notyetOwnedStoryPrice,
      alreadyOwnedStoryPrice:
          alreadyOwnedStoryPrice ?? this.alreadyOwnedStoryPrice,
    );
  }

  bool canSubmit(StoryItem? selectedStory) {
    return selectedStory != null &&
        roomTitle.trim().isNotEmpty &&
        capacity > 0 &&
        (roomType != LiveHostRoomType.interactive ||
            capacity <= liveHostInteractiveCapacityLimit) &&
        notyetOwnedStoryPrice >= 0 &&
        alreadyOwnedStoryPrice >= 0;
  }

  String get roomTypeParam {
    return switch (roomType) {
      LiveHostRoomType.listenOnly => 'listenOnly',
      LiveHostRoomType.interactive => 'interactive',
    };
  }
}
