import 'package:actpod_studio/api/response/user_response/received_donation.dart';
import 'package:actpod_studio/app/app_scaffold.dart';
import 'package:actpod_studio/features/create_story/controllers/user_controller.dart';
import 'package:actpod_studio/features/donation/controllers/donation_controller.dart';
import 'package:actpod_studio/features/statistic/models/statistic_models.dart';
import 'package:actpod_studio/features/statistic/widgets/period_segmented_filter.dart';
import 'package:actpod_studio/features/statistic/widgets/stat_metric_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DonationPage extends ConsumerStatefulWidget {
  const DonationPage({super.key});

  @override
  ConsumerState<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends ConsumerState<DonationPage> {
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
      () => ref.read(donationControllerProvider.notifier).load(userId),
    );
  }

  Future<void> _handlePeriodChanged(
    StatisticPeriod period,
    String userId,
    StatisticTimeRange currentRange,
  ) async {
    if (period == StatisticPeriod.custom) {
      await _pickTimeRange(userId, currentRange);
      return;
    }
    await ref
        .read(donationControllerProvider.notifier)
        .changePeriod(period, userId);
  }

  Future<void> _pickTimeRange(
    String userId,
    StatisticTimeRange currentRange,
  ) async {
    if (userId.isEmpty) return;

    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: DateTimeRange(
        start: currentRange.start,
        end: currentRange.end.subtract(const Duration(days: 1)),
      ),
      helpText: '選擇 Donation 區間',
      cancelText: '取消',
      confirmText: '套用',
      saveText: '套用',
      fieldStartLabelText: '開始日期',
      fieldEndLabelText: '結束日期',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: const DatePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null || !mounted) return;

    final range = StatisticTimeRange(
      start: DateTime(picked.start.year, picked.start.month, picked.start.day),
      end: DateTime(
        picked.end.year,
        picked.end.month,
        picked.end.day,
      ).add(const Duration(days: 1)),
    );
    await ref
        .read(donationControllerProvider.notifier)
        .changeTimeRange(range, userId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(donationControllerProvider);
    final userId = ref.watch(userControllerProvider)?.userId ?? '';
    if (userId.isNotEmpty && userId != _loadedUserId) {
      _loadedUserId = userId;
      Future.microtask(
        () => ref.read(donationControllerProvider.notifier).load(userId),
      );
    }

    return AppScaffold(
      title: 'ActPod 後台',
      child: RefreshIndicator(
        onRefresh: () =>
            ref.read(donationControllerProvider.notifier).load(userId),
        child: ListView(
          padding: _responsivePadding(context),
          children: [
            _Header(
              period: state.period,
              timeRange: state.timeRange,
              loading: state.loading,
              onPeriodChanged: (period) =>
                  _handlePeriodChanged(period, userId, state.timeRange),
              onRefresh: () =>
                  ref.read(donationControllerProvider.notifier).load(userId),
            ),
            const SizedBox(height: 18),
            if (state.error != null) ...[
              _ErrorBanner(message: state.error!),
              const SizedBox(height: 18),
            ],
            _SummaryGrid(state: state),
            const SizedBox(height: 18),
            if (state.loading && state.allDonations.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              DonationTable(donations: state.donations),
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
  final StatisticPeriod period;
  final StatisticTimeRange timeRange;
  final bool loading;
  final ValueChanged<StatisticPeriod> onPeriodChanged;
  final VoidCallback onRefresh;

  const _Header({
    required this.period,
    required this.timeRange,
    required this.loading,
    required this.onPeriodChanged,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Donation',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              '${period.title}收到 Donation：${timeRange.label}',
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ],
        ),
        const SizedBox(width: 8),
        PeriodSegmentedFilter(selected: period, onChanged: onPeriodChanged),
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

class _SummaryGrid extends StatelessWidget {
  final DonationState state;

  const _SummaryGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    final caption = '${state.period.title} · ${state.timeRange.label}';
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900 ? 2 : 1;
        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: columns == 1 ? 3.4 : 2.7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            StatMetricCard(
              icon: Icons.payments_rounded,
              label: '總共收到 PodCash',
              value: _formatNumber(state.totalReceivedPodCash),
              caption: caption,
              color: const Color(0xFFFFBC1F),
            ),
            StatMetricCard(
              icon: Icons.receipt_long_rounded,
              label: 'Donation 筆數',
              value: _formatNumber(state.donations.length),
              caption: caption,
              color: const Color(0xFF2563EB),
            ),
          ],
        );
      },
    );
  }
}

class DonationTable extends StatelessWidget {
  final List<ReceivedDonation> donations;

  const DonationTable({super.key, required this.donations});

  @override
  Widget build(BuildContext context) {
    if (donations.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 42),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            '此區間尚無 Donation 紀錄',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
          columns: const [
            DataColumn(label: Text('時間')),
            DataColumn(label: Text('支持者')),
            DataColumn(label: Text('類型')),
            DataColumn(label: Text('交易編號')),
            DataColumn(numeric: true, label: Text('PodCash')),
          ],
          rows: [
            for (final donation in donations)
              DataRow(
                cells: [
                  DataCell(Text(_formatDateTime(donation.createTime))),
                  DataCell(_SupporterCell(donation: donation)),
                  DataCell(Text(_typeLabel(donation.type))),
                  DataCell(
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: Text(
                        donation.transactionId,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      _formatNumber(donation.receivedPodCash),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _SupporterCell extends StatelessWidget {
  final ReceivedDonation donation;

  const _SupporterCell({required this.donation});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: const Color(0xFFFFBC1F).withValues(alpha: .15),
          backgroundImage: donation.fromUserAvatarUrl.isNotEmpty
              ? NetworkImage(donation.fromUserAvatarUrl)
              : null,
          child: donation.fromUserAvatarUrl.isEmpty
              ? const Icon(Icons.person_rounded, size: 16)
              : null,
        ),
        const SizedBox(width: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                donation.fromUserNickname.isEmpty
                    ? '未命名使用者'
                    : donation.fromUserNickname,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                donation.fromUserId,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        border: Border.all(color: const Color(0xFFFDA4AF)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFE11D48)),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

String _formatNumber(int value) {
  final text = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) buffer.write(',');
    buffer.write(text[i]);
  }
  return buffer.toString();
}

String _formatDateTime(DateTime? value) {
  if (value == null) return '-';
  final local = value.toLocal();
  return '${local.year}/${_twoDigits(local.month)}/${_twoDigits(local.day)} '
      '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

String _typeLabel(String value) {
  switch (value) {
    case 'SuperCommentDonation':
      return 'Super Comment';
    default:
      return value.isEmpty ? '-' : value;
  }
}
