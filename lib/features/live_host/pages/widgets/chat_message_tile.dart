part of '../live_host_page.dart';

class _ChatMessageTile extends StatelessWidget {
  final LiveHostChatMessage message;

  const _ChatMessageTile({required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: message.avatarUrl.isEmpty
              ? null
              : NetworkImage(message.avatarUrl),
          child: message.avatarUrl.isEmpty
              ? const Icon(Icons.person_rounded, size: 18)
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.nickname.isEmpty ? message.userId : message.nickname,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 3),
              Text(message.content),
            ],
          ),
        ),
      ],
    );
  }
}
