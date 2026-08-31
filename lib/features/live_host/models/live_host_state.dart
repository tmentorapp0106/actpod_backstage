import 'package:actpod_studio/api/response/story_response/batch_get_user_stories.dart';

const int liveHostInteractiveCapacityLimit = 50;

enum LiveHostStep { landing, storySelection, liveSettings, liveRoom }

enum LiveHostStatus { idle, connecting, live, closed, error }

enum LiveHostRoomType { listenOnly, interactive }

enum LiveHostPlayerStatus { paused, playing }

enum LiveHostPlayerPendingAction { none, play, pause, seek }

class LiveHostMember {
  final String userId;
  final String nickname;
  final String avatarUrl;
  final bool isHandsUp;
  final bool isSpeaking;

  const LiveHostMember({
    required this.userId,
    required this.nickname,
    required this.avatarUrl,
    this.isHandsUp = false,
    this.isSpeaking = false,
  });

  factory LiveHostMember.fromJson(Map<String, dynamic> json) {
    return LiveHostMember(
      userId: json['userId']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString() ?? '',
      isHandsUp: json['isHandsUp'] == true,
      isSpeaking: json['isSpeaking'] == true,
    );
  }

  LiveHostMember copyWith({bool? isHandsUp, bool? isSpeaking}) {
    return LiveHostMember(
      userId: userId,
      nickname: nickname,
      avatarUrl: avatarUrl,
      isHandsUp: isHandsUp ?? this.isHandsUp,
      isSpeaking: isSpeaking ?? this.isSpeaking,
    );
  }
}

class LiveHostChatMessage {
  final String userId;
  final String nickname;
  final String avatarUrl;
  final String content;
  final String type;

  const LiveHostChatMessage({
    required this.userId,
    required this.nickname,
    required this.avatarUrl,
    required this.content,
    this.type = 'text',
  });

  factory LiveHostChatMessage.fromJson(Map<String, dynamic> json) {
    return LiveHostChatMessage(
      userId: json['userId']?.toString() ?? json['from']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '',
      avatarUrl: json['userAvatarUrl']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      type: json['params'] is List && (json['params'] as List).isNotEmpty
          ? (json['params'] as List).first.toString()
          : 'text',
    );
  }
}

class LiveHostState {
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

  const LiveHostState({
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

  LiveHostState copyWith({
    LiveHostStep? step,
    bool? loadingStories,
    Object? error = _unset,
    List<StoryItem>? stories,
    String? searchKeyword,
    Object? selectedStory = _unset,
    String? roomTitle,
    LiveHostRoomType? roomType,
    int? capacity,
    bool? notifyFans,
    int? notyetOwnedStoryPrice,
    int? alreadyOwnedStoryPrice,
    LiveHostStatus? status,
    String? roomId,
    List<LiveHostMember>? members,
    List<LiveHostChatMessage>? chatMessages,
    LiveHostPlayerStatus? playerStatus,
    LiveHostPlayerPendingAction? pendingPlayerAction,
    Duration? currentPosition,
    Duration? duration,
    List<String>? onMicUserIds,
  }) {
    return LiveHostState(
      step: step ?? this.step,
      loadingStories: loadingStories ?? this.loadingStories,
      error: error == _unset ? this.error : error as String?,
      stories: stories ?? this.stories,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      selectedStory: selectedStory == _unset
          ? this.selectedStory
          : selectedStory as StoryItem?,
      roomTitle: roomTitle ?? this.roomTitle,
      roomType: roomType ?? this.roomType,
      capacity: capacity ?? this.capacity,
      notifyFans: notifyFans ?? this.notifyFans,
      notyetOwnedStoryPrice:
          notyetOwnedStoryPrice ?? this.notyetOwnedStoryPrice,
      alreadyOwnedStoryPrice:
          alreadyOwnedStoryPrice ?? this.alreadyOwnedStoryPrice,
      status: status ?? this.status,
      roomId: roomId ?? this.roomId,
      members: members ?? this.members,
      chatMessages: chatMessages ?? this.chatMessages,
      playerStatus: playerStatus ?? this.playerStatus,
      pendingPlayerAction: pendingPlayerAction ?? this.pendingPlayerAction,
      currentPosition: currentPosition ?? this.currentPosition,
      duration: duration ?? this.duration,
      onMicUserIds: onMicUserIds ?? this.onMicUserIds,
    );
  }

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

const _unset = Object();
