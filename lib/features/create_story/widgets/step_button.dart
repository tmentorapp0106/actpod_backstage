import 'package:actpod_studio/api/response/story_response/create_package.dart';
import 'package:actpod_studio/api/response/story_response/create_package_story.dart';
import 'package:actpod_studio/api/response/story_response/package_models.dart';
import 'package:actpod_studio/api/response/story_response/update_package.dart';
import 'package:actpod_studio/api/response/story_response/update_package_story.dart';
import 'package:actpod_studio/api/response/story_response/upload_story.dart';
import 'package:actpod_studio/api/response/upload_response/upload_package_image.dart';
import 'package:actpod_studio/api/response/upload_response/upload_story_content.dart';
import 'package:actpod_studio/api/response/upload_response/upload_story_image.dart';
import 'package:actpod_studio/api/story_system_api.dart';
import 'package:actpod_studio/api/upload_system_api.dart';
import 'package:actpod_studio/features/create_story/const.dart';
import 'package:actpod_studio/features/create_story/controllers/create_flow_controller.dart';
import 'package:actpod_studio/features/create_story/controllers/package_create_controller.dart';
import 'package:actpod_studio/features/create_story/controllers/create_shared_models.dart';
import 'package:actpod_studio/features/create_story/controllers/package_edit_controller.dart';
import 'package:actpod_studio/features/create_story/controllers/single_create_controller.dart';
import 'package:actpod_studio/features/create_story/controllers/user_controller.dart';
import 'package:actpod_studio/features/create_story/widgets/step_nav_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

const _useMockUpload = bool.fromEnvironment(
  'MOCK_STORY_UPLOAD',
  defaultValue: false,
);

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

    if (flow.flowType == CreateFlowType.editPackage) {
      final packageState = ref.watch(packageCreateControllerProvider);
      final editState = ref.watch(packageEditControllerProvider);
      switch (stepIndex) {
        case 1:
          return editState.selectedPackageId != null &&
              editState.selectedPackageId!.isNotEmpty;
        case 2:
          return packageState.hasValidPackageInfo;
        case 3:
          return packageState.hasValidStories;
        case 4:
          return packageState.probingDurationStoryIds.isEmpty;
        default:
          return false;
      }
    }

    if (flow.flowType == CreateFlowType.package) {
      final packageState = ref.watch(packageCreateControllerProvider);
      switch (stepIndex) {
        case 1:
          return packageState.hasValidPackageInfo;
        case 2:
          return packageState.hasValidStories;
        case 3:
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
        return singleState.probingDurationAudioIds.isEmpty;
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
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final flowCtrl = ref.read(createFlowControllerProvider.notifier);
    final flow = ref.read(createFlowControllerProvider);
    final packageCtrl = ref.read(packageCreateControllerProvider.notifier);
    final packageEditCtrl = ref.read(packageEditControllerProvider.notifier);
    final singleCtrl = ref.read(singleCreateControllerProvider.notifier);

    if ((flow.flowType == CreateFlowType.package ||
            flow.flowType == CreateFlowType.editPackage) &&
        ref
            .read(packageCreateControllerProvider)
            .probingDurationStoryIds
            .isNotEmpty) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('音檔時長解析中，完成後才能發布')),
      );
      return;
    }

    if (flow.flowType != CreateFlowType.package &&
        flow.flowType != CreateFlowType.editPackage &&
        ref
            .read(singleCreateControllerProvider)
            .probingDurationAudioIds
            .isNotEmpty) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('音檔時長解析中，完成後才能發布')),
      );
      return;
    }

    if (flow.flowType == CreateFlowType.editPackage) {
      flowCtrl.beginUploadQueue(
        _buildEditPackageUploadQueue(ref.read(packageCreateControllerProvider)),
      );
    } else if (flow.flowType == CreateFlowType.package) {
      flowCtrl.beginUploadQueue(
        _buildPackageUploadQueue(ref.read(packageCreateControllerProvider)),
      );
    } else {
      flowCtrl.beginUploadQueue(
        _buildSingleUploadQueue(ref.read(singleCreateControllerProvider)),
      );
    }

    final submittedFlowType = flow.flowType;
    var submittedSuccessfully = false;

    try {
      if (flow.flowType == CreateFlowType.editPackage) {
        await _submitEditPackage(
          flowCtrl,
          ref.read(packageCreateControllerProvider),
          ref.read(packageEditControllerProvider).selectedPackageId,
        );
      } else if (flow.flowType == CreateFlowType.package) {
        await _submitPackage(
          flowCtrl,
          ref.read(packageCreateControllerProvider),
          ref.read(userControllerProvider)?.userId ?? '',
        );
      } else {
        await _submitSingle(flowCtrl, ref.read(singleCreateControllerProvider));
      }

      submittedSuccessfully = true;
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('已提交發布')));
    } catch (e, st) {
      debugPrint('發布失敗：$e');
      debugPrint(st.toString());
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('發布失敗：$e')));
    } finally {
      flowCtrl.clearUploadQueue();

      if (submittedSuccessfully) {
        router.go('/publish/0');
      }

      if (submittedSuccessfully) {
        if (submittedFlowType == CreateFlowType.editPackage) {
          packageCtrl.clear();
          packageEditCtrl.clear();
        } else if (submittedFlowType == CreateFlowType.package) {
          packageCtrl.clear();
        } else {
          singleCtrl.clear();
        }
        flowCtrl.clear();
      }
    }
  }

  Future<void> _submitSingle(
    CreateFlowController flowCtrl,
    SingleCreateState state,
  ) async {
    final uploaded = await _uploadSingleAssets(flowCtrl, state);
    final ids = _selectedSingleIds(state);

    await _runUploadStep(
      flowCtrl,
      'single-publish',
      () => _uploadStory(
        ids.spaceId,
        ids.channelId,
        uploaded.contentUrl,
        state.title!,
        state.description!,
        uploaded.imageUrls,
        uploaded.duration.inMilliseconds,
        (uploaded.duration.inMilliseconds / 2).toInt(),
        (uploaded.duration.inMilliseconds / 2).toInt() + 20 * 1000,
        "enable",
        state.pricePodcoin > 0 || state.priceTwd > 0,
        state.pricePodcoin,
        state.priceTwd,
        state.isAdult,
        state.collaborator?.userId,
        state.scheduledAt,
      ),
    );
  }

  Future<void> _submitPackage(
    CreateFlowController flowCtrl,
    PackageCreateState state,
    String userId,
  ) async {
    final uploadedStories = <_UploadedPackageStory>[];
    final packageImageResponse = await _runUploadStep(
      flowCtrl,
      'package-image',
      () => _uploadPackageImage(
        state.packageImagePath!,
        state.packageImageBytes!,
      ),
    );
    final coverImageResponse = await _runUploadStep(
      flowCtrl,
      'cover-image',
      () => _uploadPackageImage(state.coverImagePath!, state.coverImageBytes!),
    );

    for (var i = 0; i < state.stories.length; i++) {
      uploadedStories.add(
        await _uploadPackageStoryAssets(flowCtrl, state.stories[i], i),
      );
    }

    final packageResponse = await _runUploadStep(
      flowCtrl,
      'package-create',
      () => _createPackage(
        userId,
        state.packageName!,
        state.packageDescription!,
        packageImageResponse.publicUrl,
        coverImageResponse.publicUrl,
        state.packagePrices,
      ),
    );

    for (var i = 0; i < uploadedStories.length; i++) {
      final uploadedStory = uploadedStories[i];
      final ids = _selectedPackageStoryIds(state, uploadedStory);
      await _runUploadStep(
        flowCtrl,
        'package-story-create-$i',
        () => _createPackageStory(
          packageResponse.packageId,
          uploadedStory.contentUrl,
          uploadedStory.title,
          uploadedStory.description,
          uploadedStory.imageUrls,
          uploadedStory.duration.inMilliseconds,
          _previewStart(uploadedStory.duration),
          _previewEnd(uploadedStory.duration),
          "enable",
          uploadedStory.packageNote,
          ids.channelId,
          ids.spaceId,
          null,
          uploadedStory.podcoins,
          uploadedStory.twd,
        ),
      );
    }
  }

  Future<void> _submitEditPackage(
    CreateFlowController flowCtrl,
    PackageCreateState state,
    String? selectedPackageId,
  ) async {
    final packageId = selectedPackageId;
    if (packageId == null || packageId.isEmpty) {
      throw StateError('missing package id');
    }

    var packageImageUrl = state.packageImageUrl ?? '';
    var coverImageUrl = state.coverImageUrl ?? '';
    if (state.packageImageBytes != null) {
      final packageImageResponse = await _runUploadStep(
        flowCtrl,
        'package-image',
        () => _uploadPackageImage(
          state.packageImagePath!,
          state.packageImageBytes!,
        ),
      );
      packageImageUrl = packageImageResponse.publicUrl;
    }
    if (state.coverImageBytes != null) {
      final coverImageResponse = await _runUploadStep(
        flowCtrl,
        'cover-image',
        () =>
            _uploadPackageImage(state.coverImagePath!, state.coverImageBytes!),
      );
      coverImageUrl = coverImageResponse.publicUrl;
    }

    await _runUploadStep(
      flowCtrl,
      'package-update',
      () => _updatePackage(
        packageId,
        state.packageName!,
        state.packageDescription!,
        packageImageUrl,
        coverImageUrl,
        state.packagePrices,
      ),
    );

    for (var i = 0; i < state.stories.length; i++) {
      final story = state.stories[i];
      final uploadedStory = await _uploadEditPackageStoryAssets(
        flowCtrl,
        story,
        i,
      );

      if (story.isExisting) {
        await _runUploadStep(
          flowCtrl,
          'package-story-update-$i',
          () => _updatePackageStory(
            story.storyId,
            packageId,
            uploadedStory.contentUrl,
            uploadedStory.title,
            uploadedStory.description,
            uploadedStory.imageUrls,
            uploadedStory.duration.inMilliseconds,
            uploadedStory.previewStartFrom,
            uploadedStory.previewEndAt,
            uploadedStory.packageNote,
            story.collaboratorId,
            story.shouldUpdateStoryAudio,
          ),
        );
      } else {
        final ids = _selectedPackageStoryIds(state, uploadedStory);
        await _runUploadStep(
          flowCtrl,
          'package-story-create-$i',
          () => _createPackageStory(
            packageId,
            uploadedStory.contentUrl,
            uploadedStory.title,
            uploadedStory.description,
            uploadedStory.imageUrls,
            uploadedStory.duration.inMilliseconds,
            _previewStart(uploadedStory.duration),
            _previewEnd(uploadedStory.duration),
            "enable",
            uploadedStory.packageNote,
            ids.channelId,
            ids.spaceId,
            story.collaboratorId.isEmpty ? null : story.collaboratorId,
            uploadedStory.podcoins,
            uploadedStory.twd,
          ),
        );
      }
    }
  }

  Future<_UploadedStoryAssets> _uploadSingleAssets(
    CreateFlowController flowCtrl,
    SingleCreateState state,
  ) async {
    _PreparedUploadAudio? preparedAudio;
    final contentResponse = await _runUploadStep(
      flowCtrl,
      'single-audio',
      () async {
        preparedAudio = await _prepareAudioForUpload(state.audios[0]);
        final audio = preparedAudio!;
        return audio.readStream != null && audio.fileSize > 0
            ? _uploadStoryContentStream(
                audio.fileName,
                audio.readStream!,
                audio.fileSize,
              )
            : _uploadStoryContent(audio.fileName, audio.fileBytes);
      },
    );
    final imageUrls = <String>[];
    for (var i = 0; i < (state.imageFilePaths?.length ?? 0); i++) {
      final imageResponse = await _runUploadStep(
        flowCtrl,
        'single-image-$i',
        () => _uploadStoryImage(
          state.imageFilePaths![i],
          state.imageFilesBytes![i],
        ),
      );
      imageUrls.add(imageResponse.publicUrl);
    }

    return _UploadedStoryAssets(
      contentUrl: contentResponse.publicUrl,
      imageUrls: imageUrls,
      duration: preparedAudio?.duration ?? Duration.zero,
    );
  }

  Future<_UploadedPackageStory> _uploadPackageStoryAssets(
    CreateFlowController flowCtrl,
    PackageStoryDraft story,
    int storyIndex,
  ) async {
    var contentUrl = '';
    var duration = Duration.zero;
    final audio = story.audio;
    if (audio != null) {
      final contentResponse = await _runUploadStep(
        flowCtrl,
        'package-story-audio-$storyIndex',
        () => audio.readStream != null && audio.fileSize > 0
            ? _uploadStoryContentStream(
                audio.fileName,
                audio.readStream!,
                audio.fileSize,
              )
            : _uploadStoryContent(audio.fileName, audio.fileBytes),
      );
      contentUrl = contentResponse.publicUrl;
      duration = audio.duration;
    }

    final imageUrls = <String>[];
    for (var i = 0; i < story.imageFilePaths.length; i++) {
      final imageResponse = await _runUploadStep(
        flowCtrl,
        'package-story-image-$storyIndex-$i',
        () => _uploadStoryImage(
          story.imageFilePaths[i],
          story.imageFilesBytes[i],
        ),
      );
      imageUrls.add(imageResponse.publicUrl);
    }

    return _UploadedPackageStory(
      title: story.title,
      description: story.description,
      packageNote: story.packageNote,
      selectedSpace: story.selectedSpace,
      selectedChannel: story.selectedChannel,
      podcoins: story.podcoins,
      twd: story.twd,
      contentUrl: contentUrl,
      imageUrls: imageUrls,
      duration: duration,
    );
  }

  Future<_UploadedPackageStory> _uploadEditPackageStoryAssets(
    CreateFlowController flowCtrl,
    PackageStoryDraft story,
    int storyIndex,
  ) async {
    var contentUrl = story.contentUrl;
    var duration = Duration(milliseconds: story.storyMilliSec);
    final audio = story.audio;
    if (audio != null) {
      final contentResponse = await _runUploadStep(
        flowCtrl,
        'package-story-audio-$storyIndex',
        () => audio.readStream != null && audio.fileSize > 0
            ? _uploadStoryContentStream(
                audio.fileName,
                audio.readStream!,
                audio.fileSize,
              )
            : _uploadStoryContent(audio.fileName, audio.fileBytes),
      );
      contentUrl = contentResponse.publicUrl;
      duration = audio.duration;
    } else if (story.shouldUpdateStoryAudio && contentUrl.isEmpty) {
      duration = Duration.zero;
    }

    final imageUrls = <String>[];
    if (story.imageFilesBytes.isEmpty) {
      imageUrls.addAll(story.remoteImageUrls);
    } else {
      for (var i = 0; i < story.imageFilePaths.length; i++) {
        final imageResponse = await _runUploadStep(
          flowCtrl,
          'package-story-image-$storyIndex-$i',
          () => _uploadStoryImage(
            story.imageFilePaths[i],
            story.imageFilesBytes[i],
          ),
        );
        imageUrls.add(imageResponse.publicUrl);
      }
    }

    return _UploadedPackageStory(
      title: story.title,
      description: story.description,
      packageNote: story.packageNote,
      selectedSpace: story.selectedSpace,
      selectedChannel: story.selectedChannel,
      podcoins: story.podcoins,
      twd: story.twd,
      contentUrl: contentUrl,
      imageUrls: imageUrls,
      duration: duration,
      previewStartFrom: audio == null
          ? (contentUrl.isEmpty ? 0 : story.previewStartFrom)
          : _previewStart(duration),
      previewEndAt: audio == null
          ? (contentUrl.isEmpty ? 0 : story.previewEndAt)
          : _previewEnd(duration),
    );
  }

  Future<T> _runUploadStep<T>(
    CreateFlowController flowCtrl,
    String taskId,
    Future<T> Function() action,
  ) async {
    flowCtrl.markUploadActive(taskId);
    await Future<void>.delayed(Duration.zero);
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
      UploadQueueItem(
        id: 'cover-image',
        label: '上傳封面圖: ${state.coverImagePath!}',
      ),
    ];

    for (var i = 0; i < state.stories.length; i++) {
      final story = state.stories[i];
      if (story.audio != null) {
        items.add(
          UploadQueueItem(
            id: 'package-story-audio-$i',
            label: '上傳 Story ${i + 1} 音檔: ${story.audio!.fileName}',
          ),
        );
      }
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

  List<UploadQueueItem> _buildEditPackageUploadQueue(PackageCreateState state) {
    final items = <UploadQueueItem>[];

    if (state.packageImageBytes != null) {
      items.add(
        UploadQueueItem(
          id: 'package-image',
          label: '上傳套裝圖片: ${state.packageImagePath!}',
        ),
      );
    }
    if (state.coverImageBytes != null) {
      items.add(
        UploadQueueItem(
          id: 'cover-image',
          label: '上傳封面圖: ${state.coverImagePath!}',
        ),
      );
    }

    items.add(const UploadQueueItem(id: 'package-update', label: '更新套裝資料'));

    for (var i = 0; i < state.stories.length; i++) {
      final story = state.stories[i];
      if (story.audio != null) {
        items.add(
          UploadQueueItem(
            id: 'package-story-audio-$i',
            label: '上傳 Story ${i + 1} 音檔: ${story.audio!.fileName}',
          ),
        );
      }
      for (var j = 0; j < story.imageFilePaths.length; j++) {
        items.add(
          UploadQueueItem(
            id: 'package-story-image-$i-$j',
            label: '上傳 Story ${i + 1} 圖片 ${j + 1}: ${story.imageFilePaths[j]}',
          ),
        );
      }
      items.add(
        UploadQueueItem(
          id: story.isExisting
              ? 'package-story-update-$i'
              : 'package-story-create-$i',
          label: story.isExisting
              ? '更新 Story ${i + 1} 資料'
              : '建立 Story ${i + 1} 資料',
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

  _SelectedIds _selectedPackageStoryIds(
    PackageCreateState state,
    _UploadedPackageStory story,
  ) {
    final spaceId = state.spaces
        .where((space) => space.name == story.selectedSpace)
        .first
        .spaceId;
    final channelId = state.channels
        .where((channel) => channel.channelName == story.selectedChannel)
        .first
        .channelId;
    return _SelectedIds(spaceId: spaceId, channelId: channelId);
  }

  int _previewStart(Duration duration) {
    if (duration == Duration.zero) return 0;
    return (duration.inMilliseconds / 2).toInt();
  }

  int _previewEnd(Duration duration) {
    if (duration == Duration.zero) return 0;
    return _previewStart(duration) + 20 * 1000;
  }

  Future<_PreparedUploadAudio> _prepareAudioForUpload(
    UploadedAudio audio,
  ) async {
    if (audio.duration != Duration.zero &&
        audio.readStream != null &&
        audio.fileSize > 0) {
      return _PreparedUploadAudio(
        fileName: audio.fileName,
        fileBytes: Uint8List(0),
        readStream: audio.readStream,
        fileSize: audio.fileSize,
        duration: audio.duration,
      );
    }

    if (!kIsWeb && _hasRealFilePath(audio)) {
      final duration = audio.duration == Duration.zero
          ? await _probeDurationFromFilePath(audio.path)
          : audio.duration;
      return _PreparedUploadAudio(
        fileName: audio.fileName,
        fileBytes: Uint8List(0),
        readStream: audio.readStream,
        fileSize: audio.fileSize,
        duration: duration,
      );
    }

    if (audio.fileBytes.isNotEmpty) {
      final duration = audio.duration == Duration.zero
          ? await _probeDurationFromBytes(audio.fileBytes, audio.fileName)
          : audio.duration;
      return _PreparedUploadAudio(
        fileName: audio.fileName,
        fileBytes: audio.fileBytes,
        fileSize: audio.fileBytes.length,
        duration: duration,
      );
    }

    if (audio.readStream != null) {
      final bytes = await _readAllBytes(audio.readStream!);
      final duration = audio.duration == Duration.zero
          ? await _probeDurationFromBytes(bytes, audio.fileName)
          : audio.duration;
      return _PreparedUploadAudio(
        fileName: audio.fileName,
        fileBytes: bytes,
        fileSize: bytes.length,
        duration: duration,
      );
    }

    return _PreparedUploadAudio(
      fileName: audio.fileName,
      fileBytes: audio.fileBytes,
      fileSize: audio.fileSize,
      duration: audio.duration,
    );
  }

  Future<Duration> _probeDurationFromFilePath(String path) async {
    final player = AudioPlayer();
    try {
      await player.setFilePath(path);
      var duration = player.duration ?? Duration.zero;
      if (duration == Duration.zero) {
        final streamDuration = await player.durationStream
            .firstWhere((d) => d != null)
            .timeout(const Duration(seconds: 3), onTimeout: () => null);
        duration = streamDuration ?? Duration.zero;
      }
      return duration;
    } catch (_) {
      return Duration.zero;
    } finally {
      await player.dispose();
    }
  }

  Future<Duration> _probeDurationFromBytes(
    Uint8List bytes,
    String fileName,
  ) async {
    final player = AudioPlayer();
    try {
      await player.setUrl(
        Uri.dataFromBytes(bytes, mimeType: _mimeFromName(fileName)).toString(),
      );
      var duration = player.duration ?? Duration.zero;
      if (duration == Duration.zero) {
        final streamDuration = await player.durationStream
            .firstWhere((d) => d != null)
            .timeout(const Duration(seconds: 3), onTimeout: () => null);
        duration = streamDuration ?? Duration.zero;
      }
      return duration;
    } catch (_) {
      return Duration.zero;
    } finally {
      await player.dispose();
    }
  }

  Future<Uint8List> _readAllBytes(Stream<List<int>> stream) async {
    final chunks = <int>[];
    await for (final chunk in stream) {
      chunks.addAll(chunk);
    }
    return Uint8List.fromList(chunks);
  }

  bool _hasRealFilePath(UploadedAudio audio) {
    return audio.path.isNotEmpty && audio.path != audio.fileName;
  }

  String _mimeFromName(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'mp3':
        return 'audio/mpeg';
      case 'm4a':
        return 'audio/mp4';
      case 'aac':
        return 'audio/aac';
      case 'wav':
        return 'audio/wav';
      case 'flac':
        return 'audio/flac';
      case 'ogg':
        return 'audio/ogg';
      default:
        return 'application/octet-stream';
    }
  }

  Future<UploadStoryContentResponse> _uploadStoryContent(
    String fileName,
    Uint8List fileBytes,
  ) async {
    if (!_useMockUpload) {
      return UploadApi().uploadStoryContent(fileName, fileBytes);
    }
    await Future.delayed(const Duration(milliseconds: 900));
    return UploadStoryContentResponse(
      code: '200',
      message: 'mock success',
      signedUrl: 'https://mock.local/upload/$fileName',
      publicUrl: 'https://mock.local/story-content/$fileName',
    );
  }

  Future<UploadStoryContentResponse> _uploadStoryContentStream(
    String fileName,
    Stream<List<int>> stream,
    int contentLength,
  ) async {
    if (!_useMockUpload) {
      return UploadApi().uploadStoryContentStream(
        fileName,
        stream,
        contentLength,
      );
    }
    await Future.delayed(const Duration(milliseconds: 900));
    return UploadStoryContentResponse(
      code: '200',
      message: 'mock success',
      signedUrl: 'https://mock.local/upload/$fileName',
      publicUrl: 'https://mock.local/story-content/$fileName',
    );
  }

  Future<UploadStoryImageResponse> _uploadStoryImage(
    String fileName,
    Uint8List fileBytes,
  ) async {
    if (!_useMockUpload) {
      return UploadApi().uploadStoryImage(fileName, fileBytes);
    }
    await Future.delayed(const Duration(milliseconds: 700));
    return UploadStoryImageResponse(
      code: '200',
      message: 'mock success',
      signedUrl: 'https://mock.local/upload/$fileName',
      publicUrl: 'https://mock.local/story-image/$fileName',
    );
  }

  Future<UploadPackageImageResponse> _uploadPackageImage(
    String fileName,
    Uint8List fileBytes,
  ) async {
    if (!_useMockUpload) {
      return UploadApi().uploadPackageImage(fileName, fileBytes);
    }
    await Future.delayed(const Duration(milliseconds: 700));
    return UploadPackageImageResponse(
      code: '200',
      message: 'mock success',
      signedUrl: 'https://mock.local/upload/$fileName',
      publicUrl: 'https://mock.local/package-image/$fileName',
    );
  }

  Future<UploadStoryResponse> _uploadStory(
    String spaceId,
    String channelId,
    String contentUrl,
    String storyName,
    String storyDescription,
    List<String> storyImageUrls,
    int storyMilliSec,
    int previewStartFrom,
    int previewEndAt,
    String voiceMessageStatus,
    bool isPremium,
    int podcoins,
    int twd,
    bool isAdult,
    String? collaboratorId,
    DateTime? releaseTime,
  ) async {
    if (!_useMockUpload) {
      return StoryApi().uploadStory(
        spaceId,
        channelId,
        contentUrl,
        storyName,
        storyDescription,
        storyImageUrls,
        storyMilliSec,
        previewStartFrom,
        previewEndAt,
        voiceMessageStatus,
        isPremium,
        podcoins,
        twd,
        isAdult,
        collaboratorId,
        releaseTime,
      );
    }
    await Future.delayed(const Duration(milliseconds: 1200));
    return const UploadStoryResponse(
      code: '200',
      message: 'mock success',
      storyId: 'mock-story-id',
    );
  }

  Future<CreatePackageResponse> _createPackage(
    String userId,
    String packageName,
    String packageDescription,
    String packageImageUrl,
    String coverImageUrl,
    List<PackagePriceDraft> packagePrices,
  ) async {
    if (!_useMockUpload) {
      return StoryApi().createPackage(
        userId,
        packageName,
        packageDescription,
        packageImageUrl,
        coverImageUrl,
        packagePrices
            .map(
              (price) => PackagePrice(
                packagePriceId: '',
                priceType: "package",
                lable: price.lable,
                podcoins: price.podcoins,
                twd: price.twd,
                isActive: price.isActive,
              ),
            )
            .toList(),
      );
    }
    await Future.delayed(const Duration(milliseconds: 1200));
    return const CreatePackageResponse(
      code: '200',
      message: 'mock success',
      packageId: 'mock-package-id',
    );
  }

  Future<CreatePackageStoryResponse> _createPackageStory(
    String packageId,
    String contentUrl,
    String storyName,
    String storyDescription,
    List<String> storyImageUrls,
    int storyMilliSec,
    int previewStartFrom,
    int previewEndAt,
    String voiceMessageStatus,
    String packageNote,
    String channelId,
    String spaceId,
    String? collaboratorId,
    int podcoins,
    int twd,
  ) async {
    if (!_useMockUpload) {
      return StoryApi().createPackageStory(
        packageId,
        contentUrl,
        storyName,
        storyDescription,
        storyImageUrls,
        storyMilliSec,
        previewStartFrom,
        previewEndAt,
        voiceMessageStatus,
        packageNote,
        channelId,
        spaceId,
        collaboratorId,
        podcoins,
        twd,
      );
    }
    await Future.delayed(const Duration(milliseconds: 1200));
    return const CreatePackageStoryResponse(
      code: '200',
      message: 'mock success',
      storyId: 'mock-package-story-id',
    );
  }

  Future<UpdatePackageResponse> _updatePackage(
    String packageId,
    String packageName,
    String packageDescription,
    String packageImageUrl,
    String coverImageUrl,
    List<PackagePriceDraft> packagePrices,
  ) async {
    if (!_useMockUpload) {
      return StoryApi().updatePackage(
        packageId,
        packageName,
        packageDescription,
        packageImageUrl,
        coverImageUrl,
        packagePrices
            .map(
              (price) => PackagePrice(
                packagePriceId: price.packagePriceId,
                priceType: "package",
                lable: price.lable,
                podcoins: price.podcoins,
                twd: price.twd,
                isActive: price.isActive,
              ),
            )
            .toList(),
      );
    }
    await Future.delayed(const Duration(milliseconds: 1200));
    return const UpdatePackageResponse(code: '200', message: 'mock success');
  }

  Future<UpdatePackageStoryResponse> _updatePackageStory(
    String storyId,
    String packageId,
    String contentUrl,
    String storyName,
    String storyDescription,
    List<String> storyImageUrls,
    int storyMilliSec,
    int previewStartFrom,
    int previewEndAt,
    String packageNote,
    String collaboratorId,
    bool updateStory,
  ) async {
    if (!_useMockUpload) {
      return StoryApi().updatePackageStory(
        storyId,
        packageId,
        contentUrl,
        storyName,
        storyDescription,
        storyImageUrls,
        storyMilliSec,
        previewStartFrom,
        previewEndAt,
        packageNote,
        collaboratorId,
        updateStory,
      );
    }
    await Future.delayed(const Duration(milliseconds: 1200));
    return const UpdatePackageStoryResponse(
      code: '200',
      message: 'mock success',
    );
  }
}

class _UploadedStoryAssets {
  final String contentUrl;
  final List<String> imageUrls;
  final Duration duration;

  const _UploadedStoryAssets({
    required this.contentUrl,
    required this.imageUrls,
    required this.duration,
  });
}

class _SelectedIds {
  final String spaceId;
  final String channelId;

  const _SelectedIds({required this.spaceId, required this.channelId});
}

class _PreparedUploadAudio {
  final String fileName;
  final Uint8List fileBytes;
  final Stream<List<int>>? readStream;
  final int fileSize;
  final Duration duration;

  const _PreparedUploadAudio({
    required this.fileName,
    required this.fileBytes,
    this.readStream,
    required this.fileSize,
    required this.duration,
  });
}

class _UploadedPackageStory {
  final String title;
  final String description;
  final String packageNote;
  final String? selectedSpace;
  final String? selectedChannel;
  final int podcoins;
  final int twd;
  final String contentUrl;
  final List<String> imageUrls;
  final Duration duration;
  final int previewStartFrom;
  final int previewEndAt;

  const _UploadedPackageStory({
    required this.title,
    required this.description,
    required this.packageNote,
    required this.selectedSpace,
    required this.selectedChannel,
    required this.podcoins,
    required this.twd,
    required this.contentUrl,
    required this.imageUrls,
    required this.duration,
    this.previewStartFrom = 0,
    this.previewEndAt = 0,
  });
}
