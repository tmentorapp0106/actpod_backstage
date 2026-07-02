import 'package:actpod_studio/api/comment_system_api.dart';
import 'package:actpod_studio/api/response/comment_response/batch_get_comments.dart';
import 'package:actpod_studio/api/response/story_response/batch_get_user_stories.dart';
import 'package:actpod_studio/api/story_system_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class InteractiveManagmentState {
  final bool loadingStories;
  final bool loadingComments;
  final bool submitting;
  final String? error;
  final List<StoryItem> stories;
  final String? selectedStoryId;
  final List<CommentThread> comments;

  const InteractiveManagmentState({
    this.loadingStories = false,
    this.loadingComments = false,
    this.submitting = false,
    this.error,
    this.stories = const [],
    this.selectedStoryId,
    this.comments = const [],
  });

  InteractiveManagmentState copyWith({
    bool? loadingStories,
    bool? loadingComments,
    bool? submitting,
    Object? error = _unset,
    List<StoryItem>? stories,
    Object? selectedStoryId = _unset,
    List<CommentThread>? comments,
  }) {
    return InteractiveManagmentState(
      loadingStories: loadingStories ?? this.loadingStories,
      loadingComments: loadingComments ?? this.loadingComments,
      submitting: submitting ?? this.submitting,
      error: error == _unset ? this.error : error as String?,
      stories: stories ?? this.stories,
      selectedStoryId: selectedStoryId == _unset
          ? this.selectedStoryId
          : selectedStoryId as String?,
      comments: comments ?? this.comments,
    );
  }
}

const _unset = Object();

class InteractiveManagmentController
    extends Notifier<InteractiveManagmentState> {
  @override
  InteractiveManagmentState build() => const InteractiveManagmentState();

  Future<void> load(String userId) async {
    if (userId.isEmpty || state.loadingStories) return;

    state = state.copyWith(
      loadingStories: true,
      loadingComments: true,
      error: null,
    );
    try {
      final storiesResponse = await StoryApi().getStoriesByUserId(
        userId,
        filterReviewStatus: false,
      );
      final stories = [...?storiesResponse.storyList]
        ..sort((a, b) => b.releaseTime.compareTo(a.releaseTime));
      final selectedStoryId = _nextSelectedStoryId(stories);
      final comments = selectedStoryId == null
          ? <CommentThread>[]
          : await _fetchComments(selectedStoryId);

      state = state.copyWith(
        loadingStories: false,
        loadingComments: false,
        stories: stories,
        selectedStoryId: selectedStoryId,
        comments: comments,
      );
    } catch (e) {
      state = state.copyWith(
        loadingStories: false,
        loadingComments: false,
        error: e.toString(),
      );
    }
  }

  Future<void> selectStory(String storyId) async {
    if (storyId == state.selectedStoryId || state.loadingComments) return;

    state = state.copyWith(
      selectedStoryId: storyId,
      comments: const [],
      loadingComments: true,
      error: null,
    );
    try {
      final comments = await _fetchComments(storyId);
      state = state.copyWith(loadingComments: false, comments: comments);
    } catch (e) {
      state = state.copyWith(loadingComments: false, error: e.toString());
    }
  }

  Future<void> refreshSelectedComments() async {
    final storyId = state.selectedStoryId;
    if (storyId == null || storyId.isEmpty || state.loadingComments) return;

    state = state.copyWith(loadingComments: true, error: null);
    try {
      final comments = await _fetchComments(storyId);
      state = state.copyWith(loadingComments: false, comments: comments);
    } catch (e) {
      state = state.copyWith(loadingComments: false, error: e.toString());
    }
  }

  Future<void> createComment(String content, {int sendTiming = 0}) async {
    final storyId = state.selectedStoryId;
    final trimmed = content.trim();
    if (storyId == null || storyId.isEmpty || trimmed.isEmpty) return;

    state = state.copyWith(submitting: true, error: null);
    try {
      await CommentApi().createComment(storyId, trimmed, sendTiming);
      final comments = await _fetchComments(storyId);
      state = state.copyWith(submitting: false, comments: comments);
    } catch (e) {
      state = state.copyWith(submitting: false, error: e.toString());
    }
  }

  Future<void> createReply({
    required String commentId,
    required String content,
  }) async {
    final storyId = state.selectedStoryId;
    final trimmed = content.trim();
    if (storyId == null ||
        storyId.isEmpty ||
        commentId.isEmpty ||
        trimmed.isEmpty) {
      return;
    }

    state = state.copyWith(submitting: true, error: null);
    try {
      await CommentApi().createReply(commentId, storyId, 'owner', trimmed);
      final comments = await _fetchComments(storyId);
      state = state.copyWith(submitting: false, comments: comments);
    } catch (e) {
      state = state.copyWith(submitting: false, error: e.toString());
    }
  }

  String? _nextSelectedStoryId(List<StoryItem> stories) {
    final current = state.selectedStoryId;
    if (current != null && stories.any((story) => story.storyId == current)) {
      return current;
    }
    return stories.isEmpty ? null : stories.first.storyId;
  }

  Future<List<CommentThread>> _fetchComments(String storyId) async {
    final response = await CommentApi().batchGetComments([storyId]);
    final storyComments = response.data.firstWhere(
      (item) => item.story == storyId,
      orElse: () => response.data.isEmpty
          ? const StoryComments(story: '', comments: [])
          : response.data.first,
    );
    return storyComments.comments;
  }
}

final interactiveManagmentControllerProvider =
    NotifierProvider<InteractiveManagmentController, InteractiveManagmentState>(
      InteractiveManagmentController.new,
    );
