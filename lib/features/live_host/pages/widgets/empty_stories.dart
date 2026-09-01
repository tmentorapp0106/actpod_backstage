part of '../live_host_page.dart';

class _EmptyStories extends StatelessWidget {
  const _EmptyStories();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('目前沒有可選擇的故事', style: TextStyle(color: Color(0xFF6B7280))),
    );
  }
}
