import 'dart:typed_data';

import 'package:actpod_studio/features/create_story/controllers/package_create_controller.dart';
import 'package:actpod_studio/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PackageStoriesStep extends ConsumerWidget {
  const PackageStoriesStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(packageCreateControllerProvider);
    final ctrl = ref.read(packageCreateControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '套裝故事',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '新增多個故事，所有故事都會使用前一步選好的 Space 與 Channel。',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: ctrl.addStory,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('新增 Story'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (state.stories.isEmpty)
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.library_add_rounded, size: 36),
                    const SizedBox(height: 10),
                    const Text('尚未新增故事'),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: ctrl.addStory,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('新增第一個 Story'),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...state.stories.map(
            (story) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _PackageStoryEditor(story: story),
            ),
          ),
      ],
    );
  }
}

class _PackageStoryEditor extends ConsumerWidget {
  final PackageStoryDraft story;

  const _PackageStoryEditor({required this.story});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.read(packageCreateControllerProvider.notifier);

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    story.title.trim().isEmpty ? '未命名 Story' : story.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: '刪除 Story',
                  onPressed: () => ctrl.removeStory(story.id),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              initialValue: story.title,
              onChanged: (value) => ctrl.setStoryTitle(story.id, value),
              decoration: const InputDecoration(
                labelText: '故事標題',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: story.description,
              onChanged: (value) => ctrl.setStoryDescription(story.id, value),
              maxLines: 4,
              maxLength: 800,
              decoration: const InputDecoration(
                labelText: '故事描述',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => ctrl.pickStoryAudio(story.id),
                  icon: const Icon(Icons.audio_file_rounded),
                  label: Text(story.audio == null ? '上傳音檔' : '更換音檔'),
                ),
                if (story.audio != null)
                  _InfoChip(
                    icon: Icons.check_circle_rounded,
                    label:
                        '${story.audio!.fileName} ・ ${_fmtDuration(story.audio!.duration)}',
                  ),
                OutlinedButton.icon(
                  onPressed: () => ctrl.pickStoryCover(story.id),
                  icon: const Icon(Icons.image_rounded),
                  label: Text(story.imageFilesBytes.isEmpty ? '上傳封面' : '更換封面'),
                ),
                if (story.imageFilesBytes.isNotEmpty)
                  _InfoChip(
                    icon: Icons.check_circle_rounded,
                    label: '${story.imageFilesBytes.length} 張封面',
                  ),
              ],
            ),
            if (story.imageFilesBytes.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: story.imageFilesBytes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return _CoverThumb(bytes: story.imageFilesBytes[index]);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _fmtDuration(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label, overflow: TextOverflow.ellipsis),
    );
  }
}

class _CoverThumb extends StatelessWidget {
  final Uint8List bytes;

  const _CoverThumb({required this.bytes});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.memory(bytes, width: 92, height: 92, fit: BoxFit.cover),
    );
  }
}
