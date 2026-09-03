part of '../live_host_page.dart';

class _MemberTile extends StatelessWidget {
  final LiveHostMember member;
  final bool isOnMic;

  const _MemberTile({required this.member, required this.isOnMic});

  @override
  Widget build(BuildContext context) {
    final statusText = isOnMic
        ? '上麥中'
        : member.isHandsUp
        ? '舉手中'
        : '觀眾';
    final statusIcon = isOnMic
        ? Icons.mic_rounded
        : member.isHandsUp
        ? Icons.front_hand_rounded
        : Icons.person_rounded;
    final statusColor = isOnMic || member.isHandsUp
        ? AppColors.brand
        : const Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: member.avatarUrl.isEmpty
                ? null
                : NetworkImage(member.avatarUrl),
            child: member.avatarUrl.isEmpty
                ? const Icon(Icons.person_rounded, size: 18)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              member.nickname.isEmpty ? member.userId : member.nickname,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 14, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
