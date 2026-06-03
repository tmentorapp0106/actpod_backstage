import 'dart:typed_data';
import 'package:actpod_studio/features/create_story/controllers/single_create_controller.dart';
import 'package:actpod_studio/features/create_story/models/channel_model.dart';
import 'package:actpod_studio/features/create_story/models/space_model.dart';
import 'package:actpod_studio/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DetailStep extends ConsumerWidget {
  const DetailStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(singleCreateControllerProvider); // 讀取狀態

    // 這些欄位名稱請對應你的 CreateState
    final String title = state.title ?? '';
    final String description = state.description ?? '';
    final List<Space> spaces = state.spaces;
    final String? selectedSpace = state.selectedSpace;
    final List<Channel> channels = state.channels;
    final String? selectedChannel = state.selectedChannel;
    final List<Uint8List>? coversBytes = state.imageFilesBytes;

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '編輯故事',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),

            // 標題
            Text('故事標題', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 6),
            TextFormField(
              initialValue: title,
              onChanged: (v) =>
                  ref.read(singleCreateControllerProvider.notifier).setTitle(v),
              decoration: const InputDecoration(
                hintText: 'EP 1 | title',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),

            // 敘述
            Text('故事敘述', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 6),
            TextFormField(
              initialValue: description,
              onChanged: (v) => ref
                  .read(singleCreateControllerProvider.notifier)
                  .setDescription(v),
              decoration: const InputDecoration(
                hintText: '輸入敘述（800 字以內）',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              maxLength: 800,
            ),
            const SizedBox(height: 8),

            // Space
            Text('故事空間', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedSpace,
              items: spaces
                  .map(
                    (s) => DropdownMenuItem<String>(
                      value: s.name,
                      child: Text(s.name),
                    ),
                  )
                  .toList(),
              onChanged: (v) =>
                  ref.read(singleCreateControllerProvider.notifier).setSpace(v),
              decoration: const InputDecoration(
                hintText: 'Select Your Space',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),

            // Channel
            Text('頻道選擇', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedChannel,
              items: channels
                  .map(
                    (c) => DropdownMenuItem<String>(
                      value: c.channelName,
                      child: Text(c.channelName),
                    ),
                  )
                  .toList(),
              onChanged: (v) => ref
                  .read(singleCreateControllerProvider.notifier)
                  .setChannel(v),
              decoration: const InputDecoration(
                hintText: "Select Your channel",
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),

            // 封面上傳
            Text('封面圖片', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilledButton.icon(
                  onPressed: () => ref
                      .read(singleCreateControllerProvider.notifier)
                      .pickCover(),
                  icon: const Icon(Icons.upload_rounded),
                  label: const Text('上傳圖片'),
                ),
                const SizedBox(height: 8),
                Text(
                  '建議 1:1（例如 800×800）',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 500,
              height: 130,
              child: ReorderableListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: coversBytes?.length ?? 0,
                itemBuilder: (context, index) {
                  return _CoverPicker(
                    key: ValueKey("cover-$index"),
                    index: index,
                    bytes: coversBytes?[index],
                    onRemove: coversBytes == null
                        ? null
                        : () => ref
                              .read(singleCreateControllerProvider.notifier)
                              .clearCover(),
                  );
                },
                onReorder: (int oldIndex, int newIndex) {
                  ref
                      .read(singleCreateControllerProvider.notifier)
                      .reorderCovers(oldIndex, newIndex);
                },
              ),
            ),

            const SizedBox(height: 24),

            // // 底部操作列
            // Row(
            //   children: [
            //     OutlinedButton(
            //       onPressed: () => ref.read(singleCreateControllerProvider.notifier).back(),
            //       child: const Text('上一步'),
            //     ),
            //     const Spacer(),
            //     FilledButton(
            //       onPressed: () => ref.read(singleCreateControllerProvider.notifier).next(),
            //       child: const Text('下一步'),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}

class _CoverPicker extends StatelessWidget {
  final int index;
  final Uint8List? bytes;
  final VoidCallback? onRemove;

  const _CoverPicker({
    super.key,
    required this.index,
    required this.bytes,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: theme.colorScheme.outlineVariant),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: ShapeDecoration(shape: border),
              clipBehavior: Clip.antiAlias,
              child: bytes == null
                  ? Icon(Icons.image_outlined, size: 32, color: theme.hintColor)
                  : Image.memory(bytes!, fit: BoxFit.cover),
            ),
          ],
        ),
        SizedBox(width: 8),
      ],
    );
  }
}
