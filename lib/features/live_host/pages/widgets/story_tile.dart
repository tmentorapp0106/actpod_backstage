part of '../live_host_page.dart';

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
