part of '../live_host_page.dart';

class _PlayerControls extends StatelessWidget {
  final LiveHostViewState state;
  final double positionMs;
  final double maxMs;
  final bool isLive;
  final bool isPlaying;
  final bool isPending;
  final Future<void> Function() onCloseRoom;
  final Future<void> Function() onPlay;
  final Future<void> Function() onPause;
  final ValueChanged<double> onSeek;

  const _PlayerControls({
    required this.state,
    required this.positionMs,
    required this.maxMs,
    required this.isLive,
    required this.isPlaying,
    required this.isPending,
    required this.onCloseRoom,
    required this.onPlay,
    required this.onPause,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _StatusBadge(status: state.status),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '播放器控制',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            OutlinedButton.icon(
              onPressed: state.status == LiveHostStatus.live
                  ? () => _confirmCloseRoom(context, onCloseRoom)
                  : null,
              icon: const Icon(Icons.stop_circle_rounded),
              label: const Text('關閉直播'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            FilledButton.icon(
              onPressed: !isLive || isPending
                  ? null
                  : isPlaying
                  ? onPause
                  : onPlay,
              icon: isPending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
              label: Text(isPending ? '同步中' : (isPlaying ? '暫停' : '播放')),
            ),
            const SizedBox(width: 12),
            Text(
              '${_formatDuration(state.currentPosition)} / ${_formatDuration(state.duration)}',
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.brand,
            inactiveTrackColor: const Color(0xFFE5E7EB),
            disabledActiveTrackColor: const Color(0xFFFBBF24),
            disabledInactiveTrackColor: const Color(0xFFE5E7EB),
            thumbColor: AppColors.brand,
            disabledThumbColor: const Color(0xFFFBBF24),
            overlayColor: AppColors.brand.withValues(alpha: 0.14),
            trackHeight: 6,
          ),
          child: Slider(
            value: positionMs,
            min: 0,
            max: maxMs,
            onChanged: isLive && !isPending ? onSeek : null,
          ),
        ),
        const Spacer(),
        const Text(
          '播放、暫停與拖曳進度會同步送給直播間聽眾。',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}
