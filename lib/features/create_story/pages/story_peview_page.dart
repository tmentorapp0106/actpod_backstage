import 'dart:typed_data';

import 'package:actpod_studio/app/theme/theme.dart';
import 'package:actpod_studio/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:actpod_studio/features/create_story/controllers/create_controller.dart';

/// ====== 預覽畫面（接 Riverpod，把使用者填寫的資料帶進卡片） ======
class PreviewStep extends ConsumerWidget {
  const PreviewStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createControllerProvider);

    // --- 依你的 CreateState 欄位替換以下對應 ---
    final title        = (state.title ?? '').trim();              // ex: state.title
    final description  = (state.description ?? '').trim();        // ex: state.description
    final channelName  = (state.selectedSpace ?? '未選擇頻道');     // ex: state.selectedChannelName
    final authorName   = '';                // 若沒有可留空
    final coverUrl     = '';                          // ex: state.coverUrl
    final scheduledAt  = state.scheduledAt;                       // ex: state.scheduledAt
    final isScheduled  = state.publishMode == PublishMode.schedule;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('預覽畫面',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 12),

        // 把資料餵進卡片預覽
        _StoryCardPreview(
          title: title.isNotEmpty ? title : '（未命名）',
          description: description.isNotEmpty ? description : '（尚未輸入描述）',
          channelName: channelName,
          authorName: authorName.isNotEmpty ? authorName : '作者',
          coverUrl: coverUrl,
          imageBytes: state.imageFileBytes!,
          // 若是排程則顯示排程時間，否則顯示現在（或你的建立時間）
          dateTime: isScheduled ? scheduledAt ?? DateTime.now() : DateTime.now(),
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
  final String channelName;
  final String authorName;
  final String? coverUrl;
  final DateTime dateTime;
  final int listens;
  final bool showNewBadge;
  final Uint8List imageBytes;

  const _StoryCardPreview({
    required this.title,
    required this.description,
    required this.channelName,
    required this.authorName,
    required this.dateTime,
    required this.imageBytes,
    this.coverUrl,
    this.listens = 0,
    this.showNewBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppTheme.seed;

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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(.55),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.play_arrow_rounded, size: 16, color: Colors.white),
                              SizedBox(width: 4),
                              Text('試聽精華', style: TextStyle(color: Colors.white, fontSize: 12)),
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
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      _LineMeta(icon: Icons.podcasts_rounded, text: channelName),
                      const SizedBox(height: 4),
                      if (authorName.isNotEmpty)
                        _LineMeta(icon: Icons.person_rounded, text: authorName),
                      const SizedBox(height: 8),
                      const _TagChip(label: '空間'), // 之後可用實際 space tag
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
              style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_month_outlined, size: 16, color: Colors.black45),
                const SizedBox(width: 6),
                Text(_fmt(dateTime), style: const TextStyle(color: Colors.black54)),
                const SizedBox(width: 16),
                const Icon(Icons.headphones_outlined, size: 16, color: Colors.black45),
                const SizedBox(width: 6),
                Text('$listens 次', style: const TextStyle(color: Colors.black54)),
                const SizedBox(width: 16),
                if (showNewBadge) ...[
                  Icon(Icons.bolt_rounded, size: 16, color: primary),
                  const SizedBox(width: 4),
                  Text('新發布',
                      style: TextStyle(color: primary, fontWeight: FontWeight.w600)),
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
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white),
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

/// 超簡單日期格式（可換成 intl）
String _fmt(DateTime dt) {
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$y-$m-$d $hh:$mm';
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
      child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
    );
  }
}
