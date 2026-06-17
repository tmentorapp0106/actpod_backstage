import 'dart:typed_data';

import 'package:actpod_studio/app/theme/app_colors.dart';
import 'package:actpod_studio/features/create_story/controllers/package_create_controller.dart';
import 'package:actpod_studio/features/create_story/controllers/user_controller.dart';
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
                const SizedBox(height: 12),
                _PackageCoverPreview(
                  imageBytes: state.coverImageBytes,
                  imageUrl: state.coverImageUrl,
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
        const AppCard(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '包含 Story',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...state.stories.map(
          (story) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _StoryPreviewItem(
              story: story,
              channelImageUrl: _channelImageUrlFor(
                state.channels,
                story.selectedChannel,
              ),
              authorAvatar: ref.read(userControllerProvider)?.avatarUrl ?? "",
              authorName: ref.read(userControllerProvider)?.name ?? "未知",
              isLoadingDuration: state.probingDurationStoryIds.contains(
                story.id,
              ),
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
              price.lable,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text('${price.podcoins} Podcoins / NT\$${price.twd}'),
          const SizedBox(width: 12),
          Chip(
            label: Text(price.isActive ? '啟用' : '停用'),
            visualDensity: VisualDensity.compact,
            backgroundColor: price.isActive ? AppColors.brand : null,
          ),
        ],
      ),
    );
  }
}

class _PackageCoverPreview extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? imageUrl;

  const _PackageCoverPreview({
    required this.imageBytes,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (imageBytes == null && (imageUrl == null || imageUrl!.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 160,
          width: double.infinity,
          child: imageBytes != null
              ? Image.memory(imageBytes!, fit: BoxFit.cover)
              : Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.broken_image_rounded),
                  ),
                ),
        ),
      ),
    );
  }
}

class _StoryPreviewItem extends StatelessWidget {
  final PackageStoryDraft story;
  final String channelImageUrl;
  final String authorAvatar;
  final String authorName;
  final bool isLoadingDuration;

  const _StoryPreviewItem({
    required this.story,
    required this.channelImageUrl,
    required this.authorName,
    required this.authorAvatar,
    required this.isLoadingDuration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final audio = story.audio;
    final duration =
        audio?.duration ??
        (story.contentUrl.isNotEmpty
            ? Duration(milliseconds: story.storyMilliSec)
            : Duration.zero);

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      _UserMeta(imageUrl: authorAvatar, text: authorName),
                      const SizedBox(height: 8),
                      _ChannelMeta(
                        imageUrl: channelImageUrl,
                        text: story.selectedChannel ?? '未選擇 Channel',
                      ),
                      const SizedBox(height: 8),
                      _TagChip(label: story.selectedSpace ?? '未選擇 Space'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              story.description.trim().isEmpty ? '尚未輸入描述' : story.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: Colors.black45,
                ),
                const SizedBox(width: 6),
                Text(
                  isLoadingDuration ? '解析中...' : _fmtDuration(duration),
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.headphones_outlined,
                  size: 16,
                  color: Colors.black45,
                ),
                const SizedBox(width: 6),
                const Text('0 次', style: TextStyle(color: Colors.black54)),
                const SizedBox(width: 16),
                Image.asset(
                  'assets/images/podcoins.png',
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${story.podcoins} Podcoins / NT\$${story.twd}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.brand,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 44,
                  height: 44,
                  child: FloatingActionButton(
                    elevation: 0,
                    heroTag: null,
                    onPressed: () {},
                    backgroundColor: AppColors.brand,
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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

String _channelImageUrlFor(List channels, String? channelName) {
  if (channelName == null || channelName.isEmpty) return '';
  for (final channel in channels) {
    if (channel.channelName == channelName) {
      return channel.channelImageUrl;
    }
  }
  return '';
}

class _ChannelMeta extends StatelessWidget {
  final String imageUrl;
  final String text;

  const _ChannelMeta({required this.imageUrl, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child: SizedBox(
            width: 36,
            height: 36,
            child: imageUrl.trim().isEmpty
                ? const Icon(
                    Icons.podcasts_rounded,
                    size: 16,
                    color: Colors.black54,
                  )
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.podcasts_rounded,
                      size: 16,
                      color: Colors.black54,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _UserMeta extends StatelessWidget {
  final String imageUrl;
  final String text;

  const _UserMeta({required this.imageUrl, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child: SizedBox(
            width: 16,
            height: 16,
            child: imageUrl.trim().isEmpty
                ? const Icon(
                    Icons.account_circle,
                    size: 16,
                    color: Colors.black54,
                  )
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.account_circle,
                      size: 16,
                      color: Colors.black54,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.black54),
      ),
    );
  }
}

class _CoverPreview extends StatelessWidget {
  final PackageStoryDraft story;

  const _CoverPreview({required this.story});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: story.imageFilesBytes.isEmpty
                ? story.remoteImageUrls.isEmpty
                      ? Container(
                          color: Colors.grey.shade100,
                          child: const Icon(
                            Icons.image_outlined,
                            color: Colors.black38,
                          ),
                        )
                      : Image.network(
                          story.remoteImageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade100,
                            child: const Icon(
                              Icons.broken_image_rounded,
                              color: Colors.black38,
                            ),
                          ),
                        )
                : Image.memory(story.imageFilesBytes.first, fit: BoxFit.cover),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: .55),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow_rounded, size: 16, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    '試聽精華',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
