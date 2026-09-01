library;

import 'package:actpod_studio/api/response/story_response/batch_get_user_stories.dart';

import 'live_host_chat_message.dart';
import 'live_host_constants.dart';
import 'live_host_enums.dart';
import 'live_host_member.dart';

class LiveHostViewState {
  final LiveHostStep step;
  final bool loadingStories;
  final String? error;
  final List<StoryItem> stories;
  final String searchKeyword;
  final StoryItem? selectedStory;
  final String roomTitle;
  final LiveHostRoomType roomType;
  final int capacity;
  final bool notifyFans;
  final int notyetOwnedStoryPrice;
  final int alreadyOwnedStoryPrice;
  final LiveHostStatus status;
  final String roomId;
  final List<LiveHostMember> members;
  final List<LiveHostChatMessage> chatMessages;
  final LiveHostPlayerStatus playerStatus;
  final LiveHostPlayerPendingAction pendingPlayerAction;
  final Duration currentPosition;
  final Duration duration;
  final List<String> onMicUserIds;

  const LiveHostViewState({
    this.step = LiveHostStep.landing,
    this.loadingStories = false,
    this.error,
    this.stories = const [],
    this.searchKeyword = '',
    this.selectedStory,
    this.roomTitle = '',
    this.roomType = LiveHostRoomType.listenOnly,
    this.capacity = 100,
    this.notifyFans = true,
    this.notyetOwnedStoryPrice = 0,
    this.alreadyOwnedStoryPrice = 0,
    this.status = LiveHostStatus.idle,
    this.roomId = '',
    this.members = const [],
    this.chatMessages = const [],
    this.playerStatus = LiveHostPlayerStatus.paused,
    this.pendingPlayerAction = LiveHostPlayerPendingAction.none,
    this.currentPosition = Duration.zero,
    this.duration = Duration.zero,
    this.onMicUserIds = const [],
  });

  List<StoryItem> get filteredStories {
    final keyword = searchKeyword.trim().toLowerCase();
    if (keyword.isEmpty) return stories;
    return stories.where((story) {
      return story.storyName.toLowerCase().contains(keyword) ||
          story.channelName.toLowerCase().contains(keyword);
    }).toList();
  }

  bool get canSubmitLiveSettings {
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

  String get shareUrl {
    final storyId = selectedStory?.storyId ?? '';
    if (roomId.isEmpty || storyId.isEmpty) return '';
    return 'https://web.actpodapp.com/live/$roomTypeParam/$roomId/$storyId?openExternalBrowser=1';
  }
}
