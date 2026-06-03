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

class StepButton extends ConsumerWidget {
  final int stepIndex;
  final List<PublishStep> steps;

  const StepButton({super.key, required this.stepIndex, required this.steps});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(createFlowControllerProvider);
    final flowCtrl = ref.read(createFlowControllerProvider.notifier);
    final isSaving = flow.isSaving;
    final canNext = _canNext(ref, flow, stepIndex);

    return Align(
      alignment: Alignment.centerRight,
      child: StepNavBar(
        showPrev: stepIndex > 0 && !isSaving,
        nextLabel: _nextLabel(stepIndex),
        isLast: stepIndex == steps.length - 1,
        busy: isSaving,
        disableNext: isSaving || !canNext,
        onPrev: () {
          if (stepIndex > 0) {
            flowCtrl.back();
            context.go('/publish/${flow.currentPage - 1}');
          }
        },
        onNext: () {
          if (stepIndex < steps.length - 1) {
            if (!canNext) return;
            flowCtrl.next(steps.length);
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
          return true;
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
    if (i < steps.length - 2) return '下一步';
    if (i == steps.length - 2) return '進入預覽畫面';
    return '發布';
  }

  void _submit(BuildContext context, WidgetRef ref) async {
    final flowCtrl = ref.read(createFlowControllerProvider.notifier);
    flowCtrl.setSaving(true);

    try {
      final flow = ref.read(createFlowControllerProvider);
      if (flow.flowType == CreateFlowType.package) {
        await _submitPackage(ref.read(packageCreateControllerProvider));
        ref.read(packageCreateControllerProvider.notifier).clear();
      } else {
        await _submitSingle(ref.read(singleCreateControllerProvider));
        ref.read(singleCreateControllerProvider.notifier).clear();
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已提交發布')));
    } catch (e, st) {
      debugPrint('發布失敗：$e');
      debugPrint(st.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('發布失敗：$e')));
    } finally {
      flowCtrl.setSaving(false);
      flowCtrl.clear();
      GoRouter.of(context).go('/publish/0');
    }
  }

  Future<void> _submitSingle(SingleCreateState state) async {
    final uploaded = await _uploadSingleAssets(state);
    final ids = _selectedSingleIds(state);

    await StoryApi().uploadStory(
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
    );
  }

  Future<void> _submitPackage(PackageCreateState state) async {
    final ids = _selectedPackageIds(state);
    final uploadedStories = <_UploadedPackageStory>[];

    for (final story in state.stories) {
      uploadedStories.add(await _uploadPackageStoryAssets(story));
    }

    final packageResponse = await StoryApi().createPackage(
      state.packageName!,
      state.packageDescription!,
      uploadedStories.first.imageUrls.isNotEmpty
          ? uploadedStories.first.imageUrls.first
          : '',
      ids.spaceId,
      ids.channelId,
      state.packagePricePodcoin,
      state.packageSoloPricePodcoin,
    );

    for (final uploadedStory in uploadedStories) {
      await StoryApi().createPackageStory(
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
      );
    }
  }

  Future<_UploadedStoryAssets> _uploadSingleAssets(
    SingleCreateState state,
  ) async {
    final contentResponse = await UploadApi().uploadStoryContent(
      state.audios[0].fileName,
      state.audios[0].fileBytes,
    );
    final uploadImageFutures = List.generate(
      state.imageFilePaths?.length ?? 0,
      (i) => UploadApi().uploadStoryImage(
        state.imageFilePaths![i],
        state.imageFilesBytes![i],
      ),
    );
    final imageResponses = await Future.wait(uploadImageFutures);
    final imageUrls = imageResponses
        .map((response) => response.publicUrl)
        .toList();

    return _UploadedStoryAssets(
      contentUrl: contentResponse.publicUrl,
      imageUrls: imageUrls,
    );
  }

  Future<_UploadedPackageStory> _uploadPackageStoryAssets(
    PackageStoryDraft story,
  ) async {
    final audio = story.audio!;
    final contentResponse = await UploadApi().uploadStoryContent(
      audio.fileName,
      audio.fileBytes,
    );
    final uploadImageFutures = List.generate(
      story.imageFilePaths.length,
      (i) => UploadApi().uploadStoryImage(
        story.imageFilePaths[i],
        story.imageFilesBytes[i],
      ),
    );
    final imageResponses = await Future.wait(uploadImageFutures);
    final imageUrls = imageResponses
        .map((response) => response.publicUrl)
        .toList();

    return _UploadedPackageStory(
      title: story.title,
      description: story.description,
      contentUrl: contentResponse.publicUrl,
      imageUrls: imageUrls,
      duration: audio.duration,
    );
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
