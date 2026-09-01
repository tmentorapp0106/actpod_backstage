part of '../live_host_page.dart';

class _NoSearchResult extends StatelessWidget {
  const _NoSearchResult();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('找不到符合搜尋條件的故事', style: TextStyle(color: Color(0xFF6B7280))),
    );
  }
}
