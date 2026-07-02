import 'package:actpod_studio/api/response/comment_response/batch_get_comments.dart';
import 'package:actpod_studio/api/response/story_response/batch_get_user_stories.dart';
import 'package:actpod_studio/app/app_scaffold.dart';
import 'package:actpod_studio/app/theme/app_colors.dart';
import 'package:actpod_studio/features/create_story/controllers/user_controller.dart';
import 'package:actpod_studio/features/interactive_managment/controllers/interactive_managment_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InteractiveManagmentPage extends ConsumerStatefulWidget {
  const InteractiveManagmentPage({super.key});

  @override
  ConsumerState<InteractiveManagmentPage> createState() =>
      _InteractiveManagmentPageState();
}

class _InteractiveManagmentPageState
    extends ConsumerState<InteractiveManagmentPage> {
  final _commentController = TextEditingController();
  final _replyController = TextEditingController();
  String? _loadedUserId;
  String? _replyingCommentId;

  @override
  void dispose() {
    _commentController.dispose();
    _replyController.dispose();
    super.dispose();
  }

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
      () => ref
          .read(interactiveManagmentControllerProvider.notifier)
          .load(userId),
    );
  }

  Future<void> _refresh(String userId) async {
    if (userId.isEmpty) return;
    await ref
        .read(interactiveManagmentControllerProvider.notifier)
        .load(userId);
  }

  Future<void> _submitComment() async {
    final text = _commentController.text;
    if (text.trim().isEmpty) return;
    await ref
        .read(interactiveManagmentControllerProvider.notifier)
        .createComment(text);
    if (!mounted) return;
    if (ref.read(interactiveManagmentControllerProvider).error == null) {
      _commentController.clear();
    }
  }

  Future<void> _submitReply(String commentId) async {
    final text = _replyController.text;
    if (text.trim().isEmpty) return;
    await ref
        .read(interactiveManagmentControllerProvider.notifier)
        .createReply(commentId: commentId, content: text);
    if (!mounted) return;
    if (ref.read(interactiveManagmentControllerProvider).error == null) {
      setState(() {
        _replyingCommentId = null;
        _replyController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(interactiveManagmentControllerProvider);
    final userId = ref.watch(userControllerProvider)?.userId ?? '';
    if (userId.isNotEmpty && userId != _loadedUserId) {
      _loadedUserId = userId;
      Future.microtask(
        () => ref
            .read(interactiveManagmentControllerProvider.notifier)
            .load(userId),
      );
    }

    final selectedStory = _selectedStory(state.stories, state.selectedStoryId);

    return AppScaffold(
      title: 'ActPod 後台',
      child: RefreshIndicator(
        onRefresh: () => _refresh(userId),
        child: ListView(
          padding: _responsivePadding(context),
          children: [
            _Header(
              loading: state.loadingStories || state.loadingComments,
              onRefresh: () => _refresh(userId),
            ),
            const SizedBox(height: 18),
            if (state.error != null) ...[
              _ErrorBanner(message: state.error!),
              const SizedBox(height: 18),
            ],
            if (state.loadingStories && state.stories.isEmpty)
              const _LoadingBlock()
            else if (state.stories.isEmpty)
              const _EmptyBlock()
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final storyList = _StoryList(
                    stories: state.stories,
                    selectedStoryId: state.selectedStoryId,
                    onSelected: (storyId) {
                      setState(() {
                        _replyingCommentId = null;
                        _replyController.clear();
                      });
                      ref
                          .read(interactiveManagmentControllerProvider.notifier)
                          .selectStory(storyId);
                    },
                  );
                  final commentPanel = _CommentPanel(
                    story: selectedStory,
                    comments: state.comments,
                    loading: state.loadingComments,
                    submitting: state.submitting,
                    commentController: _commentController,
                    replyController: _replyController,
                    replyingCommentId: _replyingCommentId,
                    onSubmitComment: _submitComment,
                    onStartReply: (commentId) {
                      setState(() {
                        _replyingCommentId = commentId;
                        _replyController.clear();
                      });
                    },
                    onCancelReply: () {
                      setState(() {
                        _replyingCommentId = null;
                        _replyController.clear();
                      });
                    },
                    onSubmitReply: _submitReply,
                  );

                  if (constraints.maxWidth < 980) {
                    return Column(
                      children: [
                        SizedBox(height: 340, child: storyList),
                        const SizedBox(height: 16),
                        SizedBox(height: 640, child: commentPanel),
                      ],
                    );
                  }
                  return SizedBox(
                    height: MediaQuery.of(context).size.height - 176,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 360, child: storyList),
                        const SizedBox(width: 16),
                        Expanded(child: commentPanel),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  StoryItem? _selectedStory(List<StoryItem> stories, String? storyId) {
    if (storyId == null) return null;
    for (final story in stories) {
      if (story.storyId == storyId) return story;
    }
    return null;
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
              '互動管理',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 4),
            Text(
              '管理故事留言、作者回覆與打賞互動',
              style: TextStyle(color: Color(0xFF6B7280)),
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

class _StoryList extends StatelessWidget {
  final List<StoryItem> stories;
  final String? selectedStoryId;
  final ValueChanged<String> onSelected;

  const _StoryList({
    required this.stories,
    required this.selectedStoryId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Text(
              '我的故事',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
              itemCount: stories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final story = stories[index];
                return _StoryTile(
                  story: story,
                  selected: story.storyId == selectedStoryId,
                  onTap: () => onSelected(story.storyId),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryTile extends StatelessWidget {
  final StoryItem story;
  final bool selected;
  final VoidCallback onTap;

  const _StoryTile({
    required this.story,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = story.storyImageUrl.isNotEmpty
        ? story.storyImageUrl
        : (story.storyImageUrls.isNotEmpty ? story.storyImageUrls.first : '');

    return Material(
      color: selected ? AppColors.brand.withValues(alpha: .12) : Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: imageUrl.isEmpty
                      ? Container(
                          color: const Color(0xFFF3F4F6),
                          child: const Icon(Icons.auto_stories_rounded),
                        )
                      : Image.network(imageUrl, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.storyName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      story.channelName.isEmpty ? '未分類頻道' : story.channelName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(story.releaseTime),
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.chevron_right_rounded, color: AppColors.brand),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentPanel extends StatelessWidget {
  final StoryItem? story;
  final List<CommentThread> comments;
  final bool loading;
  final bool submitting;
  final TextEditingController commentController;
  final TextEditingController replyController;
  final String? replyingCommentId;
  final VoidCallback onSubmitComment;
  final ValueChanged<String> onStartReply;
  final VoidCallback onCancelReply;
  final ValueChanged<String> onSubmitReply;

  const _CommentPanel({
    required this.story,
    required this.comments,
    required this.loading,
    required this.submitting,
    required this.commentController,
    required this.replyController,
    required this.replyingCommentId,
    required this.onSubmitComment,
    required this.onStartReply,
    required this.onCancelReply,
    required this.onSubmitReply,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _SelectedStoryHeader(story: story, commentCount: comments.length),
          const Divider(height: 1),
          _CommentComposer(
            controller: commentController,
            submitting: submitting,
            enabled: story != null,
            onSubmit: onSubmitComment,
          ),
          const Divider(height: 1),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : comments.isEmpty
                ? const _NoComments()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: comments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final thread = comments[index];
                      return _CommentThreadCard(
                        thread: thread,
                        submitting: submitting,
                        replyController: replyController,
                        replyingCommentId: replyingCommentId,
                        onStartReply: onStartReply,
                        onCancelReply: onCancelReply,
                        onSubmitReply: onSubmitReply,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SelectedStoryHeader extends StatelessWidget {
  final StoryItem? story;
  final int commentCount;

  const _SelectedStoryHeader({required this.story, required this.commentCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story?.storyName ?? '尚未選擇故事',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  story == null
                      ? '請先從左側選擇故事'
                      : '${story!.channelName} · $commentCount 則留言',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          const Icon(Icons.forum_rounded, color: AppColors.brand),
        ],
      ),
    );
  }
}

class _CommentComposer extends StatelessWidget {
  final TextEditingController controller;
  final bool submitting;
  final bool enabled;
  final VoidCallback onSubmit;

  const _CommentComposer({
    required this.controller,
    required this.submitting,
    required this.enabled,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled && !submitting,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '新增留言',
                prefixIcon: Icon(Icons.add_comment_rounded),
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton.icon(
            onPressed: enabled && !submitting ? onSubmit : null,
            icon: submitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_rounded, size: 18),
            label: const Text('送出'),
          ),
        ],
      ),
    );
  }
}

class _CommentThreadCard extends StatelessWidget {
  final CommentThread thread;
  final bool submitting;
  final TextEditingController replyController;
  final String? replyingCommentId;
  final ValueChanged<String> onStartReply;
  final VoidCallback onCancelReply;
  final ValueChanged<String> onSubmitReply;

  const _CommentThreadCard({
    required this.thread,
    required this.submitting,
    required this.replyController,
    required this.replyingCommentId,
    required this.onStartReply,
    required this.onCancelReply,
    required this.onSubmitReply,
  });

  @override
  Widget build(BuildContext context) {
    final comment = thread.comment;
    final isReplying = replyingCommentId == comment.commentId;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UserLine(
            name: _displayName(thread.user),
            avatarUrl: thread.user.avatarUrl,
            timeLabel: _formatDateTime(comment.commentTime),
          ),
          const SizedBox(height: 10),
          Text(comment.content, style: const TextStyle(height: 1.5)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _MetaChip(
                icon: Icons.mode_comment_outlined,
                label: '${comment.replyCount} 則回覆',
              ),
              if (comment.podcoins > 0) _TipChip(podcoins: comment.podcoins),
              TextButton.icon(
                onPressed: submitting
                    ? null
                    : () => onStartReply(comment.commentId),
                icon: const Icon(Icons.reply_rounded, size: 18),
                label: const Text('回覆'),
              ),
            ],
          ),
          if (thread.replies.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...thread.replies.map(
              (reply) => Padding(
                padding: const EdgeInsets.only(left: 18, top: 8),
                child: _ReplyBubble(reply: reply),
              ),
            ),
          ],
          if (isReplying) ...[
            const SizedBox(height: 12),
            _ReplyComposer(
              controller: replyController,
              submitting: submitting,
              onCancel: onCancelReply,
              onSubmit: () => onSubmitReply(comment.commentId),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReplyBubble extends StatelessWidget {
  final CommentReplyThread reply;

  const _ReplyBubble({required this.reply});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UserLine(
            name: _displayName(reply.user),
            avatarUrl: reply.user.avatarUrl,
            timeLabel: _formatDateTime(reply.reply.replyTime),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(reply.reply.content, style: const TextStyle(height: 1.5)),
              _MetaChip(
                icon: Icons.badge_outlined,
                label: reply.reply.replyType,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReplyComposer extends StatelessWidget {
  final TextEditingController controller;
  final bool submitting;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const _ReplyComposer({
    required this.controller,
    required this.submitting,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: !submitting,
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: '輸入回覆',
                    prefixIcon: Icon(Icons.reply_rounded),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: submitting ? null : onCancel,
                child: const Text('取消'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: submitting ? null : onSubmit,
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('送出回覆'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserLine extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final String timeLabel;

  const _UserLine({
    required this.name,
    required this.avatarUrl,
    required this.timeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.brand.withValues(alpha: .15),
          backgroundImage: avatarUrl.isEmpty ? null : NetworkImage(avatarUrl),
          child: avatarUrl.isEmpty
              ? const Icon(Icons.person_rounded, size: 16)
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Text(
          timeLabel,
          style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _TipChip extends StatelessWidget {
  final int podcoins;

  const _TipChip({required this.podcoins});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.paid_rounded, size: 16, color: AppColors.brand),
      label: Text('打賞 $podcoins Podcoins'),
      backgroundColor: AppColors.brand.withValues(alpha: .12),
      side: BorderSide(color: AppColors.brand.withValues(alpha: .3)),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.statusError.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.statusError.withValues(alpha: .3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.statusError),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 420,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 420,
      child: Center(
        child: Text('目前沒有可管理的故事', style: TextStyle(color: Color(0xFF6B7280))),
      ),
    );
  }
}

class _NoComments extends StatelessWidget {
  const _NoComments();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('這則故事目前還沒有留言', style: TextStyle(color: Color(0xFF6B7280))),
    );
  }
}

String _displayName(CommentUser user) {
  if (user.nickname.isNotEmpty) return user.nickname;
  if (user.username.isNotEmpty) return user.username;
  if (user.email.isNotEmpty) return user.email;
  return user.userId.isEmpty ? '未知使用者' : user.userId;
}

String _formatDate(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

String _formatDateTime(DateTime value) {
  return '${_formatDate(value)} '
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
}
