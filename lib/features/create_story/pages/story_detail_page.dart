import 'dart:typed_data';
import 'package:actpod_studio/features/create_story/controllers/create_controller.dart';
import 'package:actpod_studio/features/create_story/models/channel_model.dart';
import 'package:actpod_studio/features/create_story/models/space_model.dart';
import 'package:actpod_studio/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DetailStep extends ConsumerWidget {
  const DetailStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(createControllerProvider); // 讀取狀態
    final ctrl = ref.read(createControllerProvider.notifier); // 呼叫方法

    // 這些欄位名稱請對應你的 CreateState
    final String title = ctrl.state.title ?? '';
    final String description = ctrl.state.description ?? '';
    final List<Space> spaces = ctrl.state.spaces ?? const [];
    final String? selectedSpace = ctrl.state.selectedSpace;
    final List<Channel> channels = ctrl.state.channels ?? const [];
    final String? selectedChannel = ctrl.state.selectedChannel;
    final Uint8List? coverBytes = ctrl.state.imageFileBytes;

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
                  ref.read(createControllerProvider.notifier).setTitle(v),
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
              onChanged: (v) =>
                  ref.read(createControllerProvider.notifier).setDescription(v),
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
                  ref.read(createControllerProvider.notifier).setSpace(v),
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
              onChanged: (v) =>
                  ref.read(createControllerProvider.notifier).setChannel(v),
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
            _CoverPicker(
              bytes: coverBytes,
              onPick: () =>
                  ref.read(createControllerProvider.notifier).pickCover(),
              onRemove: coverBytes == null
                  ? null
                  : () => ref
                        .read(createControllerProvider.notifier)
                        .clearCover(),
            ),

            const SizedBox(height: 24),

            // // 底部操作列
            // Row(
            //   children: [
            //     OutlinedButton(
            //       onPressed: () => ref.read(createControllerProvider.notifier).back(),
            //       child: const Text('上一步'),
            //     ),
            //     const Spacer(),
            //     FilledButton(
            //       onPressed: () => ref.read(createControllerProvider.notifier).next(),
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
  final Uint8List? bytes;
  final VoidCallback onPick;
  final VoidCallback? onRemove;

  const _CoverPicker({
    required this.bytes,
    required this.onPick,
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
      children: [
        // 預覽框或占位
        Container(
          width: 96,
          height: 96,
          decoration: ShapeDecoration(shape: border),
          clipBehavior: Clip.antiAlias,
          child: bytes == null
              ? Icon(Icons.image_outlined, size: 32, color: theme.hintColor)
              : Image.memory(bytes!, fit: BoxFit.cover),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilledButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.upload_rounded),
              label: const Text('上傳圖片'),
            ),
            const SizedBox(height: 8),
            // if (onRemove != null)
            //   TextButton.icon(
            //     onPressed: onRemove,
            //     icon: const Icon(Icons.delete_outline),
            //     label: const Text('移除'),
            //   ),
            Text(
              '建議 1:1（例如 800×800）',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
