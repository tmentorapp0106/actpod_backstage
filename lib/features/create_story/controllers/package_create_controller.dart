import 'package:actpod_studio/api/channel_system_api.dart';
import 'package:actpod_studio/api/space_system_api.dart';
import 'package:actpod_studio/api/response/story_response/package_models.dart';
import 'package:actpod_studio/features/create_story/controllers/create_shared_models.dart';
import 'package:actpod_studio/features/create_story/models/channel_model.dart';
import 'package:actpod_studio/features/create_story/models/space_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

const _unset = Object();

@immutable
class PackagePriceDraft {
  final String id;
  final String packagePriceId;
  final String priceType;
  final String lable;
  final int podcoins;
  final int twd;
  final bool isActive;

  const PackagePriceDraft({
    required this.id,
    this.packagePriceId = '',
    required this.priceType,
    required this.lable,
    this.podcoins = 0,
    this.twd = 0,
    this.isActive = true,
  });

  bool get isComplete => priceType.isNotEmpty && lable.trim().isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      if (packagePriceId.isNotEmpty) 'packagePriceId': packagePriceId,
      'priceType': priceType,
      'lable': lable,
      'podcoins': podcoins,
      'twd': twd,
      'isActive': isActive,
    };
  }

  PackagePriceDraft copyWith({
    String? packagePriceId,
    String? priceType,
    String? lable,
    int? podcoins,
    int? twd,
    bool? isActive,
  }) {
    return PackagePriceDraft(
      id: id,
      packagePriceId: packagePriceId ?? this.packagePriceId,
      priceType: priceType ?? this.priceType,
      lable: lable ?? this.lable,
      podcoins: podcoins ?? this.podcoins,
      twd: twd ?? this.twd,
      isActive: isActive ?? this.isActive,
    );
  }
}

@immutable
class PackageStoryDraft {
  final String id;
  final String storyId;
  final String title;
  final String description;
  final String packageNote;
  final UploadedAudio? audio;
  final String contentUrl;
  final String originalContentUrl;
  final List<String> remoteImageUrls;
  final int storyMilliSec;
  final int previewStartFrom;
  final int previewEndAt;
  final String collaboratorId;
  final String storyStatus;
  final List<String> imageFilePaths;
  final List<Uint8List> imageFilesBytes;

  const PackageStoryDraft({
    required this.id,
    this.storyId = '',
    this.title = '',
    this.description = '',
    this.packageNote = '',
    this.audio,
    this.contentUrl = '',
    this.originalContentUrl = '',
    this.remoteImageUrls = const [],
    this.storyMilliSec = 0,
    this.previewStartFrom = 0,
    this.previewEndAt = 0,
    this.collaboratorId = '',
    this.storyStatus = '',
    this.imageFilePaths = const [],
    this.imageFilesBytes = const [],
  });

  bool get isExisting => storyId.isNotEmpty;

  bool get hasNewAudio => audio != null;

  bool get shouldUpdateStoryAudio =>
      hasNewAudio || contentUrl != originalContentUrl;

  bool get hasImages =>
      imageFilesBytes.isNotEmpty || remoteImageUrls.isNotEmpty;

  bool get isComplete {
    return title.trim().isNotEmpty &&
        description.trim().isNotEmpty &&
        hasImages;
  }

  PackageStoryDraft copyWith({
    String? storyId,
    String? title,
    String? description,
    String? packageNote,
    Object? audio = _unset,
    String? contentUrl,
    String? originalContentUrl,
    List<String>? remoteImageUrls,
    int? storyMilliSec,
    int? previewStartFrom,
    int? previewEndAt,
    String? collaboratorId,
    String? storyStatus,
    List<String>? imageFilePaths,
    List<Uint8List>? imageFilesBytes,
  }) {
    return PackageStoryDraft(
      id: id,
      storyId: storyId ?? this.storyId,
      title: title ?? this.title,
      description: description ?? this.description,
      packageNote: packageNote ?? this.packageNote,
      audio: audio == _unset ? this.audio : audio as UploadedAudio?,
      contentUrl: contentUrl ?? this.contentUrl,
      originalContentUrl: originalContentUrl ?? this.originalContentUrl,
      remoteImageUrls: remoteImageUrls ?? this.remoteImageUrls,
      storyMilliSec: storyMilliSec ?? this.storyMilliSec,
      previewStartFrom: previewStartFrom ?? this.previewStartFrom,
      previewEndAt: previewEndAt ?? this.previewEndAt,
      collaboratorId: collaboratorId ?? this.collaboratorId,
      storyStatus: storyStatus ?? this.storyStatus,
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
  final String? packageImageUrl;
  final Uint8List? packageImageBytes;
  final List<PackagePriceDraft> packagePrices;
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
  final String? error;

  const PackageCreateState({
    this.packageName,
    this.packageDescription,
    this.packageImagePath,
    this.packageImageUrl,
    this.packageImageBytes,
    this.packagePrices = const [
      PackagePriceDraft(
        id: 'package_default',
        priceType: 'package',
        lable: '整套價格',
      ),
      PackagePriceDraft(
        id: 'single_default',
        priceType: 'single',
        lable: '單集價格',
      ),
    ],
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
    this.error,
  });

  bool get hasValidPackageInfo {
    return (packageName != null && packageName!.trim().isNotEmpty) &&
        (packageDescription != null && packageDescription!.trim().isNotEmpty) &&
        (packageImageBytes != null ||
            (packageImageUrl != null && packageImageUrl!.isNotEmpty)) &&
        (selectedSpace != null && selectedSpace!.isNotEmpty) &&
        (selectedChannel != null && selectedChannel!.isNotEmpty) &&
        packagePrices.isNotEmpty &&
        packagePrices.every((price) => price.isComplete);
  }

  bool get hasValidStories {
    return stories.isNotEmpty && stories.every((story) => story.isComplete);
  }

  PackageCreateState copyWith({
    String? packageName,
    String? packageDescription,
    Object? packageImagePath = _unset,
    Object? packageImageUrl = _unset,
    Object? packageImageBytes = _unset,
    List<PackagePriceDraft>? packagePrices,
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
    String? error,
  }) {
    return PackageCreateState(
      packageName: packageName ?? this.packageName,
      packageDescription: packageDescription ?? this.packageDescription,
      packageImagePath: packageImagePath == _unset
          ? this.packageImagePath
          : packageImagePath as String?,
      packageImageUrl: packageImageUrl == _unset
          ? this.packageImageUrl
          : packageImageUrl as String?,
      packageImageBytes: packageImageBytes == _unset
          ? this.packageImageBytes
          : packageImageBytes as Uint8List?,
      packagePrices: packagePrices ?? this.packagePrices,
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
  void setSpace(String? v) => state = state.copyWith(selectedSpace: v);
  void setChannel(String? v) => state = state.copyWith(selectedChannel: v);

  void applyPackageInfo(PackageInfo packageInfo) {
    state = state.copyWith(
      packageName: packageInfo.packageName,
      packageDescription: packageInfo.packageDescription,
      packageImagePath: packageInfo.packageImageUrl.isEmpty ? null : '目前封面',
      packageImageUrl: packageInfo.packageImageUrl,
      packageImageBytes: null,
      selectedSpace: packageInfo.spaceName,
      selectedChannel: packageInfo.channelName,
      packagePrices: [
        for (final price in packageInfo.packagePrices)
          PackagePriceDraft(
            id: price.packagePriceId.isEmpty
                ? _genId('price')
                : price.packagePriceId,
            packagePriceId: price.packagePriceId,
            priceType: price.priceType,
            lable: price.lable,
            podcoins: price.podcoins,
            twd: price.twd,
            isActive: price.isActive,
          ),
      ],
      stories: [
        for (final story in packageInfo.stories)
          PackageStoryDraft(
            id: story.storyId.isEmpty ? _genId('story') : story.storyId,
            storyId: story.storyId,
            title: story.storyName,
            description: story.storyDescription,
            packageNote: story.packageNote,
            contentUrl: story.storyUrl,
            originalContentUrl: story.storyUrl,
            remoteImageUrls: story.storyImageUrls,
            storyMilliSec: story.storyLength,
            previewStartFrom: story.previewStartFrom,
            previewEndAt: story.previewEndAt,
            collaboratorId: story.collaborator,
            storyStatus: story.storyStatus,
          ),
      ],
      error: null,
    );
  }

  void addPackagePrice() {
    state = state.copyWith(
      packagePrices: [
        ...state.packagePrices,
        PackagePriceDraft(id: _genId('price'), priceType: 'package', lable: ''),
      ],
    );
  }

  void removePackagePrice(String priceId) {
    if (state.packagePrices.length <= 1) return;
    state = state.copyWith(
      packagePrices: state.packagePrices
          .where((price) => price.id != priceId)
          .toList(),
    );
  }

  void setPackagePriceType(String priceId, String priceType) {
    _updatePackagePrice(
      priceId,
      (price) => price.copyWith(priceType: priceType),
    );
  }

  void setPackagePriceLable(String priceId, String lable) {
    _updatePackagePrice(priceId, (price) => price.copyWith(lable: lable));
  }

  void setPackagePricePodcoins(String priceId, int podcoins) {
    _updatePackagePrice(priceId, (price) => price.copyWith(podcoins: podcoins));
  }

  void setPackagePriceTwd(String priceId, int twd) {
    _updatePackagePrice(priceId, (price) => price.copyWith(twd: twd));
  }

  void setPackagePriceActive(String priceId, bool isActive) {
    _updatePackagePrice(priceId, (price) => price.copyWith(isActive: isActive));
  }

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
        packageImageUrl: null,
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
    _updateStory(
      storyId,
      (story) => story.copyWith(
        audio: null,
        contentUrl: story.isExisting ? '' : story.contentUrl,
      ),
    );
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

  void _updatePackagePrice(
    String priceId,
    PackagePriceDraft Function(PackagePriceDraft price) update,
  ) {
    state = state.copyWith(
      packagePrices: [
        for (final price in state.packagePrices)
          if (price.id == priceId) update(price) else price,
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
