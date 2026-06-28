import 'package:flutter/foundation.dart';

enum StatisticPeriod { day, week, month }

extension StatisticPeriodLabel on StatisticPeriod {
  String get label {
    switch (this) {
      case StatisticPeriod.day:
        return '日';
      case StatisticPeriod.week:
        return '週';
      case StatisticPeriod.month:
        return '月';
    }
  }
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
