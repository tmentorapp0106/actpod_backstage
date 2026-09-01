part of '../live_host_page.dart';

class _MembersPanel extends StatelessWidget {
  final LiveHostViewState state;

  const _MembersPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '觀眾 / 上麥',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  '${state.members.length} 人',
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: state.members.isEmpty
                ? const Center(
                    child: Text(
                      '目前沒有觀眾',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: state.members.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final member = state.members[index];
                      return _MemberTile(
                        member: member,
                        isOnMic: state.onMicUserIds.contains(member.userId),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
