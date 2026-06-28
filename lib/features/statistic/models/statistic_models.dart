import 'package:flutter/foundation.dart';

enum StatisticPeriod { day, week, month, custom }

extension StatisticPeriodLabel on StatisticPeriod {
  String get label {
    switch (this) {
      case StatisticPeriod.day:
        return '日';
      case StatisticPeriod.week:
        return '週';
      case StatisticPeriod.month:
        return '月';
      case StatisticPeriod.custom:
        return '自訂';
    }
  }

  String get title {
    switch (this) {
      case StatisticPeriod.day:
        return '今日';
      case StatisticPeriod.week:
        return '本週';
      case StatisticPeriod.month:
        return '本月';
      case StatisticPeriod.custom:
        return '自訂區間';
    }
  }

  StatisticTimeRange rangeFor(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    switch (this) {
      case StatisticPeriod.day:
        return StatisticTimeRange(
          start: today,
          end: today.add(const Duration(days: 1)),
        );
      case StatisticPeriod.week:
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        return StatisticTimeRange(
          start: weekStart,
          end: weekStart.add(const Duration(days: 7)),
        );
      case StatisticPeriod.month:
        final monthStart = DateTime(today.year, today.month);
        return StatisticTimeRange(
          start: monthStart,
          end: DateTime(today.year, today.month + 1),
        );
      case StatisticPeriod.custom:
        return StatisticTimeRange(
          start: today,
          end: today.add(const Duration(days: 1)),
        );
    }
  }
}

@immutable
class StatisticTimeRange {
  final DateTime start;
  final DateTime end;

  const StatisticTimeRange({required this.start, required this.end});

  bool contains(DateTime value) {
    final localValue = value.toLocal();
    return !localValue.isBefore(start) && localValue.isBefore(end);
  }

  String get label {
    final inclusiveEnd = end.subtract(const Duration(days: 1));
    if (_sameDay(start, inclusiveEnd)) {
      return _formatDate(start);
    }
    return '${_formatDate(start)} - ${_formatDate(inclusiveEnd)}';
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDate(DateTime value) {
    return '${value.year}/${_twoDigits(value.month)}/${_twoDigits(value.day)}';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

@immutable
class StatisticStory {
  final String storyId;
  final String storyName;
  final String packageName;
  final DateTime? releaseTime;

  const StatisticStory({
    required this.storyId,
    required this.storyName,
    required this.packageName,
    required this.releaseTime,
  });
}

@immutable
class StoryStatistic {
  final StatisticStory story;
  final int listenCount;
  final int commentCount;
  final int instantCommentCount;
  final int likeCount;
  final int voiceMessageCount;

  const StoryStatistic({
    required this.story,
    required this.listenCount,
    required this.commentCount,
    required this.instantCommentCount,
    required this.likeCount,
    required this.voiceMessageCount,
  });

  int get totalInteractions =>
      commentCount + instantCommentCount + likeCount + voiceMessageCount;

  double get interactionRate {
    if (listenCount <= 0) return 0;
    return totalInteractions / listenCount;
  }
}

@immutable
class StatisticSummary {
  final int storyCount;
  final int listenCount;
  final int commentCount;
  final int instantCommentCount;
  final int likeCount;
  final int voiceMessageCount;

  const StatisticSummary({
    required this.storyCount,
    required this.listenCount,
    required this.commentCount,
    required this.instantCommentCount,
    required this.likeCount,
    required this.voiceMessageCount,
  });

  const StatisticSummary.empty()
    : storyCount = 0,
      listenCount = 0,
      commentCount = 0,
      instantCommentCount = 0,
      likeCount = 0,
      voiceMessageCount = 0;

  int get totalInteractions =>
      commentCount + instantCommentCount + likeCount + voiceMessageCount;

  double get interactionRate {
    if (listenCount <= 0) return 0;
    return totalInteractions / listenCount;
  }
}
