part of '../live_host_page.dart';

class _PlayerControlCard extends StatelessWidget {
  final LiveHostViewState state;
  final StoryItem? story;
  final Future<void> Function() onCloseRoom;
  final Future<void> Function() onPlay;
  final Future<void> Function() onPause;
  final ValueChanged<double> onSeek;

  const _PlayerControlCard({
    required this.state,
    required this.story,
    required this.onCloseRoom,
    required this.onPlay,
    required this.onPause,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final maxMs = state.duration.inMilliseconds <= 0
        ? 1.0
        : state.duration.inMilliseconds.toDouble();
    final positionMs = state.currentPosition.inMilliseconds
        .clamp(0, maxMs.round())
        .toDouble();
    final isLive = state.status == LiveHostStatus.live;
    final isPlaying = state.playerStatus == LiveHostPlayerStatus.playing;
    final isPending =
        state.pendingPlayerAction != LiveHostPlayerPendingAction.none;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 700;
            final storyPane = _StoryControlPreview(story: story);
            final controls = _PlayerControls(
              state: state,
              positionMs: positionMs,
              maxMs: maxMs,
              isLive: isLive,
              isPlaying: isPlaying,
              isPending: isPending,
              onCloseRoom: onCloseRoom,
              onPlay: onPlay,
              onPause: onPause,
              onSeek: onSeek,
            );

            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [storyPane, const SizedBox(height: 16), controls],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 210, child: storyPane),
                const SizedBox(width: 22),
                Expanded(child: controls),
              ],
            );
          },
        ),
      ),
    );
  }
}
