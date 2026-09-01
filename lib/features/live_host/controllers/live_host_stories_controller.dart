import 'package:actpod_studio/api/response/story_response/batch_get_user_stories.dart';
import 'package:actpod_studio/api/story_system_api.dart';
import 'package:actpod_studio/features/live_host/models/live_host_stories_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LiveHostStoriesController extends Notifier<LiveHostStoriesState> {
  @override
  LiveHostStoriesState build() => const LiveHostStoriesState();

  Future<void> loadStories(String userId) async {
    if (userId.isEmpty || state.loading) return;

    state = state.copyWith(loading: true, error: null);
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
        loading: false,
        stories: stories,
        selectedStory: selectedStory,
      );
    } catch (error) {
      state = state.copyWith(loading: false, error: error.toString());
    }
  }

  void updateSearchKeyword(String value) {
    state = state.copyWith(searchKeyword: value);
  }

  void selectStory(StoryItem story) {
    state = state.copyWith(selectedStory: story);
  }

  void resetSelection() {
    state = state.copyWith(selectedStory: null, searchKeyword: '');
  }

  StoryItem? _findStory(List<StoryItem> stories, String storyId) {
    for (final story in stories) {
      if (story.storyId == storyId) return story;
    }
    return null;
  }
}

final liveHostStoriesControllerProvider =
    NotifierProvider<LiveHostStoriesController, LiveHostStoriesState>(
      LiveHostStoriesController.new,
    );
