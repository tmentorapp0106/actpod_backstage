import 'package:actpod_studio/app/app_scaffold.dart';
import 'package:actpod_studio/features/create_story/controllers/user_controller.dart';
import 'package:actpod_studio/features/premium_sales/controllers/premium_sales_controller.dart';
import 'package:actpod_studio/features/premium_sales/models/premium_sales_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PremiumSalesPage extends ConsumerStatefulWidget {
  const PremiumSalesPage({super.key});

  @override
  ConsumerState<PremiumSalesPage> createState() => _PremiumSalesPageState();
}

class _PremiumSalesPageState extends ConsumerState<PremiumSalesPage> {
  String? _loadedUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadForCurrentUser();
  }

  void _loadForCurrentUser() {
    final userId = ref.read(userControllerProvider)?.userId ?? '';
    if (userId.isEmpty || userId == _loadedUserId) return;
    _loadedUserId = userId;
    Future.microtask(
      () => ref.read(premiumSalesControllerProvider.notifier).load(userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(premiumSalesControllerProvider);
    final userId = ref.watch(userControllerProvider)?.userId ?? '';
    if (userId.isNotEmpty && userId != _loadedUserId) {
      _loadedUserId = userId;
      Future.microtask(
        () => ref.read(premiumSalesControllerProvider.notifier).load(userId),
      );
    }

    return AppScaffold(
      title: 'ActPod 後台',
      child: RefreshIndicator(
        onRefresh: () =>
            ref.read(premiumSalesControllerProvider.notifier).load(userId),
        child: ListView(
          padding: _responsivePadding(context),
          children: [
            _Header(
              loading: state.loading,
              onRefresh: () => ref
                  .read(premiumSalesControllerProvider.notifier)
                  .load(userId),
            ),
            const SizedBox(height: 18),
            if (state.error != null) ...[
              _ErrorBanner(message: state.error!),
              const SizedBox(height: 18),
            ],
            _OverviewRow(
              packageCount: state.packages.length,
              storyCount: state.singleStories.length,
              totalSales:
                  state.packages.fold(0, (sum, item) => sum + item.salesCount) +
                  state.singleStories.fold(
                    0,
                    (sum, item) => sum + item.salesCount,
                  ),
            ),
            const SizedBox(height: 18),
            if (state.loading &&
                state.packages.isEmpty &&
                state.singleStories.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              _Section(
                title: 'Package',
                items: state.packages,
                emptyMessage: '目前沒有 package premium stories',
              ),
              const SizedBox(height: 18),
              _Section(
                title: '個別販售',
                items: state.singleStories,
                emptyMessage: '目前沒有個別 premium stories',
              ),
            ],
          ],
        ),
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

class _Header extends StatelessWidget {
  final bool loading;
  final VoidCallback onRefresh;

  const _Header({required this.loading, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Premium 銷售紀錄',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        IconButton.outlined(
          tooltip: '重新整理',
          onPressed: loading ? null : onRefresh,
          icon: loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }
}

class _OverviewRow extends StatelessWidget {
  final int packageCount;
  final int storyCount;
  final int totalSales;

  const _OverviewRow({
    required this.packageCount,
    required this.storyCount,
    required this.totalSales,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _MetricCard(label: 'Package', value: packageCount.toString()),
        _MetricCard(label: '個別 premium stories', value: storyCount.toString()),
        _MetricCard(label: '總購買次數', value: totalSales.toString()),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;

  const _MetricCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF6B7280))),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<PremiumSaleEntry> items;
  final String emptyMessage;

  const _Section({
    required this.title,
    required this.items,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                emptyMessage,
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
            )
          else
            ...items.map((item) => _SaleCard(item: item)),
        ],
      ),
    );
  }
}

class _SaleCard extends StatelessWidget {
  final PremiumSaleEntry item;

  const _SaleCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          final uri = Uri(
            path: '/premium_sales/detail',
            queryParameters: {
              'type': item.isPackage ? 'package' : 'single',
              'id': item.targetId,
              'title': item.title,
              'subtitle': item.subtitle,
            },
          );
          context.go(uri.toString(), extra: item.stories);
        },
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.isPackage
                      ? const Color(0xFFE8F3FF)
                      : const Color(0xFFFFF5D8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  item.isPackage
                      ? Icons.inventory_2_rounded
                      : Icons.lock_open_rounded,
                  color: item.isPackage
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFB45309),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: const TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('已販售', style: TextStyle(color: Color(0xFF6B7280))),
                  const SizedBox(height: 4),
                  Text(
                    '${item.salesCount}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '查看購買者',
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
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
