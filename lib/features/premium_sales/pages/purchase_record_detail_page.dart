import 'package:actpod_studio/api/response/story_response/batch_get_user_stories.dart';
import 'package:actpod_studio/api/response/story_response/package_models.dart';
import 'package:actpod_studio/api/story_system_api.dart';
import 'package:actpod_studio/app/app_scaffold.dart';
import 'package:actpod_studio/features/premium_sales/models/premium_sales_models.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PurchaseRecordDetailPage extends StatefulWidget {
  final PremiumSaleType type;
  final String targetId;
  final String title;
  final String subtitle;
  final List<StoryItem> stories;

  const PurchaseRecordDetailPage({
    super.key,
    required this.type,
    required this.targetId,
    required this.title,
    required this.subtitle,
    required this.stories,
  });

  @override
  State<PurchaseRecordDetailPage> createState() =>
      _PurchaseRecordDetailPageState();
}

class _PurchaseRecordDetailPageState extends State<PurchaseRecordDetailPage> {
  static const _pageSize = 20;

  bool _loading = false;
  String? _error;
  int _total = 0;
  int _page = 1;
  List<PurchaseRecord> _records = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({int page = 1}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await StoryApi().getPurchaseRecords(
        storyId: widget.type == PremiumSaleType.single ? widget.targetId : null,
        packageId: widget.type == PremiumSaleType.package
            ? widget.targetId
            : null,
        page: page,
        pageSize: _pageSize,
      );
      setState(() {
        _loading = false;
        _page = response.data?.page ?? page;
        _total = response.data?.total ?? 0;
        _records = response.data?.records ?? const [];
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = _total == 0 ? 1 : ((_total - 1) ~/ _pageSize) + 1;
    return AppScaffold(
      title: 'ActPod 後台',
      child: ListView(
        padding: _responsivePadding(context),
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () => context.go('/premium_sales'),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('返回銷售列表'),
              ),
              IconButton.outlined(
                onPressed: _loading ? null : () => _load(page: _page),
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.subtitle,
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.type == PremiumSaleType.package
                      ? 'packageId: ${widget.targetId}'
                      : 'storyId: ${widget.targetId}',
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
                if (widget.stories.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.stories
                        .map(
                          (story) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(story.storyName),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (_error != null) ...[
            _ErrorBanner(message: _error!),
            const SizedBox(height: 18),
          ],
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '購買者列表',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '共 $_total 筆',
                      style: const TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_loading && _records.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_records.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      '目前沒有購買紀錄',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  )
                else ...[
                  ..._records.map((record) => _RecordTile(record: record)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _loading || _page <= 1
                            ? null
                            : () => _load(page: _page - 1),
                        child: const Text('上一頁'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('第 $_page / $totalPages 頁'),
                      ),
                      TextButton(
                        onPressed: _loading || _page >= totalPages
                            ? null
                            : () => _load(page: _page + 1),
                        child: const Text('下一頁'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  EdgeInsets _responsivePadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1750) {
      return const EdgeInsets.symmetric(horizontal: 120, vertical: 16);
    }
    if (w >= 1200) {
      return const EdgeInsets.symmetric(horizontal: 52, vertical: 16);
    }
    if (w >= 720) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    }
    return const EdgeInsets.symmetric(horizontal: 8, vertical: 12);
  }
}

class _RecordTile extends StatelessWidget {
  final PurchaseRecord record;

  const _RecordTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final buyerName = record.userInfo?.nickname.trim().isNotEmpty == true
        ? record.userInfo!.nickname
        : record.userId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: (record.userInfo?.avatarUrl.isNotEmpty ?? false)
                  ? NetworkImage(record.userInfo!.avatarUrl)
                  : null,
              child: (record.userInfo?.avatarUrl.isNotEmpty ?? false)
                  ? null
                  : const Icon(Icons.person_rounded),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    buyerName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    record.userId,
                    style: const TextStyle(color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatDateTime(record.createTime),
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 4),
                Text(
                  record.archive ? '已封存' : '有效',
                  style: TextStyle(
                    color: record.archive
                        ? const Color(0xFFB91C1C)
                        : const Color(0xFF047857),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return '-';
    final local = value.toLocal();
    return '${local.year}/${_two(local.month)}/${_two(local.day)} ${_two(local.hour)}:${_two(local.minute)}';
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFFB91C1C),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
