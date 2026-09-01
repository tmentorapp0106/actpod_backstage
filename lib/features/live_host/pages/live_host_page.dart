import 'package:actpod_studio/api/response/story_response/batch_get_user_stories.dart';
import 'package:actpod_studio/app/app_scaffold.dart';
import 'package:actpod_studio/app/theme/app_colors.dart';
import 'package:actpod_studio/features/create_story/controllers/user_controller.dart';
import 'package:actpod_studio/features/live_host/controllers/live_host_controller.dart';
import 'package:actpod_studio/features/live_host/models/live_host_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LiveHostPage extends ConsumerStatefulWidget {
  const LiveHostPage({super.key});

  @override
  ConsumerState<LiveHostPage> createState() => _LiveHostPageState();
}

class _LiveHostPageState extends ConsumerState<LiveHostPage> {
  String? _loadedUserId;

  void _loadStoriesIfNeeded(String userId) {
    if (userId.isEmpty || userId == _loadedUserId) return;
    _loadedUserId = userId;
    Future.microtask(
      () => ref.read(liveHostControllerProvider.notifier).loadStories(userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(liveHostControllerProvider);
    final userId = ref.watch(userControllerProvider)?.userId ?? '';
    _loadStoriesIfNeeded(userId);

    return AppScaffold(
      title: 'ActPod 後台',
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: switch (state.step) {
          LiveHostStep.landing => _LandingStep(
            onStart: () =>
                ref.read(liveHostControllerProvider.notifier).startLiveFlow(),
          ),
          LiveHostStep.storySelection => _StorySelectionStep(
            state: state,
            onBack: () =>
                ref.read(liveHostControllerProvider.notifier).backToLanding(),
            onSearchChanged: ref
                .read(liveHostControllerProvider.notifier)
                .updateSearchKeyword,
            onRefresh: () => ref
                .read(liveHostControllerProvider.notifier)
                .loadStories(userId),
            onSelected: ref
                .read(liveHostControllerProvider.notifier)
                .selectStory,
            onNext: () => ref
                .read(liveHostControllerProvider.notifier)
                .goToLiveSettings(),
          ),
          LiveHostStep.liveSettings => _LiveSettingsStep(
            state: state,
            onBack: () => ref
                .read(liveHostControllerProvider.notifier)
                .backToStorySelection(),
            onTitleChanged: ref
                .read(liveHostControllerProvider.notifier)
                .updateRoomTitle,
            onRoomTypeChanged: ref
                .read(liveHostControllerProvider.notifier)
                .updateRoomType,
            onCapacityChanged: ref
                .read(liveHostControllerProvider.notifier)
                .updateCapacity,
            onNotifyFansChanged: ref
                .read(liveHostControllerProvider.notifier)
                .updateNotifyFans,
            onNotyetOwnedPriceChanged: ref
                .read(liveHostControllerProvider.notifier)
                .updateNotyetOwnedStoryPrice,
            onAlreadyOwnedPriceChanged: ref
                .read(liveHostControllerProvider.notifier)
                .updateAlreadyOwnedStoryPrice,
            onOpenRoom: () =>
                ref.read(liveHostControllerProvider.notifier).openRoom(userId),
          ),
          LiveHostStep.liveRoom => _LiveRoomStep(
            state: state,
            onCloseRoom: ref
                .read(liveHostControllerProvider.notifier)
                .closeRoom,
            onStartNewLive: ref
                .read(liveHostControllerProvider.notifier)
                .startNewLiveFlow,
            onPlayPodcast: ref
                .read(liveHostControllerProvider.notifier)
                .playPodcast,
            onPausePodcast: ref
                .read(liveHostControllerProvider.notifier)
                .pausePodcast,
            onSeekPodcast: ref
                .read(liveHostControllerProvider.notifier)
                .seekPodcast,
          ),
        },
      ),
    );
  }
}

class _LandingStep extends StatelessWidget {
  final VoidCallback onStart;

  const _LandingStep({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('live-host-landing'),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.podcasts_rounded,
              size: 64,
              color: AppColors.brand,
            ),
            const SizedBox(height: 18),
            const Text(
              '開始直播',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              '建立主持人直播流程，選擇故事後再設定直播內容。',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 15),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('開始直播'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StorySelectionStep extends StatelessWidget {
  final LiveHostState state;
  final VoidCallback onBack;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onRefresh;
  final ValueChanged<StoryItem> onSelected;
  final VoidCallback onNext;

  const _StorySelectionStep({
    required this.state,
    required this.onBack,
    required this.onSearchChanged,
    required this.onRefresh,
    required this.onSelected,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final stories = state.filteredStories;

    return Column(
      key: const ValueKey('live-host-story-selection'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton.outlined(
              tooltip: '回到開始',
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '選擇故事',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '選擇一則要用來開直播的故事。',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            IconButton.outlined(
              tooltip: '重新整理',
              onPressed: state.loadingStories ? null : onRefresh,
              icon: state.loadingStories
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        const SizedBox(height: 18),
        TextField(
          onChanged: onSearchChanged,
          decoration: const InputDecoration(
            hintText: '搜尋故事名稱或頻道',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 16),
        if (state.error != null) ...[
          _ErrorBanner(message: state.error!),
          const SizedBox(height: 16),
        ],
        Expanded(
          child: Card(
            child: state.loadingStories && state.stories.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.stories.isEmpty
                ? const _EmptyStories()
                : stories.isEmpty
                ? const _NoSearchResult()
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: stories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final story = stories[index];
                      return _StoryTile(
                        story: story,
                        selected: story.storyId == state.selectedStory?.storyId,
                        onTap: () => onSelected(story),
                      );
                    },
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                state.selectedStory == null
                    ? '請先選擇故事'
                    : '已選擇：${state.selectedStory!.storyName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: state.selectedStory == null ? null : onNext,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('下一步'),
            ),
          ],
        ),
      ],
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
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: imageUrl.isEmpty
                      ? Container(
                          color: const Color(0xFFF3F4F6),
                          child: const Icon(Icons.auto_stories_rounded),
                        )
                      : Image.network(imageUrl, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 14),
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
                            ? FontWeight.w800
                            : FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _StoryMetaChip(
                          icon: Icons.folder_rounded,
                          label: story.channelName.isEmpty
                              ? '未分類頻道'
                              : story.channelName,
                        ),
                        _StoryMetaChip(
                          icon: Icons.schedule_rounded,
                          label: _formatDate(story.releaseTime),
                        ),
                        _StoryMetaChip(
                          icon: story.isPremium
                              ? Icons.lock_rounded
                              : Icons.lock_open_rounded,
                          label: story.isPremium ? '付費' : '免費',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? AppColors.brand : const Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoryMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StoryMetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF6B7280)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _LiveSettingsStep extends StatelessWidget {
  final LiveHostState state;
  final VoidCallback onBack;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<LiveHostRoomType> onRoomTypeChanged;
  final ValueChanged<String> onCapacityChanged;
  final ValueChanged<bool> onNotifyFansChanged;
  final ValueChanged<String> onNotyetOwnedPriceChanged;
  final ValueChanged<String> onAlreadyOwnedPriceChanged;
  final VoidCallback onOpenRoom;

  const _LiveSettingsStep({
    required this.state,
    required this.onBack,
    required this.onTitleChanged,
    required this.onRoomTypeChanged,
    required this.onCapacityChanged,
    required this.onNotifyFansChanged,
    required this.onNotyetOwnedPriceChanged,
    required this.onAlreadyOwnedPriceChanged,
    required this.onOpenRoom,
  });

  @override
  Widget build(BuildContext context) {
    final story = state.selectedStory;

    return Column(
      key: const ValueKey('live-host-live-settings'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton.outlined(
              tooltip: '回到故事選擇',
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '設定直播',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '確認直播資訊後，下一步會進入主持畫面。',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (state.error != null) ...[
          _ErrorBanner(message: state.error!),
          const SizedBox(height: 16),
        ],
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 900;
              final storyCard = _SelectedStoryCard(story: story);
              final formCard = _LiveSettingsForm(
                state: state,
                onTitleChanged: onTitleChanged,
                onRoomTypeChanged: onRoomTypeChanged,
                onCapacityChanged: onCapacityChanged,
                onNotifyFansChanged: onNotifyFansChanged,
                onNotyetOwnedPriceChanged: onNotyetOwnedPriceChanged,
                onAlreadyOwnedPriceChanged: onAlreadyOwnedPriceChanged,
              );

              if (isNarrow) {
                return ListView(
                  children: [storyCard, const SizedBox(height: 16), formCard],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 360, child: storyCard),
                  const SizedBox(width: 16),
                  Expanded(child: formCard),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                state.canSubmitLiveSettings ? '設定完成，可以進入下一步' : '請完成必填欄位',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed:
                  state.canSubmitLiveSettings &&
                      state.status != LiveHostStatus.connecting
                  ? onOpenRoom
                  : null,
              icon: state.status == LiveHostStatus.connecting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.podcasts_rounded),
              label: Text(
                state.status == LiveHostStatus.connecting ? '連線中' : '開啟直播',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LiveRoomStep extends StatelessWidget {
  final LiveHostState state;
  final Future<void> Function() onCloseRoom;
  final VoidCallback onStartNewLive;
  final Future<void> Function() onPlayPodcast;
  final Future<void> Function() onPausePodcast;
  final ValueChanged<double> onSeekPodcast;

  const _LiveRoomStep({
    required this.state,
    required this.onCloseRoom,
    required this.onStartNewLive,
    required this.onPlayPodcast,
    required this.onPausePodcast,
    required this.onSeekPodcast,
  });

  @override
  Widget build(BuildContext context) {
    final story = state.selectedStory;

    return Column(
      key: const ValueKey('live-host-live-room'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.error != null) ...[
          _ErrorBanner(message: state.error!),
          const SizedBox(height: 16),
        ],
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 900;
              final roomInfoCard = _RoomInfoCard(
                state: state,
                onStartNewLive: onStartNewLive,
              );
              final playerCard = _PlayerControlCard(
                state: state,
                story: story,
                onCloseRoom: onCloseRoom,
                onPlay: onPlayPodcast,
                onPause: onPausePodcast,
                onSeek: onSeekPodcast,
              );
              final chatCard = _ChatPanel(state: state);
              final membersCard = _MembersPanel(state: state);

              if (isNarrow) {
                return ListView(
                  children: [
                    playerCard,
                    const SizedBox(height: 16),
                    roomInfoCard,
                    const SizedBox(height: 16),
                    chatCard,
                    const SizedBox(height: 16),
                    membersCard,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(height: 250, child: playerCard),
                        const SizedBox(height: 16),
                        Expanded(child: chatCard),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 360,
                    child: Column(
                      children: [
                        roomInfoCard,
                        const SizedBox(height: 16),
                        Expanded(child: membersCard),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PlayerControlCard extends StatelessWidget {
  final LiveHostState state;
  final StoryItem? story;
  final Future<void> Function() onCloseRoom;
  final Future<void> Function() onPlay;
  final Future<void> Function() onPause;
  final ValueChanged<double> onSeek;

  const _PlayerControlCard({
    required this.state,
    required this.story,
    required this.onCloseRoom,
    required this.onPlay,
    required this.onPause,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final maxMs = state.duration.inMilliseconds <= 0
        ? 1.0
        : state.duration.inMilliseconds.toDouble();
    final positionMs = state.currentPosition.inMilliseconds
        .clamp(0, maxMs.round())
        .toDouble();
    final isLive = state.status == LiveHostStatus.live;
    final isPlaying = state.playerStatus == LiveHostPlayerStatus.playing;
    final isPending =
        state.pendingPlayerAction != LiveHostPlayerPendingAction.none;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 700;
            final storyPane = _StoryControlPreview(story: story);
            final controls = _PlayerControls(
              state: state,
              positionMs: positionMs,
              maxMs: maxMs,
              isLive: isLive,
              isPlaying: isPlaying,
              isPending: isPending,
              onCloseRoom: onCloseRoom,
              onPlay: onPlay,
              onPause: onPause,
              onSeek: onSeek,
            );

            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [storyPane, const SizedBox(height: 16), controls],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 210, child: storyPane),
                const SizedBox(width: 22),
                Expanded(child: controls),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StoryControlPreview extends StatelessWidget {
  final StoryItem? story;

  const _StoryControlPreview({required this.story});

  @override
  Widget build(BuildContext context) {
    final selectedStory = story;
    final imageUrl = _storyImageUrl(selectedStory);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox.square(
          dimension: 150,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl.isEmpty
                ? Container(
                    color: const Color(0xFFF3F4F6),
                    child: const Icon(Icons.auto_stories_rounded),
                  )
                : Image.network(imageUrl, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          selectedStory?.storyName ?? '尚未選擇故事',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        if (selectedStory != null) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StoryMetaChip(
                icon: Icons.folder_rounded,
                label: selectedStory.channelName.isEmpty
                    ? '未分類頻道'
                    : selectedStory.channelName,
              ),
              _StoryMetaChip(
                icon: selectedStory.isPremium
                    ? Icons.lock_rounded
                    : Icons.lock_open_rounded,
                label: selectedStory.isPremium ? '付費' : '免費',
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _PlayerControls extends StatelessWidget {
  final LiveHostState state;
  final double positionMs;
  final double maxMs;
  final bool isLive;
  final bool isPlaying;
  final bool isPending;
  final Future<void> Function() onCloseRoom;
  final Future<void> Function() onPlay;
  final Future<void> Function() onPause;
  final ValueChanged<double> onSeek;

  const _PlayerControls({
    required this.state,
    required this.positionMs,
    required this.maxMs,
    required this.isLive,
    required this.isPlaying,
    required this.isPending,
    required this.onCloseRoom,
    required this.onPlay,
    required this.onPause,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _StatusBadge(status: state.status),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '播放器控制',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            OutlinedButton.icon(
              onPressed: state.status == LiveHostStatus.live
                  ? () => _confirmCloseRoom(context, onCloseRoom)
                  : null,
              icon: const Icon(Icons.stop_circle_rounded),
              label: const Text('關閉直播'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            FilledButton.icon(
              onPressed: !isLive || isPending
                  ? null
                  : isPlaying
                  ? onPause
                  : onPlay,
              icon: isPending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
              label: Text(isPending ? '同步中' : (isPlaying ? '暫停' : '播放')),
            ),
            const SizedBox(width: 12),
            Text(
              '${_formatDuration(state.currentPosition)} / ${_formatDuration(state.duration)}',
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.brand,
            inactiveTrackColor: const Color(0xFFE5E7EB),
            disabledActiveTrackColor: const Color(0xFFFBBF24),
            disabledInactiveTrackColor: const Color(0xFFE5E7EB),
            thumbColor: AppColors.brand,
            disabledThumbColor: const Color(0xFFFBBF24),
            overlayColor: AppColors.brand.withValues(alpha: 0.14),
            trackHeight: 6,
          ),
          child: Slider(
            value: positionMs,
            min: 0,
            max: maxMs,
            onChanged: isLive && !isPending ? onSeek : null,
          ),
        ),
        const Spacer(),
        const Text(
          '播放、暫停與拖曳進度會同步送給直播間聽眾。',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

Future<void> _confirmCloseRoom(
  BuildContext context,
  Future<void> Function() onCloseRoom,
) async {
  final shouldClose = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('關閉直播'),
        content: const Text('確定要關閉目前直播房間嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('關閉直播'),
          ),
        ],
      );
    },
  );
  if (shouldClose == true) {
    await onCloseRoom();
  }
}

class _ChatPanel extends StatelessWidget {
  final LiveHostState state;

  const _ChatPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '聊天室',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: state.chatMessages.isEmpty
                ? const Center(
                    child: Text(
                      '目前沒有聊天訊息',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.chatMessages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final message = state.chatMessages[index];
                      return _ChatMessageTile(message: message);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessageTile extends StatelessWidget {
  final LiveHostChatMessage message;

  const _ChatMessageTile({required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: message.avatarUrl.isEmpty
              ? null
              : NetworkImage(message.avatarUrl),
          child: message.avatarUrl.isEmpty
              ? const Icon(Icons.person_rounded, size: 18)
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.nickname.isEmpty ? message.userId : message.nickname,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 3),
              Text(message.content),
            ],
          ),
        ),
      ],
    );
  }
}

class _MembersPanel extends StatelessWidget {
  final LiveHostState state;

  const _MembersPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '觀眾 / 上麥',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  '${state.members.length} 人',
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: state.members.isEmpty
                ? const Center(
                    child: Text(
                      '目前沒有觀眾',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: state.members.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final member = state.members[index];
                      return _MemberTile(
                        member: member,
                        isOnMic: state.onMicUserIds.contains(member.userId),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final LiveHostMember member;
  final bool isOnMic;

  const _MemberTile({required this.member, required this.isOnMic});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: CircleAvatar(
        backgroundImage: member.avatarUrl.isEmpty
            ? null
            : NetworkImage(member.avatarUrl),
        child: member.avatarUrl.isEmpty
            ? const Icon(Icons.person_rounded)
            : null,
      ),
      title: Text(
        member.nickname.isEmpty ? member.userId : member.nickname,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        isOnMic
            ? '上麥中'
            : member.isHandsUp
            ? '舉手中'
            : '觀眾',
      ),
      trailing: Icon(
        isOnMic
            ? Icons.mic_rounded
            : member.isHandsUp
            ? Icons.front_hand_rounded
            : Icons.person_rounded,
        color: isOnMic || member.isHandsUp
            ? AppColors.brand
            : const Color(0xFF9CA3AF),
      ),
    );
  }
}

class _RoomInfoCard extends StatelessWidget {
  final LiveHostState state;
  final VoidCallback onStartNewLive;

  const _RoomInfoCard({required this.state, required this.onStartNewLive});

  @override
  Widget build(BuildContext context) {
    final shareUrl = state.shareUrl;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: _RoomInfoSection(
          state: state,
          onStartNewLive: onStartNewLive,
          shareUrl: shareUrl,
          onCopyShareUrl: shareUrl.isEmpty
              ? null
              : () => _copyShareUrl(context, shareUrl),
        ),
      ),
    );
  }
}

class _RoomInfoSection extends StatelessWidget {
  final LiveHostState state;
  final VoidCallback onStartNewLive;
  final String shareUrl;
  final VoidCallback? onCopyShareUrl;

  const _RoomInfoSection({
    required this.state,
    required this.onStartNewLive,
    required this.shareUrl,
    required this.onCopyShareUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.status == LiveHostStatus.closed) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '直播已關閉，可以重新開始新的直播流程。',
                    style: TextStyle(color: Color(0xFF4B5563)),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: onStartNewLive,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('重新開始直播'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],
        _InfoRow(label: '房間標題', value: state.roomTitle),
        const SizedBox(height: 10),
        _InfoRow(label: 'Room ID', value: state.roomId),
        const SizedBox(height: 10),
        _InfoRow(
          label: '直播模式',
          value: state.roomType == LiveHostRoomType.listenOnly
              ? '陪聽直播'
              : '互動直播',
        ),
        const SizedBox(height: 18),
        _ShareLinkBox(shareUrl: shareUrl, onCopy: onCopyShareUrl),
      ],
    );
  }
}

Future<void> _copyShareUrl(BuildContext context, String shareUrl) async {
  await Clipboard.setData(ClipboardData(text: shareUrl));
  if (!context.mounted) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('已複製分享連結')));
}

class _ShareLinkBox extends StatelessWidget {
  final String shareUrl;
  final VoidCallback? onCopy;

  const _ShareLinkBox({required this.shareUrl, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    final displayUrl = shareUrl.isEmpty ? '-' : shareUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '分享連結',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.only(left: 14, right: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            border: Border.all(color: const Color(0xFFD1D5DB)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.link_rounded,
                size: 20,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Tooltip(
                  message: displayUrl,
                  waitDuration: const Duration(milliseconds: 500),
                  child: Text(
                    displayUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              IconButton(
                tooltip: '複製分享連結',
                onPressed: onCopy,
                icon: const Icon(Icons.copy_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final LiveHostStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      LiveHostStatus.idle => '未開播',
      LiveHostStatus.connecting => '連線中',
      LiveHostStatus.live => '已開播',
      LiveHostStatus.closed => '已關閉',
      LiveHostStatus.error => '錯誤',
    };
    final color = switch (status) {
      LiveHostStatus.live => const Color(0xFF16A34A),
      LiveHostStatus.error => const Color(0xFFDC2626),
      LiveHostStatus.connecting => AppColors.brand,
      LiveHostStatus.closed => const Color(0xFF6B7280),
      LiveHostStatus.idle => const Color(0xFF6B7280),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(label, style: const TextStyle(color: Color(0xFF6B7280))),
        ),
        Expanded(
          child: SelectableText(
            value.isEmpty ? '-' : value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

String _storyImageUrl(StoryItem? story) {
  if (story == null) return '';
  if (story.storyImageUrl.isNotEmpty) return story.storyImageUrl;
  return story.storyImageUrls.isNotEmpty ? story.storyImageUrls.first : '';
}

class _SelectedStoryCard extends StatelessWidget {
  final StoryItem? story;

  const _SelectedStoryCard({required this.story});

  @override
  Widget build(BuildContext context) {
    final selectedStory = story;
    final imageUrl = _storyImageUrl(selectedStory);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: selectedStory == null
            ? const Text('尚未選擇故事', style: TextStyle(color: Color(0xFF6B7280)))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: imageUrl.isEmpty
                          ? Container(
                              color: const Color(0xFFF3F4F6),
                              child: const Icon(Icons.auto_stories_rounded),
                            )
                          : Image.network(imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    selectedStory.storyName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StoryMetaChip(
                        icon: Icons.folder_rounded,
                        label: selectedStory.channelName.isEmpty
                            ? '未分類頻道'
                            : selectedStory.channelName,
                      ),
                      _StoryMetaChip(
                        icon: selectedStory.isPremium
                            ? Icons.lock_rounded
                            : Icons.lock_open_rounded,
                        label: selectedStory.isPremium ? '付費' : '免費',
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class _LiveSettingsForm extends StatefulWidget {
  final LiveHostState state;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<LiveHostRoomType> onRoomTypeChanged;
  final ValueChanged<String> onCapacityChanged;
  final ValueChanged<bool> onNotifyFansChanged;
  final ValueChanged<String> onNotyetOwnedPriceChanged;
  final ValueChanged<String> onAlreadyOwnedPriceChanged;

  const _LiveSettingsForm({
    required this.state,
    required this.onTitleChanged,
    required this.onRoomTypeChanged,
    required this.onCapacityChanged,
    required this.onNotifyFansChanged,
    required this.onNotyetOwnedPriceChanged,
    required this.onAlreadyOwnedPriceChanged,
  });

  @override
  State<_LiveSettingsForm> createState() => _LiveSettingsFormState();
}

class _LiveSettingsFormState extends State<_LiveSettingsForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _capacityController;
  late final TextEditingController _notyetOwnedPriceController;
  late final TextEditingController _alreadyOwnedPriceController;
  final _titleFocusNode = FocusNode();
  final _capacityFocusNode = FocusNode();
  final _notyetOwnedPriceFocusNode = FocusNode();
  final _alreadyOwnedPriceFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.state.roomTitle);
    _capacityController = TextEditingController(
      text: widget.state.capacity == 0 ? '' : widget.state.capacity.toString(),
    );
    _notyetOwnedPriceController = TextEditingController(
      text: widget.state.notyetOwnedStoryPrice.toString(),
    );
    _alreadyOwnedPriceController = TextEditingController(
      text: widget.state.alreadyOwnedStoryPrice.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant _LiveSettingsForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllerText(
      controller: _titleController,
      focusNode: _titleFocusNode,
      value: widget.state.roomTitle,
    );
    _syncControllerText(
      controller: _capacityController,
      focusNode: _capacityFocusNode,
      value: widget.state.capacity == 0 ? '' : widget.state.capacity.toString(),
    );
    _syncControllerText(
      controller: _notyetOwnedPriceController,
      focusNode: _notyetOwnedPriceFocusNode,
      value: widget.state.notyetOwnedStoryPrice.toString(),
    );
    _syncControllerText(
      controller: _alreadyOwnedPriceController,
      focusNode: _alreadyOwnedPriceFocusNode,
      value: widget.state.alreadyOwnedStoryPrice.toString(),
    );
  }

  void _syncControllerText({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String value,
  }) {
    if (focusNode.hasFocus || controller.text == value) return;
    controller.text = value;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _capacityController.dispose();
    _notyetOwnedPriceController.dispose();
    _alreadyOwnedPriceController.dispose();
    _titleFocusNode.dispose();
    _capacityFocusNode.dispose();
    _notyetOwnedPriceFocusNode.dispose();
    _alreadyOwnedPriceFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final numberFormatters = [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(6),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              key: ValueKey('room-title-${state.selectedStory?.storyId ?? ''}'),
              controller: _titleController,
              focusNode: _titleFocusNode,
              onChanged: widget.onTitleChanged,
              decoration: InputDecoration(
                labelText: '房間標題',
                hintText: state.selectedStory?.storyName ?? '輸入直播房間標題',
                prefixIcon: const Icon(Icons.title_rounded),
                errorText: state.roomTitle.trim().isEmpty ? '請輸入房間標題' : null,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              '直播模式',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SegmentedButton<LiveHostRoomType>(
              segments: const [
                ButtonSegment(
                  value: LiveHostRoomType.listenOnly,
                  icon: Icon(Icons.headphones_rounded),
                  label: Text('陪聽直播'),
                ),
                ButtonSegment(
                  value: LiveHostRoomType.interactive,
                  icon: Icon(Icons.record_voice_over_rounded),
                  label: Text('互動直播'),
                ),
              ],
              selected: {state.roomType},
              onSelectionChanged: (values) =>
                  widget.onRoomTypeChanged(values.first),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _capacityController,
              focusNode: _capacityFocusNode,
              enabled: state.roomType == LiveHostRoomType.interactive,
              onChanged: widget.onCapacityChanged,
              keyboardType: TextInputType.number,
              inputFormatters: numberFormatters,
              decoration: InputDecoration(
                labelText: '人數上限',
                prefixIcon: const Icon(Icons.groups_rounded),
                helperText: state.roomType == LiveHostRoomType.listenOnly
                    ? '陪聽直播固定 100 人'
                    : '互動直播最多 $liveHostInteractiveCapacityLimit 人',
                errorText: _capacityErrorText(state),
              ),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: state.notifyFans,
              onChanged: widget.onNotifyFansChanged,
              title: const Text('通知粉絲'),
              subtitle: const Text('開播時通知追蹤者'),
              secondary: const Icon(Icons.notifications_active_rounded),
            ),
            const Divider(height: 30),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _notyetOwnedPriceController,
                    focusNode: _notyetOwnedPriceFocusNode,
                    onChanged: widget.onNotyetOwnedPriceChanged,
                    keyboardType: TextInputType.number,
                    inputFormatters: numberFormatters,
                    decoration: InputDecoration(
                      labelText: '未購買價格',
                      prefixIcon: const Icon(Icons.lock_rounded),
                      suffixText: 'PodCoin',
                      errorText: state.notyetOwnedStoryPrice < 0
                          ? '價格不可小於 0'
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextFormField(
                    controller: _alreadyOwnedPriceController,
                    focusNode: _alreadyOwnedPriceFocusNode,
                    onChanged: widget.onAlreadyOwnedPriceChanged,
                    keyboardType: TextInputType.number,
                    inputFormatters: numberFormatters,
                    decoration: InputDecoration(
                      labelText: '已購買價格',
                      prefixIcon: const Icon(Icons.verified_rounded),
                      suffixText: 'PodCoin',
                      errorText: state.alreadyOwnedStoryPrice < 0
                          ? '價格不可小於 0'
                          : null,
                    ),
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

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Text(message, style: const TextStyle(color: Color(0xFFBE123C))),
    );
  }
}

class _EmptyStories extends StatelessWidget {
  const _EmptyStories();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('目前沒有可選擇的故事', style: TextStyle(color: Color(0xFF6B7280))),
    );
  }
}

class _NoSearchResult extends StatelessWidget {
  const _NoSearchResult();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('找不到符合搜尋條件的故事', style: TextStyle(color: Color(0xFF6B7280))),
    );
  }
}

String _formatDate(DateTime date) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${date.year}/${twoDigits(date.month)}/${twoDigits(date.day)}';
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  final hours = duration.inHours;
  if (hours > 0) {
    return '$hours:$minutes:$seconds';
  }
  return '$minutes:$seconds';
}

String? _capacityErrorText(LiveHostState state) {
  if (state.capacity <= 0) return '人數上限需大於 0';
  if (state.roomType == LiveHostRoomType.interactive &&
      state.capacity > liveHostInteractiveCapacityLimit) {
    return '互動直播最多 $liveHostInteractiveCapacityLimit 人';
  }
  return null;
}
