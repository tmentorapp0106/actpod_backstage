part of '../live_host_page.dart';

class _MemberTile extends StatelessWidget {
  final LiveHostMember member;
  final bool isOnMic;

  const _MemberTile({required this.member, required this.isOnMic});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: CircleAvatar(
        backgroundImage: member.avatarUrl.isEmpty
            ? null
            : NetworkImage(member.avatarUrl),
        child: member.avatarUrl.isEmpty
            ? const Icon(Icons.person_rounded)
            : null,
      ),
      title: Text(
        member.nickname.isEmpty ? member.userId : member.nickname,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        isOnMic
            ? '上麥中'
            : member.isHandsUp
            ? '舉手中'
            : '觀眾',
      ),
      trailing: Icon(
        isOnMic
            ? Icons.mic_rounded
            : member.isHandsUp
            ? Icons.front_hand_rounded
            : Icons.person_rounded,
        color: isOnMic || member.isHandsUp
            ? AppColors.brand
            : const Color(0xFF9CA3AF),
      ),
    );
  }
}
