import 'package:actpod_studio/api/channel_system_api.dart';
import 'package:actpod_studio/api/space_system_api.dart';
import 'package:actpod_studio/features/create_story/controllers/create_shared_models.dart';
import 'package:actpod_studio/features/create_story/models/channel_model.dart';
import 'package:actpod_studio/features/create_story/models/space_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

const _unset = Object();

@immutable
class PackageStoryDraft {
  final String id;
  final String title;
  final String description;
  final String packageNote;
  final UploadedAudio? audio;
  final List<String> imageFilePaths;
  final List<Uint8List> imageFilesBytes;

  const PackageStoryDraft({
    required this.id,
    this.title = '',
    this.description = '',
    this.packageNote = '',
    this.audio,
    this.imageFilePaths = const [],
    this.imageFilesBytes = const [],
  });

  bool get isComplete {
    return title.trim().isNotEmpty &&
        description.trim().isNotEmpty &&
        imageFilesBytes.isNotEmpty;
  }

  PackageStoryDraft copyWith({
    String? title,
    String? description,
    String? packageNote,
    Object? audio = _unset,
    List<String>? imageFilePaths,
    List<Uint8List>? imageFilesBytes,
  }) {
    return PackageStoryDraft(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      packageNote: packageNote ?? this.packageNote,
      audio: audio == _unset ? this.audio : audio as UploadedAudio?,
      imageFilePaths: imageFilePaths ?? this.imageFilePaths,
      imageFilesBytes: imageFilesBytes ?? this.imageFilesBytes,
    );
  }
}

@immutable
class PackageCreateState {
  final String? packageName;
  final String? packageDescription;
  final String? packageImagePath;
  final Uint8List? packageImageBytes;
  final int packagePricePodcoin;
  final int packageSinglePricePodcoin;
  final List<Space> spaces;
  final String? selectedSpace;
  final List<Channel> channels;
  final String? selectedChannel;
  final List<PackageStoryDraft> stories;
  final bool uploadingAudio;
  final bool pickingPackageImage;
  final String? pickingAudioStoryId;
  final String? pickingCoverStoryId;
  final List<String> probingDurationStoryIds;
  final PublishMode publishMode;
  final DateTime? scheduledAt;
  final String? error;

  const PackageCreateState({
    this.packageName,
    this.packageDescription,
    this.packageImagePath,
    this.packageImageBytes,
    this.packagePricePodcoin = 0,
    this.packageSinglePricePodcoin = 0,
    this.spaces = const [],
    this.selectedSpace,
    this.channels = const [],
    this.selectedChannel,
    this.stories = const [],
    this.uploadingAudio = false,
    this.pickingPackageImage = false,
    this.pickingAudioStoryId,
    this.pickingCoverStoryId,
    this.probingDurationStoryIds = const [],
    this.publishMode = PublishMode.now,
    this.scheduledAt,
    this.error,
  });

  bool get hasValidPackageInfo {
    return (packageName != null && packageName!.trim().isNotEmpty) &&
        (packageDescription != null && packageDescription!.trim().isNotEmpty) &&
        packageImageBytes != null &&
        (selectedSpace != null && selectedSpace!.isNotEmpty) &&
        (selectedChannel != null && selectedChannel!.isNotEmpty) &&
        packagePricePodcoin >= 0 &&
        packageSinglePricePodcoin >= 0;
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
    Object? packageImagePath = _unset,
    Object? packageImageBytes = _unset,
    int? packagePricePodcoin,
    int? packageSoloPricePodcoin,
    List<Space>? spaces,
    String? selectedSpace,
    List<Channel>? channels,
    String? selectedChannel,
    List<PackageStoryDraft>? stories,
    bool? uploadingAudio,
    bool? pickingPackageImage,
    Object? pickingAudioStoryId = _unset,
    Object? pickingCoverStoryId = _unset,
    List<String>? probingDurationStoryIds,
    PublishMode? publishMode,
    DateTime? scheduledAt,
    String? error,
  }) {
    return PackageCreateState(
      packageName: packageName ?? this.packageName,
      packageDescription: packageDescription ?? this.packageDescription,
      packageImagePath: packageImagePath == _unset
          ? this.packageImagePath
          : packageImagePath as String?,
      packageImageBytes: packageImageBytes == _unset
          ? this.packageImageBytes
          : packageImageBytes as Uint8List?,
      packagePricePodcoin: packagePricePodcoin ?? this.packagePricePodcoin,
      packageSinglePricePodcoin:
          packageSoloPricePodcoin ?? packageSinglePricePodcoin,
      spaces: spaces ?? this.spaces,
      selectedSpace: selectedSpace ?? this.selectedSpace,
      channels: channels ?? this.channels,
      selectedChannel: selectedChannel ?? this.selectedChannel,
      stories: stories ?? this.stories,
      uploadingAudio: uploadingAudio ?? this.uploadingAudio,
      pickingPackageImage: pickingPackageImage ?? this.pickingPackageImage,
      pickingAudioStoryId: pickingAudioStoryId == _unset
          ? this.pickingAudioStoryId
          : pickingAudioStoryId as String?,
      pickingCoverStoryId: pickingCoverStoryId == _unset
          ? this.pickingCoverStoryId
          : pickingCoverStoryId as String?,
      probingDurationStoryIds:
          probingDurationStoryIds ?? this.probingDurationStoryIds,
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

  Future<void> pickPackageImage() async {
    if (state.pickingPackageImage) return;

    state = state.copyWith(pickingPackageImage: true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.bytes == null) return;

      state = state.copyWith(
        packageImagePath: file.name,
        packageImageBytes: file.bytes,
      );
    } finally {
      state = state.copyWith(pickingPackageImage: false);
    }
  }

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

  void setStoryPackageNote(String storyId, String packageNote) {
    _updateStory(storyId, (story) => story.copyWith(packageNote: packageNote));
  }

  void clearStoryAudio(String storyId) {
    _updateStory(storyId, (story) => story.copyWith(audio: null));
    _setDurationProbing(storyId, false);
  }

  Future<void> pickStoryAudio(String storyId) async {
    if (state.pickingAudioStoryId != null) return;

    state = state.copyWith(uploadingAudio: true, pickingAudioStoryId: storyId);
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: const ['mp3'],
        withData: false,
        withReadStream: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final audio = UploadedAudio(
        id: _genId(file.name),
        name: file.name,
        fileName: file.name,
        fileBytes: Uint8List(0),
        readStream: file.readStream,
        fileSize: file.size,
        duration: Duration.zero,
        path: file.path ?? file.name,
      );

      _updateStory(storyId, (story) => story.copyWith(audio: audio));
    } finally {
      state = state.copyWith(uploadingAudio: false, pickingAudioStoryId: null);
    }
  }

  Future<void> probeMissingDurations() async {
    final storyIds = state.stories
        .where(
          (story) =>
              story.audio != null &&
              story.audio!.duration == Duration.zero &&
              !state.probingDurationStoryIds.contains(story.id),
        )
        .map((story) => story.id)
        .toList();

    for (final storyId in storyIds) {
      await probeStoryDuration(storyId);
    }
  }

  Future<void> probeStoryDuration(String storyId) async {
    final story = _findStory(storyId);
    final audio = story?.audio;
    if (audio == null ||
        audio.duration != Duration.zero ||
        state.probingDurationStoryIds.contains(storyId)) {
      return;
    }

    _setDurationProbing(storyId, true);

    var bytes = audio.fileBytes;
    var fileSize = audio.fileSize;
    var duration = Duration.zero;

    try {
      final player = AudioPlayer();
      try {
        if (!kIsWeb && _hasRealFilePath(audio)) {
          await player.setFilePath(audio.path);
        } else {
          if (bytes.isEmpty && audio.readStream != null) {
            bytes = await _readAllBytes(audio.readStream!);
            fileSize = bytes.length;
          }
          if (bytes.isEmpty) return;
          await player.setUrl(
            Uri.dataFromBytes(
              bytes,
              mimeType: _mimeFromName(audio.fileName),
            ).toString(),
          );
        }

        duration = player.duration ?? Duration.zero;
        if (duration == Duration.zero) {
          final streamDuration = await player.durationStream
              .firstWhere((d) => d != null)
              .timeout(const Duration(seconds: 3), onTimeout: () => null);
          duration = streamDuration ?? Duration.zero;
        }
      } finally {
        await player.dispose();
      }
    } catch (_) {
      duration = Duration.zero;
    } finally {
      _updateStoryAudio(
        storyId,
        audio,
        bytes: bytes,
        fileSize: fileSize,
        duration: duration,
        clearReadStream: bytes.isNotEmpty && audio.fileBytes.isEmpty,
      );
      _setDurationProbing(storyId, false);
    }
  }

  Future<void> pickStoryCover(String storyId) async {
    if (state.pickingCoverStoryId != null) return;

    state = state.copyWith(pickingCoverStoryId: storyId);
    try {
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
        (story) =>
            story.copyWith(imageFilePaths: paths, imageFilesBytes: bytes),
      );
    } finally {
      state = state.copyWith(pickingCoverStoryId: null);
    }
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

  PackageStoryDraft? _findStory(String storyId) {
    for (final story in state.stories) {
      if (story.id == storyId) return story;
    }
    return null;
  }

  void _updateStoryAudio(
    String storyId,
    UploadedAudio audio, {
    required Uint8List bytes,
    required int fileSize,
    required Duration duration,
    required bool clearReadStream,
  }) {
    _updateStory(
      storyId,
      (story) => story.copyWith(
        audio: UploadedAudio(
          id: audio.id,
          name: audio.name,
          fileName: audio.fileName,
          fileBytes: bytes,
          readStream: clearReadStream ? null : audio.readStream,
          fileSize: fileSize,
          duration: duration,
          path: audio.path,
        ),
      ),
    );
  }

  void _setDurationProbing(String storyId, bool isProbing) {
    final ids = state.probingDurationStoryIds.toSet();
    if (isProbing) {
      ids.add(storyId);
    } else {
      ids.remove(storyId);
    }
    state = state.copyWith(probingDurationStoryIds: ids.toList());
  }

  bool _hasRealFilePath(UploadedAudio audio) {
    return audio.path.isNotEmpty && audio.path != audio.fileName;
  }

  Future<Uint8List> _readAllBytes(Stream<List<int>> stream) async {
    final chunks = <int>[];
    await for (final chunk in stream) {
      chunks.addAll(chunk);
    }
    return Uint8List.fromList(chunks);
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
