import 'package:actpod_studio/api/story_system_api.dart';
import 'package:actpod_studio/api/upload_system_api.dart';
import 'package:actpod_studio/features/create_story/const.dart';
import 'package:actpod_studio/features/create_story/controllers/create_flow_controller.dart';
import 'package:actpod_studio/features/create_story/controllers/package_create_controller.dart';
import 'package:actpod_studio/features/create_story/controllers/single_create_controller.dart';
import 'package:actpod_studio/features/create_story/widgets/step_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class StepButton extends ConsumerStatefulWidget {
  final int stepIndex;
  final List<PublishStep> steps;

  const StepButton({super.key, required this.stepIndex, required this.steps});

  @override
  ConsumerState<StepButton> createState() => _StepButtonState();
}

class _StepButtonState extends ConsumerState<StepButton> {
  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(createFlowControllerProvider);
    final flowCtrl = ref.read(createFlowControllerProvider.notifier);
    final isSaving = flow.isSaving;
    final canNext = _canNext(ref, flow, widget.stepIndex);

    return Align(
      alignment: Alignment.centerRight,
      child: StepNavBar(
        showPrev: widget.stepIndex > 0 && !isSaving,
        nextLabel: _nextLabel(widget.stepIndex),
        isLast: widget.stepIndex == widget.steps.length - 1,
        busy: isSaving,
        disableNext: isSaving || !canNext,
        onPrev: () {
          if (widget.stepIndex > 0) {
            flowCtrl.back();
            context.go('/publish/${flow.currentPage - 1}');
          }
        },
        onNext: () {
          if (widget.stepIndex < widget.steps.length - 1) {
            if (!canNext) return;
            flowCtrl.next(widget.steps.length);
            context.go('/publish/${flow.currentPage + 1}');
          } else {
            _submit(context, ref);
          }
        },
      ),
    );
  }

  bool _canNext(WidgetRef ref, CreateFlowState flow, int stepIndex) {
    if (stepIndex == 0) return flow.flowType != null;

    if (flow.flowType == CreateFlowType.package) {
      final packageState = ref.watch(packageCreateControllerProvider);
      switch (stepIndex) {
        case 1:
          return packageState.hasValidPackageInfo;
        case 2:
          return packageState.hasValidStories;
        case 3:
          return packageState.hasValidSettings;
        case 4:
          return packageState.probingDurationStoryIds.isEmpty;
        default:
          return false;
      }
    }

    final singleState = ref.watch(singleCreateControllerProvider);
    switch (stepIndex) {
      case 1:
        return singleState.hasValidUpload;
      case 2:
        return singleState.hasValidStoryDetail;
      case 3:
        return singleState.hasValidSettings;
      case 4:
        return true;
      default:
        return false;
    }
  }

  String _nextLabel(int i) {
    if (i == 0) return '下一步';
    if (i < widget.steps.length - 2) return '下一步';
    if (i == widget.steps.length - 2) return '進入預覽畫面';
    return '發布';
  }

  void _submit(BuildContext context, WidgetRef ref) async {
    final flowCtrl = ref.read(createFlowControllerProvider.notifier);
    final flow = ref.read(createFlowControllerProvider);
    final packageCtrl = ref.read(packageCreateControllerProvider.notifier);
    final singleCtrl = ref.read(singleCreateControllerProvider.notifier);

    if (flow.flowType == CreateFlowType.package &&
        ref
            .read(packageCreateControllerProvider)
            .probingDurationStoryIds
            .isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('音檔時長解析中，完成後才能發布')));
      return;
    }

    if (flow.flowType == CreateFlowType.package) {
      flowCtrl.beginUploadQueue(
        _buildPackageUploadQueue(ref.read(packageCreateControllerProvider)),
      );
    } else {
      flowCtrl.beginUploadQueue(
        _buildSingleUploadQueue(ref.read(singleCreateControllerProvider)),
      );
    }

    try {
      if (flow.flowType == CreateFlowType.package) {
        await _submitPackage(ref, ref.read(packageCreateControllerProvider));
        if (!mounted) return;
        packageCtrl.clear();
      } else {
        await _submitSingle(ref, ref.read(singleCreateControllerProvider));
        if (!mounted) return;
        singleCtrl.clear();
      }

      if (!mounted) return;
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已提交發布')));
      }
    } catch (e, st) {
      debugPrint('發布失敗：$e');
      debugPrint(st.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('發布失敗：$e')));
      }
    } finally {
      if (mounted) {
        flowCtrl.clearUploadQueue();
        flowCtrl.clear();
        if (context.mounted) {
          GoRouter.of(context).go('/publish/0');
        }
      }
    }
  }

  Future<void> _submitSingle(WidgetRef ref, SingleCreateState state) async {
    final uploaded = await _uploadSingleAssets(ref, state);
    final ids = _selectedSingleIds(state);

    await _runUploadStep(
      ref,
      'single-publish',
      () => StoryApi().uploadStory(
        ids.spaceId,
        ids.channelId,
        uploaded.contentUrl,
        state.title!,
        state.description!,
        uploaded.imageUrls,
        state.audios[0].duration.inMilliseconds,
        (state.audios[0].duration.inMilliseconds / 2).toInt(),
        (state.audios[0].duration.inMilliseconds / 2).toInt() + 20 * 1000,
        "enable",
        state.pricePodcoin > 0,
        state.pricePodcoin,
        state.collaborator?.userId,
        state.scheduledAt,
      ),
    );
  }

  Future<void> _submitPackage(WidgetRef ref, PackageCreateState state) async {
    final uploadedStories = <_UploadedPackageStory>[];
    final ids = _selectedPackageIds(state);
    final packageImageResponse = await _runUploadStep(
      ref,
      'package-image',
      () => UploadApi().uploadPackageImage(
        state.packageImagePath!,
        state.packageImageBytes!,
      ),
    );

    for (var i = 0; i < state.stories.length; i++) {
      uploadedStories.add(
        await _uploadPackageStoryAssets(ref, state.stories[i], i),
      );
    }

    final packageResponse = await _runUploadStep(
      ref,
      'package-create',
      () => StoryApi().createPackage(
        state.packageName!,
        state.packageDescription!,
        packageImageResponse.publicUrl,
        ids.spaceId,
        ids.channelId,
        state.packagePricePodcoin,
        state.packageSinglePricePodcoin,
      ),
    );

    for (var i = 0; i < uploadedStories.length; i++) {
      final uploadedStory = uploadedStories[i];
      await _runUploadStep(
        ref,
        'package-story-create-$i',
        () => StoryApi().createPackageStory(
          packageResponse.packageId,
          uploadedStory.contentUrl,
          uploadedStory.title,
          uploadedStory.description,
          uploadedStory.imageUrls,
          uploadedStory.duration.inMilliseconds,
          (uploadedStory.duration.inMilliseconds / 2).toInt(),
          (uploadedStory.duration.inMilliseconds / 2).toInt() + 20 * 1000,
          "enable",
          null,
          state.scheduledAt,
        ),
      );
    }
  }

  Future<_UploadedStoryAssets> _uploadSingleAssets(
    WidgetRef ref,
    SingleCreateState state,
  ) async {
    final contentResponse = await _runUploadStep(
      ref,
      'single-audio',
      () => UploadApi().uploadStoryContent(
        state.audios[0].fileName,
        state.audios[0].fileBytes,
      ),
    );
    final imageUrls = <String>[];
    for (var i = 0; i < (state.imageFilePaths?.length ?? 0); i++) {
      final imageResponse = await _runUploadStep(
        ref,
        'single-image-$i',
        () => UploadApi().uploadStoryImage(
          state.imageFilePaths![i],
          state.imageFilesBytes![i],
        ),
      );
      imageUrls.add(imageResponse.publicUrl);
    }

    return _UploadedStoryAssets(
      contentUrl: contentResponse.publicUrl,
      imageUrls: imageUrls,
    );
  }

  Future<_UploadedPackageStory> _uploadPackageStoryAssets(
    WidgetRef ref,
    PackageStoryDraft story,
    int storyIndex,
  ) async {
    final audio = story.audio!;
    final contentResponse = await _runUploadStep(
      ref,
      'package-story-audio-$storyIndex',
      () => audio.readStream != null && audio.fileSize > 0
          ? UploadApi().uploadStoryContentStream(
              audio.fileName,
              audio.readStream!,
              audio.fileSize,
            )
          : UploadApi().uploadStoryContent(audio.fileName, audio.fileBytes),
    );
    final imageUrls = <String>[];
    for (var i = 0; i < story.imageFilePaths.length; i++) {
      final imageResponse = await _runUploadStep(
        ref,
        'package-story-image-$storyIndex-$i',
        () => UploadApi().uploadStoryImage(
          story.imageFilePaths[i],
          story.imageFilesBytes[i],
        ),
      );
      imageUrls.add(imageResponse.publicUrl);
    }

    return _UploadedPackageStory(
      title: story.title,
      description: story.description,
      contentUrl: contentResponse.publicUrl,
      imageUrls: imageUrls,
      duration: audio.duration,
    );
  }

  Future<T> _runUploadStep<T>(
    WidgetRef ref,
    String taskId,
    Future<T> Function() action,
  ) async {
    final flowCtrl = ref.read(createFlowControllerProvider.notifier);
    flowCtrl.markUploadActive(taskId);
    try {
      final result = await action();
      flowCtrl.markUploadDone(taskId);
      return result;
    } catch (_) {
      flowCtrl.markUploadFailed(taskId);
      rethrow;
    }
  }

  List<UploadQueueItem> _buildSingleUploadQueue(SingleCreateState state) {
    final items = <UploadQueueItem>[
      UploadQueueItem(
        id: 'single-audio',
        label: '上傳音檔: ${state.audios[0].fileName}',
      ),
    ];

    for (var i = 0; i < (state.imageFilePaths?.length ?? 0); i++) {
      items.add(
        UploadQueueItem(
          id: 'single-image-$i',
          label: '上傳圖片 ${i + 1}: ${state.imageFilePaths![i]}',
        ),
      );
    }

    items.add(
      const UploadQueueItem(id: 'single-publish', label: '建立 Story 資料'),
    );
    return items;
  }

  List<UploadQueueItem> _buildPackageUploadQueue(PackageCreateState state) {
    final items = <UploadQueueItem>[
      UploadQueueItem(
        id: 'package-image',
        label: '上傳套裝圖片: ${state.packageImagePath!}',
      ),
    ];

    for (var i = 0; i < state.stories.length; i++) {
      final story = state.stories[i];
      items.add(
        UploadQueueItem(
          id: 'package-story-audio-$i',
          label: '上傳 Story ${i + 1} 音檔: ${story.audio!.fileName}',
        ),
      );
      for (var j = 0; j < story.imageFilePaths.length; j++) {
        items.add(
          UploadQueueItem(
            id: 'package-story-image-$i-$j',
            label: '上傳 Story ${i + 1} 圖片 ${j + 1}: ${story.imageFilePaths[j]}',
          ),
        );
      }
    }

    items.add(const UploadQueueItem(id: 'package-create', label: '建立套裝資料'));

    for (var i = 0; i < state.stories.length; i++) {
      items.add(
        UploadQueueItem(
          id: 'package-story-create-$i',
          label: '建立 Story ${i + 1} 資料',
        ),
      );
    }

    return items;
  }

  _SelectedIds _selectedSingleIds(SingleCreateState state) {
    final spaceId = state.spaces
        .where((space) => space.name == state.selectedSpace)
        .first
        .spaceId;
    final channelId = state.channels
        .where((channel) => channel.channelName == state.selectedChannel)
        .first
        .channelId;
    return _SelectedIds(spaceId: spaceId, channelId: channelId);
  }

  _SelectedIds _selectedPackageIds(PackageCreateState state) {
    final spaceId = state.spaces
        .where((space) => space.name == state.selectedSpace)
        .first
        .spaceId;
    final channelId = state.channels
        .where((channel) => channel.channelName == state.selectedChannel)
        .first
        .channelId;
    return _SelectedIds(spaceId: spaceId, channelId: channelId);
  }
}

class _UploadedStoryAssets {
  final String contentUrl;
  final List<String> imageUrls;

  const _UploadedStoryAssets({
    required this.contentUrl,
    required this.imageUrls,
  });
}

class _SelectedIds {
  final String spaceId;
  final String channelId;

  const _SelectedIds({required this.spaceId, required this.channelId});
}

class _UploadedPackageStory {
  final String title;
  final String description;
  final String contentUrl;
  final List<String> imageUrls;
  final Duration duration;

  const _UploadedPackageStory({
    required this.title,
    required this.description,
    required this.contentUrl,
    required this.imageUrls,
    required this.duration,
  });
}
