import 'dart:math' as math;
import 'package:actpod_studio/app/theme/theme.dart';
import 'package:actpod_studio/features/create_story/controllers/create_controller.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UploadArea extends ConsumerWidget {
  final List<String> allowedExtensions;
  final String hint;
  final bool allowMultiple;
  final ValueChanged<List<PlatformFile>> onChanged;

  const UploadArea({
    super.key,
    required this.allowedExtensions,
    required this.onChanged,
    this.hint = '點擊上傳選擇檔案',
    this.allowMultiple = false,
  });

  Future<void> _pick(WidgetRef ref) async {
    ref.read(createControllerProvider.notifier).setLoadingAudio(true);
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: kIsWeb, // web 取 bytes
    );
    ref.read(createControllerProvider.notifier).setLoadingAudio(false);
    if (result != null && result.files.isNotEmpty) {
      onChanged(result.files);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DottedBorder(
      color: Colors.grey.shade400,
      dashPattern: const [6, 6],
      strokeWidth: 1.4,
      borderType: BorderType.RRect,
      radius: const Radius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {_pick(ref);},
        child: Container(
          constraints: const BoxConstraints(minHeight: 280),
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.color.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_upload_rounded, size: 32),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {_pick(ref);},
                icon: Icon(Icons.upload_rounded ,color: context.color.brand),
                label: const Text('上傳音檔'),
              ),
              const SizedBox(height: 8),
              Text(hint, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Text('支援：${allowedExtensions.join(', ').toUpperCase()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black38,
                      )),
            ],
          ),
        ),
      ),
    );
  }
}

