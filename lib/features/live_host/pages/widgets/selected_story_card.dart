part of '../live_host_page.dart';

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
