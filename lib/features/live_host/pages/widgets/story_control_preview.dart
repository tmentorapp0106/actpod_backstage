part of '../live_host_page.dart';

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
