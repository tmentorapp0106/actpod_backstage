part of '../live_host_page.dart';

class _LiveSettingsScope extends ConsumerWidget {
  final String userId;

  const _LiveSettingsScope({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(liveHostFlowControllerProvider);
    final stories = ref.watch(liveHostStoriesControllerProvider);
    final settings = ref.watch(liveHostSettingsControllerProvider);
    final room = ref.watch(liveHostRoomControllerProvider);
    return _LiveSettingsStep(
      state: _viewState(
        flow: flow,
        stories: stories,
        settings: settings,
        room: room,
      ),
      onBack: () => ref
          .read(liveHostFlowControllerProvider.notifier)
          .backToStorySelection(),
      onTitleChanged: ref
          .read(liveHostSettingsControllerProvider.notifier)
          .updateRoomTitle,
      onRoomTypeChanged: ref
          .read(liveHostSettingsControllerProvider.notifier)
          .updateRoomType,
      onCapacityChanged: ref
          .read(liveHostSettingsControllerProvider.notifier)
          .updateCapacity,
      onNotifyFansChanged: ref
          .read(liveHostSettingsControllerProvider.notifier)
          .updateNotifyFans,
      onNotyetOwnedPriceChanged: ref
          .read(liveHostSettingsControllerProvider.notifier)
          .updateNotyetOwnedStoryPrice,
      onAlreadyOwnedPriceChanged: ref
          .read(liveHostSettingsControllerProvider.notifier)
          .updateAlreadyOwnedStoryPrice,
      onOpenRoom: () => ref
          .read(liveHostRoomControllerProvider.notifier)
          .openRoom(
            userId: userId,
            selectedStory: stories.selectedStory,
            settings: settings,
          ),
    );
  }
}
