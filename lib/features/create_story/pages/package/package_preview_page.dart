import 'package:actpod_studio/features/create_story/controllers/package_create_controller.dart';
import 'package:actpod_studio/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PackagePreviewStep extends ConsumerWidget {
  const PackagePreviewStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(packageCreateControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '套裝摘要',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                _SummaryRow(label: '套裝名稱', value: state.packageName ?? ''),
                _SummaryRow(label: 'Space', value: state.selectedSpace ?? ''),
                _SummaryRow(
                  label: 'Channel',
                  value: state.selectedChannel ?? '',
                ),
                _SummaryRow(
                  label: '套裝價格',
                  value: '${state.packagePricePodcoin} Podcoin',
                ),
                _SummaryRow(
                  label: '單賣價格',
                  value: '${state.packageSoloPricePodcoin} Podcoin',
                ),
                const SizedBox(height: 8),
                Text(
                  state.packageDescription ?? '',
                  style: const TextStyle(color: Colors.black54, height: 1.4),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '包含 Story',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ...state.stories.map(
                  (story) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      child: Icon(Icons.audio_file_rounded),
                    ),
                    title: Text(
                      story.title.trim().isEmpty ? '未命名 Story' : story.title,
                    ),
                    subtitle: Text(
                      '${story.audio?.fileName ?? '未上傳音檔'} ・ ${story.imageFilesBytes.length} 張封面',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
