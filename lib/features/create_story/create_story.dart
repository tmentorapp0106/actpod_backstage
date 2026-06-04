// features/publish/pages/publish_flow_page.dart
import 'package:actpod_studio/app/theme/theme.dart';
import 'package:actpod_studio/features/create_story/const.dart';
import 'package:actpod_studio/features/create_story/controllers/create_flow_controller.dart';
import 'package:actpod_studio/features/create_story/pages/create_type_page.dart';
import 'package:actpod_studio/features/create_story/pages/package/package_preview_page.dart';
import 'package:actpod_studio/features/create_story/pages/package/package_settings_page.dart';
import 'package:actpod_studio/features/create_story/pages/package/package_setup_page.dart';
import 'package:actpod_studio/features/create_story/pages/package/package_stories_page.dart';
import 'package:actpod_studio/features/create_story/pages/single/detail_page.dart';
import 'package:actpod_studio/features/create_story/pages/single/preview_page.dart';
import 'package:actpod_studio/features/create_story/pages/single/settings_page.dart';
import 'package:actpod_studio/features/create_story/pages/single/upload_page.dart';
import 'package:actpod_studio/features/create_story/widgets/step_button.dart';
import 'package:actpod_studio/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_scaffold.dart';

class PublishFlowPage extends ConsumerWidget {
  final int stepIndex;
  const PublishFlowPage({super.key, required this.stepIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createFlowControllerProvider);
    final steps = _stepsFor(state.flowType);
    final labels = _labelsFor(state.flowType);
    final current = stepIndex.clamp(0, steps.length - 1);
    final children = _childrenFor(state.flowType);

    return AppScaffold(
      title: 'ActPod 後台',
      child: ListView(
        padding: _responsivePadding(context),
        children: [
          // 進度列 + 標題列
          _PublishHeader(current: current, total: steps.length, labels: labels),
          const SizedBox(height: 16),

          // 內容區（每一步自己的表單/內容）
          children[current],

          const SizedBox(height: 20),

          if (state.isSaving || state.uploadItems.isNotEmpty) ...[
            _UploadProgressCard(state: state),
            const SizedBox(height: 20),
          ],

          // 底部導覽列（上一步 / 下一步 / 發布）
          StepButton(stepIndex: current, steps: steps),
        ],
      ),
    );
  }

  List<PublishStep> _stepsFor(CreateFlowType? flowType) {
    if (flowType == CreateFlowType.package) {
      return const [
        PublishStep.type,
        PublishStep.package,
        PublishStep.detail,
        PublishStep.settings,
        PublishStep.preview,
      ];
    }
    return const [
      PublishStep.type,
      PublishStep.upload,
      PublishStep.detail,
      PublishStep.settings,
      PublishStep.preview,
    ];
  }

  List<String> _labelsFor(CreateFlowType? flowType) {
    if (flowType == CreateFlowType.package) {
      return const ['建立類型', '套裝資訊', '套裝故事', '上傳設定', '預覽畫面'];
    }
    return const ['建立類型', '上傳音檔', '編輯故事', '上傳設定', '預覽畫面'];
  }

  List<Widget> _childrenFor(CreateFlowType? flowType) {
    if (flowType == CreateFlowType.package) {
      return const [
        CreateTypeStep(),
        PackageSetupStep(),
        PackageStoriesStep(),
        PackageSettingsStep(),
        PackagePreviewStep(),
      ];
    }
    return const [
      CreateTypeStep(),
      UploadStep(),
      DetailStep(),
      SettingsStep(),
      PreviewStep(),
    ];
  }

  EdgeInsets _responsivePadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1750) {
      return const EdgeInsets.symmetric(horizontal: 120, vertical: 16);
    }
    if (w >= 1200) {
      return const EdgeInsets.symmetric(horizontal: 52, vertical: 16);
    }
    if (w >= 720) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    }
    return const EdgeInsets.symmetric(horizontal: 8, vertical: 12);
  }
}

class _UploadProgressCard extends StatelessWidget {
  final CreateFlowState state;

  const _UploadProgressCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final total = state.uploadItems.length;
    final completed = state.completedUploadCount;
    final progress = total == 0 ? null : completed / total;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '發布進度',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            state.currentUploadLabel == null
                ? '準備上傳中...'
                : '目前處理: ${state.currentUploadLabel}',
            style: const TextStyle(color: Colors.black87, height: 1.4),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: progress, minHeight: 10),
          const SizedBox(height: 8),
          Text(
            '$completed / $total 已完成',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          ...state.uploadItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _UploadStatusIcon(status: item.status),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        color: item.status == UploadQueueItemStatus.done
                            ? Colors.black54
                            : Colors.black87,
                      ),
                    ),
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

class _UploadStatusIcon extends StatelessWidget {
  final UploadQueueItemStatus status;

  const _UploadStatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case UploadQueueItemStatus.pending:
        return const Icon(
          Icons.radio_button_unchecked_rounded,
          size: 20,
          color: Colors.black26,
        );
      case UploadQueueItemStatus.active:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case UploadQueueItemStatus.done:
        return const Icon(
          Icons.check_circle_rounded,
          size: 20,
          color: Colors.green,
        );
      case UploadQueueItemStatus.failed:
        return const Icon(Icons.error_rounded, size: 20, color: Colors.red);
    }
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
            Text(
              '新建故事',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              '步驟 ${current + 1} / $total',
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 進度條
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: ratio.clamp(0, 1),
            minHeight: 10,
            backgroundColor: context.color.brand.withValues(alpha: .2),
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
                        done
                            ? Icons.check_circle_rounded
                            : (active
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_unchecked_rounded),
                        size: 24,
                        color: done || active
                            ? context.color.brand
                            : Colors.black26,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          labels[i],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: active
                                ? context.color.brand
                                : Colors.black54,
                            fontWeight: active
                                ? FontWeight.w600
                                : FontWeight.w600,
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
