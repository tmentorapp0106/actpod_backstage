import 'package:actpod_studio/app/app_scaffold.dart';
import 'package:actpod_studio/features/create_story/controllers/user_controller.dart';
import 'package:actpod_studio/features/statistic/controllers/statistic_controller.dart';
import 'package:actpod_studio/features/statistic/models/statistic_models.dart';
import 'package:actpod_studio/features/statistic/widgets/period_segmented_filter.dart';
import 'package:actpod_studio/features/statistic/widgets/stat_bar_chart.dart';
import 'package:actpod_studio/features/statistic/widgets/stat_metric_card.dart';
import 'package:actpod_studio/features/statistic/widgets/story_stat_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatisticPage extends ConsumerStatefulWidget {
  const StatisticPage({super.key});

  @override
  ConsumerState<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends ConsumerState<StatisticPage> {
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
      () => ref.read(statisticControllerProvider.notifier).load(userId),
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
        .read(statisticControllerProvider.notifier)
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
      helpText: '選擇統計區間',
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
        .read(statisticControllerProvider.notifier)
        .changeTimeRange(range, userId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(statisticControllerProvider);
    final userId = ref.watch(userControllerProvider)?.userId ?? '';
    if (userId.isNotEmpty && userId != _loadedUserId) {
      _loadedUserId = userId;
      Future.microtask(
        () => ref.read(statisticControllerProvider.notifier).load(userId),
      );
    }

    return AppScaffold(
      title: 'ActPod 後台',
      child: RefreshIndicator(
        onRefresh: () =>
            ref.read(statisticControllerProvider.notifier).load(userId),
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
                  ref.read(statisticControllerProvider.notifier).load(userId),
            ),
            const SizedBox(height: 18),
            if (state.error != null) ...[
              _ErrorBanner(message: state.error!),
              const SizedBox(height: 18),
            ],
            _SummaryGrid(
              summary: state.summary,
              period: state.period,
              timeRange: state.timeRange,
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 980) {
                  return Column(
                    children: [
                      StatBarChart(stories: state.topStories),
                      const SizedBox(height: 18),
                      _InteractionPanel(summary: state.summary),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: StatBarChart(stories: state.topStories),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      flex: 2,
                      child: _InteractionPanel(summary: state.summary),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            if (state.loading && state.stories.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              StoryStatTable(stories: state.stories),
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
            Text(
              '節目統計',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 4),
            Text(
              '${period.title}發布故事：${timeRange.label}',
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
  final StatisticSummary summary;
  final StatisticPeriod period;
  final StatisticTimeRange timeRange;

  const _SummaryGrid({
    required this.summary,
    required this.period,
    required this.timeRange,
  });

  @override
  Widget build(BuildContext context) {
    final caption = '${period.title} · ${timeRange.label}';
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1280
            ? 4
            : width >= 760
            ? 2
            : 1;
        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: columns == 1 ? 3.2 : 2.2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            StatMetricCard(
              icon: Icons.play_circle_rounded,
              label: '節目播放數',
              value: _formatNumber(summary.listenCount),
              caption: caption,
              color: const Color(0xFFFFBC1F),
            ),
            StatMetricCard(
              icon: Icons.forum_rounded,
              label: '留言數',
              value: _formatNumber(
                summary.commentCount + summary.instantCommentCount,
              ),
              caption: caption,
              color: const Color(0xFF2563EB),
            ),
            StatMetricCard(
              icon: Icons.favorite_rounded,
              label: '互動數',
              value: _formatNumber(summary.totalInteractions),
              caption: caption,
              color: const Color(0xFFEF4444),
            ),
            StatMetricCard(
              icon: Icons.percent_rounded,
              label: '互動率',
              value: _formatPercent(summary.interactionRate),
              caption: '${summary.storyCount} 個故事',
              color: const Color(0xFF22C55E),
            ),
          ],
        );
      },
    );
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

  String _formatPercent(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }
}

class _InteractionPanel extends StatelessWidget {
  final StatisticSummary summary;

  const _InteractionPanel({required this.summary});

  @override
  Widget build(BuildContext context) {
    final total = summary.totalInteractions;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '互動組成',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          _ProgressLine(
            label: '留言',
            value: summary.commentCount,
            total: total,
            color: const Color(0xFF2563EB),
          ),
          _ProgressLine(
            label: '即時留言',
            value: summary.instantCommentCount,
            total: total,
            color: const Color(0xFF7C3AED),
          ),
          _ProgressLine(
            label: '按讚',
            value: summary.likeCount,
            total: total,
            color: const Color(0xFFEF4444),
          ),
          _ProgressLine(
            label: '語音留言',
            value: summary.voiceMessageCount,
            total: total,
            color: const Color(0xFF22C55E),
          ),
        ],
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final Color color;

  const _ProgressLine({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : value / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(
                value.toString(),
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: color,
              backgroundColor: const Color(0xFFF3F4F6),
            ),
          ),
        ],
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
