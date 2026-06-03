import 'package:actpod_studio/api/channel_system_api.dart';
import 'package:actpod_studio/api/space_system_api.dart';
import 'package:actpod_studio/features/create_story/controllers/create_shared_models.dart';
import 'package:actpod_studio/features/create_story/models/channel_model.dart';
import 'package:actpod_studio/features/create_story/models/space_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

@immutable
class PackageStoryDraft {
  final String id;
  final String title;
  final String description;
  final UploadedAudio? audio;
  final List<String> imageFilePaths;
  final List<Uint8List> imageFilesBytes;

  const PackageStoryDraft({
    required this.id,
    this.title = '',
    this.description = '',
    this.audio,
    this.imageFilePaths = const [],
    this.imageFilesBytes = const [],
  });

  bool get isComplete {
    return title.trim().isNotEmpty &&
        description.trim().isNotEmpty &&
        audio != null &&
        imageFilesBytes.isNotEmpty;
  }

  PackageStoryDraft copyWith({
    String? title,
    String? description,
    UploadedAudio? audio,
    List<String>? imageFilePaths,
    List<Uint8List>? imageFilesBytes,
  }) {
    return PackageStoryDraft(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      audio: audio ?? this.audio,
      imageFilePaths: imageFilePaths ?? this.imageFilePaths,
      imageFilesBytes: imageFilesBytes ?? this.imageFilesBytes,
    );
  }
}

@immutable
class PackageCreateState {
  final String? packageName;
  final String? packageDescription;
  final int packagePricePodcoin;
  final int packageSoloPricePodcoin;
  final List<Space> spaces;
  final String? selectedSpace;
  final List<Channel> channels;
  final String? selectedChannel;
  final List<PackageStoryDraft> stories;
  final bool uploadingAudio;
  final PublishMode publishMode;
  final DateTime? scheduledAt;
  final String? error;

  const PackageCreateState({
    this.packageName,
    this.packageDescription,
    this.packagePricePodcoin = 0,
    this.packageSoloPricePodcoin = 0,
    this.spaces = const [],
    this.selectedSpace,
    this.channels = const [],
    this.selectedChannel,
    this.stories = const [],
    this.uploadingAudio = false,
    this.publishMode = PublishMode.now,
    this.scheduledAt,
    this.error,
  });

  bool get hasValidPackageInfo {
    return (packageName != null && packageName!.trim().isNotEmpty) &&
        (packageDescription != null && packageDescription!.trim().isNotEmpty) &&
        (selectedSpace != null && selectedSpace!.isNotEmpty) &&
        (selectedChannel != null && selectedChannel!.isNotEmpty) &&
        packagePricePodcoin >= 0 &&
        packageSoloPricePodcoin >= 0;
  }

  bool get hasValidStories {
    return stories.isNotEmpty && stories.every((story) => story.isComplete);
  }

  bool get hasValidSettings {
    if (publishMode == PublishMode.schedule) return scheduledAt != null;
    return true;
  }

  PackageCreateState copyWith({
    String? packageName,
    String? packageDescription,
    int? packagePricePodcoin,
    int? packageSoloPricePodcoin,
    List<Space>? spaces,
    String? selectedSpace,
    List<Channel>? channels,
    String? selectedChannel,
    List<PackageStoryDraft>? stories,
    bool? uploadingAudio,
    PublishMode? publishMode,
    DateTime? scheduledAt,
    String? error,
  }) {
    return PackageCreateState(
      packageName: packageName ?? this.packageName,
      packageDescription: packageDescription ?? this.packageDescription,
      packagePricePodcoin: packagePricePodcoin ?? this.packagePricePodcoin,
      packageSoloPricePodcoin:
          packageSoloPricePodcoin ?? this.packageSoloPricePodcoin,
      spaces: spaces ?? this.spaces,
      selectedSpace: selectedSpace ?? this.selectedSpace,
      channels: channels ?? this.channels,
      selectedChannel: selectedChannel ?? this.selectedChannel,
      stories: stories ?? this.stories,
      uploadingAudio: uploadingAudio ?? this.uploadingAudio,
      publishMode: publishMode ?? this.publishMode,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      error: error,
    );
  }
}

class PackageCreateController extends Notifier<PackageCreateState> {
  @override
  PackageCreateState build() => const PackageCreateState();

  void clear() {
    state = PackageCreateState(spaces: state.spaces, channels: state.channels);
  }

  Future<void> getSpaceList() async {
    final response = await SpaceApi().getSpaces();
    state = state.copyWith(spaces: response.spaces);
  }

  void getUserChannels(String userId) async {
    final response = await ChannelApi().getUserChannels(userId);
    state = state.copyWith(channels: response.channels);
  }

  void setPackageName(String v) => state = state.copyWith(packageName: v);
  void setPackageDescription(String v) =>
      state = state.copyWith(packageDescription: v);
  void setPackagePrice(int podcoin) =>
      state = state.copyWith(packagePricePodcoin: podcoin);
  void setPackageSoloPrice(int podcoin) =>
      state = state.copyWith(packageSoloPricePodcoin: podcoin);
  void setSpace(String? v) => state = state.copyWith(selectedSpace: v);
  void setChannel(String? v) => state = state.copyWith(selectedChannel: v);

  void addStory() {
    state = state.copyWith(
      stories: [
        ...state.stories,
        PackageStoryDraft(id: _genId('story')),
      ],
    );
  }

  void removeStory(String storyId) {
    state = state.copyWith(
      stories: state.stories.where((story) => story.id != storyId).toList(),
    );
  }

  void setStoryTitle(String storyId, String title) {
    _updateStory(storyId, (story) => story.copyWith(title: title));
  }

  void setStoryDescription(String storyId, String description) {
    _updateStory(storyId, (story) => story.copyWith(description: description));
  }

  Future<void> pickStoryAudio(String storyId) async {
    state = state.copyWith(uploadingAudio: true);
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: const ['mp3'],
      withData: true,
    );
    state = state.copyWith(uploadingAudio: false);
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final audio = UploadedAudio(
      id: _genId(file.name),
      name: file.name,
      fileName: file.name,
      fileBytes: file.bytes ?? Uint8List(0),
      duration: Duration.zero,
      path: file.path ?? file.name,
    );

    _updateStory(storyId, (story) => story.copyWith(audio: audio));
    _probeStoryDuration(storyId, audio);
  }

  Future<void> pickStoryCover(String storyId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return;

    final paths = <String>[];
    final bytes = <Uint8List>[];
    for (final file in result.files.where((file) => file.bytes != null)) {
      paths.add(file.name);
      bytes.add(file.bytes!);
    }
    if (bytes.isEmpty) return;

    _updateStory(
      storyId,
      (story) => story.copyWith(imageFilePaths: paths, imageFilesBytes: bytes),
    );
  }

  void setPublishMode(PublishMode mode) {
    if (mode == PublishMode.now) {
      state = state.copyWith(publishMode: mode, scheduledAt: null);
    } else {
      state = state.copyWith(publishMode: mode);
    }
  }

  void setScheduledAt(DateTime? dt) => state = state.copyWith(scheduledAt: dt);

  void _updateStory(
    String storyId,
    PackageStoryDraft Function(PackageStoryDraft story) update,
  ) {
    state = state.copyWith(
      stories: [
        for (final story in state.stories)
          if (story.id == storyId) update(story) else story,
      ],
    );
  }

  Future<void> _probeStoryDuration(String storyId, UploadedAudio audio) async {
    final player = AudioPlayer();
    try {
      if (audio.fileBytes.isNotEmpty) {
        await player.setUrl(
          Uri.dataFromBytes(
            audio.fileBytes,
            mimeType: _mimeFromName(audio.fileName),
          ).toString(),
        );
      } else if (audio.path.isNotEmpty) {
        await player.setFilePath(audio.path);
      } else {
        return;
      }

      var duration = player.duration ?? Duration.zero;
      if (duration == Duration.zero) {
        final streamDuration = await player.durationStream
            .firstWhere((d) => d != null)
            .timeout(const Duration(seconds: 3), onTimeout: () => null);
        duration = streamDuration ?? Duration.zero;
      }

      _updateStory(
        storyId,
        (story) => story.copyWith(audio: audio.copyWith(duration: duration)),
      );
    } catch (_) {
      _updateStory(storyId, (story) => story.copyWith(audio: audio));
    } finally {
      await player.dispose();
    }
  }

  String _genId(String seed) =>
      '${DateTime.now().microsecondsSinceEpoch}_${seed.hashCode}';

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
}

final packageCreateControllerProvider =
    NotifierProvider<PackageCreateController, PackageCreateState>(
      PackageCreateController.new,
    );
