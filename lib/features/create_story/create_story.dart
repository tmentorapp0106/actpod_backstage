// features/publish/pages/publish_flow_page.dart
import 'package:actpod_studio/app/theme/theme.dart';
import 'package:actpod_studio/features/create_story/const.dart';
import 'package:actpod_studio/features/create_story/pages/Story_highlight_page.dart';
import 'package:actpod_studio/features/create_story/pages/Story_settings_page.dart';
import 'package:actpod_studio/features/create_story/pages/story_detail_page.dart';
import 'package:actpod_studio/features/create_story/pages/story_peview_page.dart';
import 'package:actpod_studio/features/create_story/pages/story_upload_page.dart';
import 'package:actpod_studio/features/create_story/widgets/step_button.dart';
import 'package:actpod_studio/features/create_story/widgets/step_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/app_scaffold.dart';

class PublishFlowPage extends StatelessWidget {
  final int stepIndex;
  const PublishFlowPage({super.key, required this.stepIndex});

  static const steps = PublishStep.values;

  @override
  Widget build(BuildContext context) {
    final step = steps[stepIndex.clamp(0, steps.length - 1)];
    final children = <Widget>[
      const UploadStep(),
      const DetailStep(),
      // const HighlightStep(),
      // const SettingsStep(),
      const PreviewStep(),
    ];

    return AppScaffold(
      title: 'ActPod 後台',
      child: ListView(
        padding: _responsivePadding(context),
        children: [
          // 進度列 + 標題列
          _PublishHeader(
            current: stepIndex,
            total: steps.length,
            // labels: const ['上傳音檔', '編輯故事', '擷取精華', '上傳設定', '預覽畫面'],
            labels: const ['上傳音檔', '編輯故事', '預覽畫面'],
          ),
          const SizedBox(height: 16),

          // 內容區（每一步自己的表單/內容）
          children[stepIndex],

          const SizedBox(height: 20),

          // 底部導覽列（上一步 / 下一步 / 發布）
          StepButton(stepIndex: stepIndex, steps: steps)
        ],
      ),
    );
  }

  EdgeInsets _responsivePadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1750) return const EdgeInsets.symmetric(horizontal: 120, vertical: 16);
    if (w >= 1200) return const EdgeInsets.symmetric(horizontal: 52, vertical: 16);
    if (w >= 720) return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    return const EdgeInsets.symmetric(horizontal: 8, vertical: 12);
  }
}





class _PublishHeader extends StatelessWidget {
  final int current;
  final int total;
  final List<String> labels;
  const _PublishHeader({
    required this.current,
    required this.total,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = (current + 1) / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 標題 + 右側步驟顯示
        Row(
          children: [
            Text('新建故事', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('步驟 ${current + 1} / $total', style: const TextStyle(color: Colors.black54)),
          ],
        ),
        const SizedBox(height: 12),

        // 進度條
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: ratio.clamp(0, 1),
            minHeight: 10,
            backgroundColor: context.color.brand.withOpacity(.2),
            color: context.color.brand,
          ),
        ),
        const SizedBox(height: 12),

        // 標籤（五段）
        LayoutBuilder(
          builder: (_, c) {
            final w = (c.maxWidth - 16) / (labels.length);
            return Wrap(
              spacing: 0,
              runSpacing: 6,
              children: List.generate(labels.length, (i) {
                final active = i == current;
                final done = i < current;
                return SizedBox(
                  width: w,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        done ? Icons.check_circle_rounded :
                              (active ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded),
                        size: 24,
                        color: done || active ? context.color.brand : Colors.black26,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          labels[i],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: active ? context.color.brand : Colors.black54,
                            fontWeight: active ? FontWeight.w600 : FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}


