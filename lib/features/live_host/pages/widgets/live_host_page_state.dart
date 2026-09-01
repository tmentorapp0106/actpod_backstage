part of '../live_host_page.dart';

class _LiveHostPageState extends ConsumerState<LiveHostPage> {
  String? _loadedUserId;

  void _loadStoriesIfNeeded(String userId) {
    if (userId.isEmpty || userId == _loadedUserId) return;
    _loadedUserId = userId;
    Future.microtask(
      () => ref
          .read(liveHostStoriesControllerProvider.notifier)
          .loadStories(userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flowState = ref.watch(liveHostFlowControllerProvider);
    final userId = ref.watch(userControllerProvider)?.userId ?? '';
    _loadStoriesIfNeeded(userId);
    ref.listen(liveHostRoomControllerProvider, (previous, next) {
      if (next.status != LiveHostStatus.live || next.roomId.isEmpty) return;
      if (previous?.roomId == next.roomId &&
          previous?.status == LiveHostStatus.live) {
        return;
      }
      final selectedStory = ref
          .read(liveHostStoriesControllerProvider)
          .selectedStory;
      ref.read(liveHostFlowControllerProvider.notifier).goToLiveRoom();
      unawaited(
        ref
            .read(liveHostPlayerControllerProvider.notifier)
            .attachRoom(roomId: next.roomId, story: selectedStory),
      );
    });

    return AppScaffold(
      title: 'ActPod 後台',
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: switch (flowState.step) {
          LiveHostStep.landing => _LandingStep(
            onStart: () => ref
                .read(liveHostFlowControllerProvider.notifier)
                .startLiveFlow(),
          ),
          LiveHostStep.storySelection => _StorySelectionScope(userId: userId),
          LiveHostStep.liveSettings => _LiveSettingsScope(userId: userId),
          LiveHostStep.liveRoom => _LiveRoomStep(
            onCloseRoom: () async {
              await ref
                  .read(liveHostRoomControllerProvider.notifier)
                  .closeRoom();
              await ref
                  .read(liveHostPlayerControllerProvider.notifier)
                  .disposePlayer();
              ref.read(liveHostChatControllerProvider.notifier).reset();
              ref.read(liveHostMembersControllerProvider.notifier).reset();
              ref
                  .read(liveHostRoomControllerProvider.notifier)
                  .resetForNewLive();
              ref.read(liveHostFlowControllerProvider.notifier).backToLanding();
            },
            onStartNewLive: () => _startNewLiveFlow(ref),
          ),
        },
      ),
    );
  }
}
