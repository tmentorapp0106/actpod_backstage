import 'dart:typed_data';

import 'package:actpod_studio/app/theme/theme.dart';
import 'package:actpod_studio/features/create_story/controllers/create_shared_models.dart';
import 'package:actpod_studio/features/create_story/controllers/user_controller.dart';
import 'package:actpod_studio/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:actpod_studio/features/create_story/controllers/single_create_controller.dart';

/// ====== 預覽畫面（接 Riverpod，把使用者填寫的資料帶進卡片） ======
class PreviewStep extends ConsumerStatefulWidget {
  const PreviewStep({super.key});

  @override
  ConsumerState<PreviewStep> createState() => _PreviewStepState();
}

class _PreviewStepState extends ConsumerState<PreviewStep> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(singleCreateControllerProvider.notifier).probeMissingDurations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(singleCreateControllerProvider);
    final user = ref.read(userControllerProvider);

    // --- 依你的 CreateState 欄位替換以下對應 ---
    final title = (state.title ?? '').trim(); // ex: state.title
    final description = (state.description ?? '')
        .trim(); // ex: state.description
    final channelName =
        (state.selectedChannel ?? '未選擇頻道'); // ex: state.selectedChannelName
    final channelImageUrl = _channelImageUrlFor(
      state.channels,
      state.selectedChannel,
    );
    final authorName =
        _channelNicknameFor(state.channels, state.selectedChannel).isNotEmpty
        ? _channelNicknameFor(state.channels, state.selectedChannel)
        : user?.name ?? '';
    final authorAvatarUrl =
        _channelAvatarUrlFor(state.channels, state.selectedChannel).isNotEmpty
        ? _channelAvatarUrlFor(state.channels, state.selectedChannel)
        : user?.avatarUrl ?? '';
    final selectedSpace =
        (state.selectedSpace ?? '未選擇頻道'); // ex: state.selectedChannelName
    final coverUrl = ''; // ex: state.coverUrl
    final scheduledAt = state.scheduledAt; // ex: state.scheduledAt
    final isScheduled = state.publishMode == PublishMode.schedule;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '預覽畫面',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 12),

        // 把資料餵進卡片預覽
        _StoryCardPreview(
          title: title.isNotEmpty ? title : '（未命名）',
          description: description.isNotEmpty ? description : '（尚未輸入描述）',
          channelName: channelName,
          channelImageUrl: channelImageUrl,
          selectedSpace: selectedSpace,
          authorName: authorName.isNotEmpty ? authorName : '作者',
          authorAvatarUrl: authorAvatarUrl,
          coverUrl: coverUrl,
          imageBytes: state.imageFilesBytes!.first,
          storyLength: state.selectedAudio?.duration ?? Duration.zero,
          isProbingStoryLength: state.probingDurationAudioIds.contains(
            state.selectedAudioId,
          ),
          podcoins: state.pricePodcoin,
          twd: state.priceTwd,
          // 若是排程則顯示排程時間，否則顯示現在（或你的建立時間）
          dateTime: isScheduled
              ? scheduledAt ?? DateTime.now()
              : DateTime.now(),
          showNewBadge: !isScheduled,
          listens: 0, // 沒有就 0
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}

/// ====== 預覽卡片（吃資料的版本） ======
class _StoryCardPreview extends StatelessWidget {
  final String title;
  final String description;
  final String selectedSpace;
  final String channelName;
  final String channelImageUrl;
  final String authorName;
  final String authorAvatarUrl;
  final String? coverUrl;
  final DateTime dateTime;
  final int listens;
  final bool showNewBadge;
  final Uint8List imageBytes;
  final Duration storyLength;
  final bool isProbingStoryLength;
  final int podcoins;
  final int twd;

  const _StoryCardPreview({
    required this.title,
    required this.description,
    required this.selectedSpace,
    required this.channelName,
    required this.channelImageUrl,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.dateTime,
    required this.imageBytes,
    required this.storyLength,
    required this.isProbingStoryLength,
    required this.podcoins,
    required this.twd,
    this.coverUrl,
    this.listens = 0,
    this.showNewBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppTheme().theme.colorScheme.primary;

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 上半：左圖右文
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: 110,
                        height: 110,
                        child: coverUrl == null || coverUrl!.isEmpty
                            ? Image.memory(imageBytes, fit: BoxFit.cover)
                            : Image.network(coverUrl!, fit: BoxFit.cover),
                      ),
                      Positioned(
                        left: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: .55),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.play_arrow_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '試聽精華',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // 右側文字區
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      _ChannelMeta(
                        imageUrl: channelImageUrl,
                        text: channelName,
                      ),
                      const SizedBox(height: 4),
                      if (authorName.isNotEmpty)
                        _UserMeta(imageUrl: authorAvatarUrl, text: authorName),
                      const SizedBox(height: 4),
                      _LineMeta(
                        icon: Icons.timer_outlined,
                        text: isProbingStoryLength
                            ? '解析中...'
                            : _fmtDuration(storyLength),
                      ),
                      const SizedBox(height: 8),
                      _TagChip(label: selectedSpace), // 之後可用實際 space tag
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
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
                  Icons.calendar_month_outlined,
                  size: 16,
                  color: Colors.black45,
                ),
                const SizedBox(width: 6),
                Text(
                  _fmt(dateTime),
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.headphones_outlined,
                  size: 16,
                  color: Colors.black45,
                ),
                const SizedBox(width: 6),
                Text(
                  '$listens 次',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(width: 16),
                if (podcoins > 0 || twd > 0) ...[
                  Image.asset(
                    'assets/images/podcoins.png',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _fmtPrice(podcoins, twd),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                if (showNewBadge) ...[
                  Icon(Icons.bolt_rounded, size: 16, color: primary),
                  const SizedBox(width: 4),
                  Text(
                    '新發布',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const Spacer(),
                SizedBox(
                  width: 44,
                  height: 44,
                  child: FloatingActionButton(
                    elevation: 0,
                    heroTag: null,
                    onPressed: () {},
                    backgroundColor: primary,
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

String _channelNicknameFor(List channels, String? channelName) {
  if (channelName == null || channelName.isEmpty) return '';
  for (final channel in channels) {
    if (channel.channelName == channelName) {
      return channel.nickname;
    }
  }
  return '';
}

String _channelAvatarUrlFor(List channels, String? channelName) {
  if (channelName == null || channelName.isEmpty) return '';
  for (final channel in channels) {
    if (channel.channelName == channelName) {
      return channel.userAvatarUrl;
    }
  }
  return '';
}

String _fmtDuration(Duration duration) {
  if (duration == Duration.zero) return '--:--';
  final mm = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final ss = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$mm:$ss';
}

String _fmtPrice(int podcoins, int twd) {
  if (podcoins > 0 && twd > 0) return '$podcoins Podcoins / NT\$$twd';
  if (podcoins > 0) return '$podcoins Podcoins';
  return 'NT\$$twd';
}

/// 超簡單日期格式（可換成 intl）
String _fmt(DateTime dt) {
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
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
            width: 16,
            height: 16,
            child: imageUrl.trim().isEmpty
                ? const Icon(
                    Icons.podcasts_rounded,
                    size: 16,
                    color: Colors.black45,
                  )
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.podcasts_rounded,
                      size: 16,
                      color: Colors.black45,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.black87)),
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
                    color: Colors.black45,
                  )
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.account_circle,
                      size: 16,
                      color: Colors.black45,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.black87)),
      ],
    );
  }
}

/// 行內元素 & Tag
class _LineMeta extends StatelessWidget {
  final IconData icon;
  final String text;
  const _LineMeta({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black45),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.black87)),
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
