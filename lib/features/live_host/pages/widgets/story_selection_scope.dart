part of '../live_host_page.dart';

class _StorySelectionScope extends ConsumerWidget {
  final String userId;

  const _StorySelectionScope({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stories = ref.watch(liveHostStoriesControllerProvider);
    return _StorySelectionStep(
      state: _viewState(stories: stories),
      onBack: () =>
          ref.read(liveHostFlowControllerProvider.notifier).backToLanding(),
      onSearchChanged: ref
          .read(liveHostStoriesControllerProvider.notifier)
          .updateSearchKeyword,
      onRefresh: () => ref
          .read(liveHostStoriesControllerProvider.notifier)
          .loadStories(userId),
      onSelected: (story) {
        ref.read(liveHostStoriesControllerProvider.notifier).selectStory(story);
        ref
            .read(liveHostSettingsControllerProvider.notifier)
            .applyStoryDefaultTitle(story);
      },
      onNext: () {
        final selectedStory = ref
            .read(liveHostStoriesControllerProvider)
            .selectedStory;
        if (selectedStory == null) return;
        ref
            .read(liveHostSettingsControllerProvider.notifier)
            .applyStoryDefaultTitle(selectedStory);
        ref.read(liveHostFlowControllerProvider.notifier).goToLiveSettings();
      },
    );
  }
}
