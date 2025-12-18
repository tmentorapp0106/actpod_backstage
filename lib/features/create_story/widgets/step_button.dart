import 'package:actpod_studio/features/api/api.dart';
import 'package:actpod_studio/features/api/story_system_api.dart';
import 'package:actpod_studio/features/api/upload_system_api.dart';
import 'package:actpod_studio/features/create_story/const.dart';
import 'package:actpod_studio/features/create_story/controllers/create_controller.dart';
import 'package:actpod_studio/features/create_story/controllers/user_controller.dart';
import 'package:actpod_studio/features/create_story/widgets/step_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// StepButton
/// 可顯示「上一步」與「下一步 / 發布」的按鈕列，並可結合 Riverpod 狀態。
class StepButton extends ConsumerWidget {
  final int stepIndex;
  final List<PublishStep> steps;

  const StepButton({super.key, required this.stepIndex, required this.steps});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 只針對需要的欄位重建：效能較佳
    final state = ref.watch(createControllerProvider);
    final ctrl = ref.read(createControllerProvider.notifier);

    final isSaving = ref.watch(
      createControllerProvider.select((s) => s.isSaving),
    );
    final canNext = ref.watch(
      createControllerProvider.select((s) => s.canNext),
    );

    return Align(
      alignment: Alignment.centerRight,
      child: StepNavBar(
        showPrev: stepIndex > 0 && !isSaving, // 發布中不給退
        nextLabel: _nextLabel(stepIndex),
        isLast: stepIndex == steps.length - 1,

        // 👉 控制按鈕狀態
        busy: isSaving, // 右側按鈕顯示 loading
        disableNext: isSaving || !canNext, // 發布中或驗證未過 禁用

        onPrev: () {
          if (stepIndex > 0) {
            ctrl.back();
            context.go('/publish/${state.currentPage - 1}');
          }
        },
        onNext: () {
          if (stepIndex < steps.length - 1) {
            print(state.currentPage);
            if (!canNext) return; // 防呆
            ctrl.next();
            context.go('/publish/${state.currentPage + 1}');
           
          } else {
            _submit(context, ref); // 內部會 setSaving(true/false)
          }
        },
      ),
    );
  }

  String _nextLabel(int i) {
    if (i < 1) return '下一步';
    if (i == 1) return '進行上傳設定';
    if (i == 2) return '進入預覽畫面';
    return '發布';
  }

  void _submit(BuildContext context, WidgetRef ref) async {
    final ctrl = ref.read(createControllerProvider.notifier);
    ctrl.setSaving(true);

    try {
      // TODO: 上傳 / 發布流程

      CreateState createState = ref.watch(createControllerProvider);
      // print(createState.audios[0].duration.inMicroseconds);
      String contentUrl = await UploadApi().uploadStoryContent(
        createState.audios[0].fileName,
        createState.audios[0].fileBytes,
      );
      final uploadImageFutures = List.generate(
        createState.imageFilePaths?.length?? 0,
        (i) => UploadApi().uploadStoryImage(createState.imageFilePaths![i], createState.imageFilesBytes![i]),
      );
      final List<String> imageUrls = await Future.wait(uploadImageFutures);

      final spaceId = createState.spaces
          .where((space) => space.name == createState.selectedSpace)
          .first
          .spaceId;
      final channelId = createState.channels
          .where(
            (channel) => channel.channelName == createState.selectedChannel,
          )
          .first
          .channelId;
      await StoryApi().uploadStory(
        spaceId,
        channelId,
        contentUrl,
        createState.title!,
        createState.description!,
        imageUrls,
        createState.audios[0].duration.inMilliseconds,
        (createState.audios[0].duration.inMilliseconds / 2).toInt(),
        (createState.audios[0].duration.inMilliseconds / 2).toInt() + 20 * 1000,
        [
          BlockInfoDto(
            from: Duration.zero,
            to: createState.audios[0].duration,
            position: Duration.zero,
            soundIndex: 0,
            length: createState.audios[0].duration,
            volume: 0,
            url: "",
            name: "",
            waveformData: [],
            skip: Duration.zero,
            type: "story",
            soundType: "",
          ),
        ],
        "enable",
        false,
        0,
        createState.collaborator?.userId,
        createState.scheduledAt,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已提交發布')));

    } catch (e, st) {
      debugPrint('發布失敗：$e');
      debugPrint(st.toString()); // ✅ 會印出是哪一行
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('發布失敗：$e')));
    } finally {
      ctrl.clear();
      ctrl.setSaving(false);
      ctrl.jumpTo(0); // 回到第一步
      GoRouter.of(context).go('/publish/0'); // 發布後回到第一步
    }
  }
}
