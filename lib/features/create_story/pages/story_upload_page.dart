import 'dart:io';

import 'package:actpod_studio/features/api/api.dart';
import 'package:actpod_studio/features/api/upload_system_api.dart';
import 'package:actpod_studio/features/create_story/controllers/create_controller.dart';
import 'package:actpod_studio/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'upload_area.dart'; // ← 放到同資料夾時的匯入

class UploadStep extends ConsumerWidget {
  const UploadStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createControllerProvider);
    final ctrl = ref.read(createControllerProvider.notifier);

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UploadArea(
              allowedExtensions: const ['mp3', 'aac','m4a'],
              onChanged: (files) async {
                ctrl.setAudioFiles(files);
              },
            ),
            const SizedBox(height: 12),

            if (state.audios.isNotEmpty) ...[
              Row(
                children: [
                  Text(
                    '已選擇 ${state.audios.length} 個檔案',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      for (final a in state.audios) {
                        ctrl.removeAudio(a.id);
                      }
                    },
                    icon: const Icon(Icons.clear_all_rounded),
                    label: const Text('清空'),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.audios.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: Colors.grey.shade200),
                  itemBuilder: (_, i) {
                    final a = state.audios[i];
                    return ListTile(
                      leading: CircleAvatar(
                        child: const Icon(Icons.audio_file_rounded),
                      ),
                      title: Text(
                        a.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(_fmtDuration(a.duration)),
                      trailing: IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => ctrl.removeAudio(a.id),
                      ),
                    );
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
