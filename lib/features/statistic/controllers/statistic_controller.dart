import 'package:actpod_studio/api/comment_system_api.dart';
import 'package:actpod_studio/api/response/comment_response/batch_get_stat.dart';
import 'package:actpod_studio/api/response/story_response/batch_get_listen_count.dart';
import 'package:actpod_studio/api/response/voice_message_response/batch_get_stat.dart';
import 'package:actpod_studio/api/story_system_api.dart';
import 'package:actpod_studio/api/voice_message_system_api.dart';
import 'package:actpod_studio/features/statistic/models/statistic_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class StatisticState {
  final StatisticPeriod period;
  final bool loading;
  final String? error;
  final List<StoryStatistic> stories;

  const StatisticState({
    this.period = StatisticPeriod.day,
    this.loading = false,
    this.error,
    this.stories = const [],
  });

  StatisticSummary get summary {
    return StatisticSummary(
      storyCount: stories.length,
      listenCount: stories.fold(0, (sum, item) => sum + item.listenCount),
      commentCount: stories.fold(0, (sum, item) => sum + item.commentCount),
      instantCommentCount: stories.fold(
        0,
        (sum, item) => sum + item.instantCommentCount,
      ),
      likeCount: stories.fold(0, (sum, item) => sum + item.likeCount),
      voiceMessageCount: stories.fold(
        0,
        (sum, item) => sum + item.voiceMessageCount,
      ),
    );
  }

  List<StoryStatistic> get topStories {
    final sorted = [...stories]
      ..sort((a, b) => b.listenCount.compareTo(a.listenCount));
    return sorted.take(8).toList();
  }

  StatisticState copyWith({
    StatisticPeriod? period,
    bool? loading,
    Object? error = _unset,
    List<StoryStatistic>? stories,
  }) {
    return StatisticState(
      period: period ?? this.period,
      loading: loading ?? this.loading,
      error: error == _unset ? this.error : error as String?,
      stories: stories ?? this.stories,
    );
  }
}

const _unset = Object();

class StatisticController extends Notifier<StatisticState> {
  @override
  StatisticState build() => const StatisticState();

  Future<void> changePeriod(StatisticPeriod period, String userId) async {
    state = state.copyWith(period: period);
    await load(userId);
  }

  Future<void> load(String userId) async {
    if (userId.isEmpty || state.loading) return;

    state = state.copyWith(loading: true, error: null);
    try {
      final storyApi = StoryApi();
      final storiesResponse = await storyApi.getStoriesByUserId(
        userId,
        filterReviewStatus: false,
      );

      final stories = <String, StatisticStory>{};
      for (final story in storiesResponse.storyList ?? const []) {
        if (story.storyId.isEmpty) continue;
        stories[story.storyId] = StatisticStory(
          storyId: story.storyId,
          storyName: story.storyName,
          packageName: story.channelName,
          releaseTime: story.releaseTime,
        );
      }

      final storyIds = stories.keys.toList();
      if (storyIds.isEmpty) {
        state = state.copyWith(stories: const [], loading: false);
        return;
      }

      final results = await Future.wait([
        storyApi.batchGetListenCount(storyIds),
        CommentApi().batchGetStoryStat(storyIds),
        VoiceMessageApi().batchGetVoiceMessageStat(storyIds),
      ]);

      final listenCounts = _listenCountMap(
        (results[0] as BatchGetListenCountResponse).listenCounts,
      );
      final commentStats = _commentStatMap(
        (results[1] as BatchGetStoryStatResponse).data,
      );
      final voiceStats = _voiceMessageStatMap(
        (results[2] as BatchGetVoiceMessageResponse).stats,
      );

      final storyStats = [
        for (final story in stories.values)
          StoryStatistic(
            story: story,
            listenCount: listenCounts[story.storyId] ?? 0,
            commentCount: commentStats[story.storyId]?.commentCount ?? 0,
            instantCommentCount:
                commentStats[story.storyId]?.instantCommentCount ?? 0,
            likeCount: commentStats[story.storyId]?.likeCount ?? 0,
            voiceMessageCount: voiceStats[story.storyId] ?? 0,
          ),
      ]..sort((a, b) => b.listenCount.compareTo(a.listenCount));

      state = state.copyWith(stories: storyStats, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Map<String, int> _listenCountMap(List<StoryListenCount> values) {
    return {
      for (final value in values)
        if (value.storyId.isNotEmpty) value.storyId: value.count,
    };
  }

  Map<String, CommentStoryStat> _commentStatMap(List<CommentStoryStat> values) {
    return {
      for (final value in values)
        if (value.storyId.isNotEmpty) value.storyId: value,
    };
  }

  Map<String, int> _voiceMessageStatMap(List<VoiceMessageStat> values) {
    final result = <String, int>{};
    for (final value in values) {
      if (value.storyId.isEmpty || value.archive) continue;
      result[value.storyId] = (result[value.storyId] ?? 0) + value.count;
    }
    return result;
  }
}

final statisticControllerProvider =
    NotifierProvider<StatisticController, StatisticState>(
      StatisticController.new,
    );
