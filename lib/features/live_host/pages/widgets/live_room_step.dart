part of '../live_host_page.dart';

class _LiveRoomStep extends ConsumerWidget {
  final Future<void> Function() onCloseRoom;
  final VoidCallback onStartNewLive;

  const _LiveRoomStep({
    required this.onCloseRoom,
    required this.onStartNewLive,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomError = ref.watch(
      liveHostRoomControllerProvider.select((state) => state.error),
    );
    final playerError = ref.watch(
      liveHostPlayerControllerProvider.select((state) => state.error),
    );
    final error = roomError ?? playerError;

    return Column(
      key: const ValueKey('live-host-live-room'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (error != null) ...[
          _ErrorBanner(message: error),
          const SizedBox(height: 16),
        ],
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 900;
              final roomInfoCard = Consumer(
                builder: (context, ref, _) {
                  final stories = ref.watch(liveHostStoriesControllerProvider);
                  final settings = ref.watch(
                    liveHostSettingsControllerProvider,
                  );
                  final room = ref.watch(liveHostRoomControllerProvider);
                  return _RoomInfoCard(
                    state: _viewState(
                      stories: stories,
                      settings: settings,
                      room: room,
                    ),
                    onStartNewLive: onStartNewLive,
                  );
                },
              );
              final playerCard = Consumer(
                builder: (context, ref, _) {
                  final stories = ref.watch(liveHostStoriesControllerProvider);
                  final room = ref.watch(liveHostRoomControllerProvider);
                  final player = ref.watch(liveHostPlayerControllerProvider);
                  return _PlayerControlCard(
                    state: _viewState(
                      stories: stories,
                      room: room,
                      player: player,
                    ),
                    story: stories.selectedStory,
                    onCloseRoom: onCloseRoom,
                    onPlay: ref
                        .read(liveHostPlayerControllerProvider.notifier)
                        .playPodcast,
                    onPause: ref
                        .read(liveHostPlayerControllerProvider.notifier)
                        .pausePodcast,
                    onSeek: ref
                        .read(liveHostPlayerControllerProvider.notifier)
                        .seekPodcast,
                  );
                },
              );
              final chatCard = Consumer(
                builder: (context, ref, _) {
                  final chat = ref.watch(liveHostChatControllerProvider);
                  return _ChatPanel(state: _viewState(chat: chat));
                },
              );
              final membersCard = Consumer(
                builder: (context, ref, _) {
                  final members = ref.watch(liveHostMembersControllerProvider);
                  return _MembersPanel(state: _viewState(members: members));
                },
              );

              if (isNarrow) {
                return ListView(
                  children: [
                    playerCard,
                    const SizedBox(height: 16),
                    roomInfoCard,
                    const SizedBox(height: 16),
                    chatCard,
                    const SizedBox(height: 16),
                    membersCard,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(height: 250, child: playerCard),
                        const SizedBox(height: 16),
                        Expanded(child: chatCard),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 360,
                    child: Column(
                      children: [
                        roomInfoCard,
                        const SizedBox(height: 16),
                        Expanded(child: membersCard),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
