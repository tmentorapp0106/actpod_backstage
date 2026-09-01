part of '../live_host_page.dart';

class _StorySelectionStep extends StatelessWidget {
  final LiveHostViewState state;
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
