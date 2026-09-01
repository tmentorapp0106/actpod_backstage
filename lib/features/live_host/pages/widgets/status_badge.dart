part of '../live_host_page.dart';

class _StatusBadge extends StatelessWidget {
  final LiveHostStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      LiveHostStatus.idle => '未開播',
      LiveHostStatus.connecting => '連線中',
      LiveHostStatus.live => '已開播',
      LiveHostStatus.closed => '已關閉',
      LiveHostStatus.error => '錯誤',
    };
    final color = switch (status) {
      LiveHostStatus.live => const Color(0xFF16A34A),
      LiveHostStatus.error => const Color(0xFFDC2626),
      LiveHostStatus.connecting => AppColors.brand,
      LiveHostStatus.closed => const Color(0xFF6B7280),
      LiveHostStatus.idle => const Color(0xFF6B7280),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
