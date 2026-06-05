import 'package:actpod_studio/features/create_story/controllers/package_create_controller.dart';
import 'package:actpod_studio/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PackagePreviewStep extends ConsumerStatefulWidget {
  const PackagePreviewStep({super.key});

  @override
  ConsumerState<PackagePreviewStep> createState() => _PackagePreviewStepState();
}

class _PackagePreviewStepState extends ConsumerState<PackagePreviewStep> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(packageCreateControllerProvider.notifier)
          .probeMissingDurations();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                const SizedBox(height: 4),
                const Text('價格', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ...state.packagePrices.map(
                  (price) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _PricePreviewItem(price: price),
                  ),
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
                  (story) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _StoryPreviewItem(
                      story: story,
                      isLoadingDuration: state.probingDurationStoryIds.contains(
                        story.id,
                      ),
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

class _PricePreviewItem extends StatelessWidget {
  final PackagePriceDraft price;

  const _PricePreviewItem({required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${price.lable} / ${price.priceType}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text('${price.podcoins} Podcoins / NT\$${price.twd}'),
          const SizedBox(width: 12),
          Chip(
            label: Text(price.isActive ? '啟用' : '停用'),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _StoryPreviewItem extends StatelessWidget {
  final PackageStoryDraft story;
  final bool isLoadingDuration;

  const _StoryPreviewItem({
    required this.story,
    required this.isLoadingDuration,
  });

  @override
  Widget build(BuildContext context) {
    final audio = story.audio;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CoverPreview(story: story),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story.title.trim().isEmpty ? '未命名 Story' : story.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  story.description.trim().isEmpty
                      ? '尚未輸入描述'
                      : story.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54, height: 1.4),
                ),
                if (story.packageNote.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    story.packageNote,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.red, height: 1.4),
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _MetaChip(
                      icon: Icons.audio_file_rounded,
                      label: audio?.fileName ?? '未上傳音檔',
                    ),
                    _MetaChip(
                      icon: Icons.timer_outlined,
                      label: isLoadingDuration
                          ? '解析中...'
                          : _fmtDuration(audio?.duration ?? Duration.zero),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDuration(Duration duration) {
    if (duration == Duration.zero) return '--:--';
    final mm = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }
}

class _CoverPreview extends StatelessWidget {
  final PackageStoryDraft story;

  const _CoverPreview({required this.story});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 88,
        height: 88,
        child: story.imageFilesBytes.isEmpty
            ? Container(
                color: Colors.grey.shade100,
                child: const Icon(Icons.image_outlined, color: Colors.black38),
              )
            : Image.memory(story.imageFilesBytes.first, fit: BoxFit.cover),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.black45),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.black54)),
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
