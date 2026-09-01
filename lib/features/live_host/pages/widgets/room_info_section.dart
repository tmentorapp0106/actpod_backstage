part of '../live_host_page.dart';

class _RoomInfoSection extends StatelessWidget {
  final LiveHostViewState state;
  final VoidCallback onStartNewLive;
  final String shareUrl;
  final VoidCallback? onCopyShareUrl;

  const _RoomInfoSection({
    required this.state,
    required this.onStartNewLive,
    required this.shareUrl,
    required this.onCopyShareUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.status == LiveHostStatus.closed) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '直播已關閉，可以重新開始新的直播流程。',
                    style: TextStyle(color: Color(0xFF4B5563)),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: onStartNewLive,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('重新開始直播'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],
        _InfoRow(label: '房間標題', value: state.roomTitle),
        const SizedBox(height: 10),
        _InfoRow(label: 'Room ID', value: state.roomId),
        const SizedBox(height: 10),
        _InfoRow(
          label: '直播模式',
          value: state.roomType == LiveHostRoomType.listenOnly
              ? '陪聽直播'
              : '互動直播',
        ),
        const SizedBox(height: 18),
        _ShareLinkBox(shareUrl: shareUrl, onCopy: onCopyShareUrl),
      ],
    );
  }
}
