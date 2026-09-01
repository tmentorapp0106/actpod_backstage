library;

import 'package:actpod_studio/api/response/story_response/batch_get_user_stories.dart';

import 'live_host_constants.dart';

class LiveHostStoriesState {
  final bool loading;
  final String? error;
  final List<StoryItem> stories;
  final String searchKeyword;
  final StoryItem? selectedStory;

  const LiveHostStoriesState({
    this.loading = false,
    this.error,
    this.stories = const [],
    this.searchKeyword = '',
    this.selectedStory,
  });

  LiveHostStoriesState copyWith({
    bool? loading,
    Object? error = liveHostUnset,
    List<StoryItem>? stories,
    String? searchKeyword,
    Object? selectedStory = liveHostUnset,
  }) {
    return LiveHostStoriesState(
      loading: loading ?? this.loading,
      error: error == liveHostUnset ? this.error : error as String?,
      stories: stories ?? this.stories,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      selectedStory: selectedStory == liveHostUnset
          ? this.selectedStory
          : selectedStory as StoryItem?,
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
}
