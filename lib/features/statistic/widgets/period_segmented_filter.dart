import 'package:actpod_studio/features/statistic/models/statistic_models.dart';
import 'package:flutter/material.dart';

class PeriodSegmentedFilter extends StatelessWidget {
  final StatisticPeriod selected;
  final ValueChanged<StatisticPeriod> onChanged;

  const PeriodSegmentedFilter({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<StatisticPeriod>(
      segments: [
        for (final period in StatisticPeriod.values)
          ButtonSegment(
            value: period,
            label: Text(period.label),
            icon: Icon(_iconFor(period)),
          ),
      ],
      selected: {selected},
      onSelectionChanged: (value) => onChanged(value.first),
    );
  }

  IconData _iconFor(StatisticPeriod period) {
    switch (period) {
      case StatisticPeriod.day:
        return Icons.today_rounded;
      case StatisticPeriod.week:
        return Icons.view_week_rounded;
      case StatisticPeriod.month:
        return Icons.calendar_month_rounded;
      case StatisticPeriod.custom:
        return Icons.date_range_rounded;
    }
  }
}
