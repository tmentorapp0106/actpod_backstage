part of '../live_host_page.dart';

class _ChatPanel extends StatelessWidget {
  final LiveHostViewState state;

  const _ChatPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '聊天室',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: state.chatMessages.isEmpty
                ? const Center(
                    child: Text(
                      '目前沒有聊天訊息',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.chatMessages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final message = state.chatMessages[index];
                      return _ChatMessageTile(message: message);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
