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
                        '新增多個故事，並為每個故事選擇 Space 與 Channel。',
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
                  ],
                ),
              ),
            ),
          )
        else
          ...state.stories.map(
            (story) => Padding(
              key: ValueKey(story.id),
              padding: const EdgeInsets.only(bottom: 16),
              child: _PackageStoryEditor(story: story),
            ),
          ),
      ],
    );
  }
}

class _PackageStoryEditor extends ConsumerStatefulWidget {
  final PackageStoryDraft story;

  const _PackageStoryEditor({required this.story});

  @override
  ConsumerState<_PackageStoryEditor> createState() =>
      _PackageStoryEditorState();
}

class _PackageStoryEditorState extends ConsumerState<_PackageStoryEditor> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _packageNoteController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.story.title);
    _descriptionController = TextEditingController(
      text: widget.story.description,
    );
    _packageNoteController = TextEditingController(
      text: widget.story.packageNote,
    );
  }

  @override
  void didUpdateWidget(covariant _PackageStoryEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.story.id != widget.story.id) {
      _titleController.text = widget.story.title;
      _descriptionController.text = widget.story.description;
      _packageNoteController.text = widget.story.packageNote;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _packageNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(packageCreateControllerProvider);
    final ctrl = ref.read(packageCreateControllerProvider.notifier);
    final story = widget.story;
    final isPickingAudio = state.pickingAudioStoryId == story.id;
    final isPickingCover = state.pickingCoverStoryId == story.id;
    final canPickAudio = state.pickingAudioStoryId == null;
    final canPickCover = state.pickingCoverStoryId == null;

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
                Chip(
                  label: Text(story.isExisting ? '原有 Story' : '新增 Story'),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: '刪除 Story',
                  onPressed: () => ctrl.removeStory(story.id),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _titleController,
              onChanged: (value) => ctrl.setStoryTitle(story.id, value),
              decoration: const InputDecoration(
                labelText: '故事標題',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
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
            TextFormField(
              controller: _packageNoteController,
              onChanged: (value) => ctrl.setStoryPackageNote(story.id, value),
              maxLines: 3,
              maxLength: 800,
              decoration: const InputDecoration(
                labelText: 'Package Note',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final spaceField = _StorySpaceField(
                  state: state,
                  story: story,
                  ctrl: ctrl,
                  enabled: !story.isExisting,
                );
                final channelField = _StoryChannelField(
                  state: state,
                  story: story,
                  ctrl: ctrl,
                  enabled: !story.isExisting,
                );
                final podcoinsField = _StoryNumberField(
                  key: ValueKey('story_podcoins_${story.id}'),
                  label: 'Podcoins',
                  value: story.podcoins,
                  enabled: !story.isExisting,
                  onChanged: (value) => ctrl.setStoryPodcoins(
                    story.id,
                    _parseNonNegativeInt(value),
                  ),
                );
                final twdField = _StoryNumberField(
                  key: ValueKey('story_twd_${story.id}'),
                  label: 'TWD',
                  value: story.twd,
                  enabled: !story.isExisting,
                  onChanged: (value) =>
                      ctrl.setStoryTwd(story.id, _parseNonNegativeInt(value)),
                );

                if (constraints.maxWidth >= 720) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: spaceField),
                          const SizedBox(width: 16),
                          Expanded(child: channelField),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: podcoinsField),
                          const SizedBox(width: 16),
                          Expanded(child: twdField),
                        ],
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    spaceField,
                    const SizedBox(height: 12),
                    channelField,
                    const SizedBox(height: 12),
                    podcoinsField,
                    const SizedBox(height: 12),
                    twdField,
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: canPickAudio
                      ? () => ctrl.pickStoryAudio(story.id)
                      : null,
                  icon: const Icon(Icons.audio_file_rounded),
                  label: Text(story.audio == null ? '上傳音檔（選填）' : '更換音檔'),
                ),
                if (isPickingAudio) const _InlineLoading(),
                if (story.isExisting &&
                    story.originalContentUrl.isNotEmpty &&
                    story.contentUrl.isEmpty &&
                    story.audio == null)
                  const _InfoChip(
                    icon: Icons.remove_circle_outline_rounded,
                    label: '已移除音檔',
                  )
                else if (story.isExisting && story.contentUrl.isNotEmpty)
                  _InfoChip(
                    icon: story.hasNewAudio
                        ? Icons.change_circle_rounded
                        : Icons.cloud_done_rounded,
                    label: story.hasNewAudio ? '已更換音檔' : '使用既有音檔',
                  ),
                if (story.audio != null)
                  _InfoChip(
                    icon: Icons.check_circle_rounded,
                    label: story.audio!.duration == Duration.zero
                        ? story.audio!.fileName
                        : '${story.audio!.fileName} ・ ${_fmtDuration(story.audio!.duration)}',
                  ),
                if (story.audio != null ||
                    (story.isExisting && story.contentUrl.isNotEmpty))
                  InkWell(
                    onTap: () => ctrl.clearStoryAudio(story.id),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade500,
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.close_rounded, size: 12),
                      ),
                    ),
                  ),
                OutlinedButton.icon(
                  onPressed: canPickCover
                      ? () => ctrl.pickStoryCover(story.id)
                      : null,
                  icon: const Icon(Icons.image_rounded),
                  label: Text(story.imageFilesBytes.isEmpty ? '上傳圖片' : '更換圖片'),
                ),
                if (isPickingCover) const _InlineLoading(),
                if (story.imageFilesBytes.isNotEmpty)
                  _InfoChip(
                    icon: Icons.check_circle_rounded,
                    label: '${story.imageFilesBytes.length} 張封面',
                  )
                else if (story.remoteImageUrls.isNotEmpty)
                  _InfoChip(
                    icon: Icons.cloud_done_rounded,
                    label: '${story.remoteImageUrls.length} 張既有封面',
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
            ] else if (story.remoteImageUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: story.remoteImageUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return _RemoteCoverThumb(url: story.remoteImageUrls[index]);
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

class _StorySpaceField extends StatelessWidget {
  final PackageCreateState state;
  final PackageStoryDraft story;
  final PackageCreateController ctrl;
  final bool enabled;

  const _StorySpaceField({
    required this.state,
    required this.story,
    required this.ctrl,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('story_space_${story.id}_${story.selectedSpace ?? ''}'),
      initialValue: story.selectedSpace,
      items: state.spaces
          .map(
            (space) => DropdownMenuItem<String>(
              value: space.name,
              child: Text(space.name),
            ),
          )
          .toList(),
      onChanged: enabled
          ? (value) => ctrl.setStorySpace(story.id, value)
          : null,
      decoration: const InputDecoration(
        labelText: 'Story Space',
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}

class _StoryChannelField extends StatelessWidget {
  final PackageCreateState state;
  final PackageStoryDraft story;
  final PackageCreateController ctrl;
  final bool enabled;

  const _StoryChannelField({
    required this.state,
    required this.story,
    required this.ctrl,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('story_channel_${story.id}_${story.selectedChannel ?? ''}'),
      initialValue: story.selectedChannel,
      items: state.channels
          .map(
            (channel) => DropdownMenuItem<String>(
              value: channel.channelName,
              child: Text(channel.channelName),
            ),
          )
          .toList(),
      onChanged: enabled
          ? (value) => ctrl.setStoryChannel(story.id, value)
          : null,
      decoration: const InputDecoration(
        labelText: 'Story Channel',
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}

class _StoryNumberField extends StatelessWidget {
  final String label;
  final int value;
  final bool enabled;
  final ValueChanged<String> onChanged;

  const _StoryNumberField({
    super.key,
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value.toString(),
      enabled: enabled,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}

int _parseNonNegativeInt(String value) {
  final parsed = int.tryParse(value.trim()) ?? 0;
  return parsed < 0 ? 0 : parsed;
}

class _InlineLoading extends StatelessWidget {
  const _InlineLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
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

class _RemoteCoverThumb extends StatelessWidget {
  final String url;

  const _RemoteCoverThumb({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: 92,
        height: 92,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 92,
          height: 92,
          color: Colors.grey.shade100,
          child: const Icon(Icons.broken_image_rounded),
        ),
      ),
    );
  }
}
