import 'package:actpod_studio/api/channel_system_api.dart';
import 'package:actpod_studio/api/space_system_api.dart';
import 'package:actpod_studio/api/user_system_api.dart';
import 'package:actpod_studio/features/create_story/controllers/create_shared_models.dart';
import 'package:actpod_studio/features/create_story/models/channel_model.dart';
import 'package:actpod_studio/features/create_story/models/space_model.dart';
import 'package:actpod_studio/features/create_story/models/user_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

@immutable
class SingleCreateState {
  final String? title;
  final String? description;
  final List<Space> spaces;
  final String? selectedSpace;
  final List<Channel> channels;
  final String? selectedChannel;
  final List<String>? imageFilePaths;
  final List<Uint8List>? imageFilesBytes;
  final List<UploadedAudio> audios;
  final bool uploadingAudio;
  final List<String> probingDurationAudioIds;
  final String? selectedAudioId;
  final Duration highlightLength;
  final Duration selectionStart;
  final Duration selectionEnd;
  final int pricePodcoin;
  final int priceTwd;
  final PublishMode publishMode;
  final DateTime? scheduledAt;
  final UserInfo? collaborator;
  final List<UserInfo> searchUserList;
  final String? error;

  const SingleCreateState({
    this.title,
    this.description,
    this.spaces = const [],
    this.selectedSpace,
    this.channels = const [],
    this.selectedChannel,
    this.imageFilePaths,
    this.imageFilesBytes,
    this.audios = const [],
    this.uploadingAudio = false,
    this.probingDurationAudioIds = const [],
    this.selectedAudioId,
    this.highlightLength = const Duration(seconds: 20),
    this.selectionStart = Duration.zero,
    this.selectionEnd = const Duration(seconds: 20),
    this.pricePodcoin = 0,
    this.priceTwd = 0,
    this.publishMode = PublishMode.now,
    this.scheduledAt,
    this.collaborator,
    this.searchUserList = const [],
    this.error,
  });

  UploadedAudio? get selectedAudio {
    if (selectedAudioId == null) return null;
    for (final audio in audios) {
      if (audio.id == selectedAudioId) return audio;
    }
    return null;
  }

  Duration get currentAudioDuration => selectedAudio?.duration ?? Duration.zero;

  bool get hasValidUpload => audios.isNotEmpty;

  bool get hasValidStoryDetail {
    return (title != null && title!.trim().isNotEmpty) &&
        (description != null && description!.trim().isNotEmpty) &&
        (selectedSpace != null && selectedSpace!.isNotEmpty) &&
        (selectedChannel != null && selectedChannel!.isNotEmpty) &&
        (imageFilesBytes != null && imageFilesBytes!.isNotEmpty);
  }

  bool get hasValidSettings {
    if (publishMode == PublishMode.schedule) return scheduledAt != null;
    return true;
  }

  SingleCreateState copyWith({
    String? title,
    String? description,
    List<Space>? spaces,
    String? selectedSpace,
    List<Channel>? channels,
    String? selectedChannel,
    List<String>? imageFilePaths,
    List<Uint8List>? imageFilesBytes,
    List<UploadedAudio>? audios,
    bool? uploadingAudio,
    List<String>? probingDurationAudioIds,
    String? selectedAudioId,
    Duration? highlightLength,
    Duration? selectionStart,
    Duration? selectionEnd,
    int? pricePodcoin,
    int? priceTwd,
    PublishMode? publishMode,
    DateTime? scheduledAt,
    UserInfo? collaborator,
    List<UserInfo>? searchUserList,
    String? error,
  }) {
    return SingleCreateState(
      title: title ?? this.title,
      description: description ?? this.description,
      spaces: spaces ?? this.spaces,
      selectedSpace: selectedSpace ?? this.selectedSpace,
      channels: channels ?? this.channels,
      selectedChannel: selectedChannel ?? this.selectedChannel,
      imageFilePaths: imageFilePaths ?? this.imageFilePaths,
      imageFilesBytes: imageFilesBytes ?? this.imageFilesBytes,
      audios: audios ?? this.audios,
      uploadingAudio: uploadingAudio ?? this.uploadingAudio,
      probingDurationAudioIds:
          probingDurationAudioIds ?? this.probingDurationAudioIds,
      selectedAudioId: selectedAudioId ?? this.selectedAudioId,
      highlightLength: highlightLength ?? this.highlightLength,
      selectionStart: selectionStart ?? this.selectionStart,
      selectionEnd: selectionEnd ?? this.selectionEnd,
      pricePodcoin: pricePodcoin ?? this.pricePodcoin,
      priceTwd: priceTwd ?? this.priceTwd,
      publishMode: publishMode ?? this.publishMode,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      collaborator: collaborator ?? this.collaborator,
      searchUserList: searchUserList ?? this.searchUserList,
      error: error,
    );
  }
}

class SingleCreateController extends Notifier<SingleCreateState> {
  @override
  SingleCreateState build() => const SingleCreateState();

  void clear() {
    state = SingleCreateState(spaces: state.spaces, channels: state.channels);
  }

  Future<void> getSpaceList() async {
    final response = await SpaceApi().getSpaces();
    state = state.copyWith(spaces: response.spaces);
  }

  void getUserChannels(String userId) async {
    final response = await ChannelApi().getUserChannels(userId);
    state = state.copyWith(channels: response.channels);
  }

  void setTitle(String v) => state = state.copyWith(title: v);
  void setDescription(String v) => state = state.copyWith(description: v);
  void setSpace(String? v) => state = state.copyWith(selectedSpace: v);
  void setChannel(String? v) => state = state.copyWith(selectedChannel: v);
  void setPricePodcoin(int podcoin) {
    state = state.copyWith(pricePodcoin: podcoin);
  }

  void setPriceTwd(int twd) {
    state = state.copyWith(priceTwd: twd);
  }

  void setLoadingAudio(bool isLoading) {
    state = state.copyWith(uploadingAudio: isLoading);
  }

  void setAudioFiles(List<PlatformFile> files) {
    if (files.isEmpty) return;

    final newAudios = <UploadedAudio>[];
    for (final file in files) {
      final id = _genId(file.name);
      newAudios.add(
        UploadedAudio(
          id: id,
          name: file.name,
          fileName: file.name,
          fileBytes: Uint8List(0),
          readStream: file.readStream,
          fileSize: file.size,
          duration: Duration.zero,
          path: file.path ?? file.name,
        ),
      );
    }

    final first = newAudios.first;
    state = state.copyWith(
      audios: newAudios,
      selectedAudioId: first.id,
      selectionStart: Duration.zero,
      selectionEnd: state.highlightLength,
    );

    for (final audio in newAudios) {
      _probeDurationAndUpdate(audio.id);
    }
  }

  void removeAudio(String audioId) {
    final list = state.audios.where((audio) => audio.id != audioId).toList();
    final newSelectedId = state.selectedAudioId == audioId
        ? (list.isNotEmpty ? list.first.id : null)
        : state.selectedAudioId;

    state = state.copyWith(
      audios: list,
      selectedAudioId: newSelectedId,
      selectionStart: list.isEmpty ? Duration.zero : state.selectionStart,
      selectionEnd: list.isEmpty ? Duration.zero : state.selectionEnd,
    );
  }

  void selectAudio(String audioId) {
    if (state.selectedAudioId == audioId || state.audios.isEmpty) return;
    final audio = state.audios.firstWhere(
      (item) => item.id == audioId,
      orElse: () => state.audios.first,
    );
    state = state.copyWith(
      selectedAudioId: audioId,
      selectionStart: Duration.zero,
      selectionEnd: _minDuration(state.highlightLength, audio.duration),
    );
  }

  Future<void> pickCover() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return;

    final imageBytesList = <Uint8List>[];
    final imagePathList = <String>[];
    for (final file in result.files.where((file) => file.bytes != null)) {
      imageBytesList.add(file.bytes!);
      imagePathList.add(file.name);
    }
    if (imageBytesList.isEmpty) return;

    state = state.copyWith(
      imageFilesBytes: imageBytesList,
      imageFilePaths: imagePathList,
    );
  }

  void reorderCovers(int oldIndex, int newIndex) {
    final bytes = [...(state.imageFilesBytes ?? const <Uint8List>[])];
    final paths = [...(state.imageFilePaths ?? const <String>[])];
    if (bytes.isEmpty || paths.isEmpty) return;
    if (oldIndex < 0 || oldIndex >= bytes.length) return;
    if (oldIndex < newIndex) newIndex -= 1;

    final movedBytes = bytes.removeAt(oldIndex);
    final movedPath = paths.removeAt(oldIndex);
    bytes.insert(newIndex, movedBytes);
    paths.insert(newIndex, movedPath);

    state = state.copyWith(imageFilesBytes: bytes, imageFilePaths: paths);
  }

  void clearCover() =>
      state = state.copyWith(imageFilesBytes: null, imageFilePaths: null);

  void setHighlightLength(Duration d) {
    final audioLen = state.currentAudioDuration;
    final end = _clampEnd(state.selectionStart + d, audioLen);
    state = state.copyWith(highlightLength: d, selectionEnd: end);
  }

  void setSelection({required Duration start}) {
    final audioLen = state.currentAudioDuration;
    final clampedStart = _clamp(start, Duration.zero, audioLen);
    final end = _clampEnd(clampedStart + state.highlightLength, audioLen);
    state = state.copyWith(selectionStart: clampedStart, selectionEnd: end);
  }

  void setPublishMode(PublishMode mode) {
    if (mode == PublishMode.now) {
      state = state.copyWith(publishMode: mode, scheduledAt: null);
    } else {
      state = state.copyWith(publishMode: mode);
    }
  }

  void setScheduledAt(DateTime? dt) => state = state.copyWith(scheduledAt: dt);

  Future<void> searchUserList(String text) async {
    final keyword = text.trim();
    if (keyword.isEmpty) {
      state = state.copyWith(searchUserList: []);
      return;
    }
    final res = await UserApi().searchUser(keyword);
    state = state.copyWith(searchUserList: res.users);
  }

  void addCollaborator(UserInfo collaborator) {
    state = state.copyWith(collaborator: collaborator);
  }

  void removeCollaborator() {
    state = state.copyWith(
      collaborator: UserInfo(userId: "", name: "", avatarUrl: "", email: ""),
    );
  }

  Future<void> probeMissingDurations() async {
    final audioIds = state.audios
        .where(
          (audio) =>
              audio.duration == Duration.zero &&
              !state.probingDurationAudioIds.contains(audio.id),
        )
        .map((audio) => audio.id)
        .toList();

    for (final audioId in audioIds) {
      await probeAudioDuration(audioId);
    }
  }

  Future<void> probeAudioDuration(String audioId) async {
    final audio = _findAudio(audioId);
    if (audio == null ||
        audio.duration != Duration.zero ||
        state.probingDurationAudioIds.contains(audioId)) {
      return;
    }

    _setDurationProbing(audioId, true);

    var bytes = audio.fileBytes;
    var fileSize = audio.fileSize;
    var duration = Duration.zero;

    try {
      if (!kIsWeb && _hasRealFilePath(audio)) {
        duration = await _probeDurationFromFilePath(audio.path);
      } else {
        if (bytes.isEmpty && audio.readStream != null) {
          bytes = await _readAllBytes(audio.readStream!);
          fileSize = bytes.length;
        }
        if (bytes.isNotEmpty) {
          duration = await _probeDurationFromBytes(bytes, audio.fileName);
        }
      }
    } finally {
      _updateAudioData(
        audioId,
        audio,
        bytes: bytes,
        fileSize: fileSize,
        duration: duration,
        clearReadStream: bytes.isNotEmpty && audio.fileBytes.isEmpty,
      );
      _setDurationProbing(audioId, false);
    }
  }

  Future<void> _probeDurationAndUpdate(String audioId) async {
    final audio = state.audios
        .where((item) => item.id == audioId)
        .cast<UploadedAudio?>()
        .firstWhere((item) => item != null, orElse: () => null);
    if (audio == null) return;

    final player = AudioPlayer();
    try {
      if (!kIsWeb && _hasRealFilePath(audio)) {
        await player.setFilePath(audio.path);
      } else if (audio.fileBytes.isNotEmpty) {
        await player.setUrl(
          Uri.dataFromBytes(
            audio.fileBytes,
            mimeType: _mimeFromName(audio.fileName),
          ).toString(),
        );
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
      _updateAudioDuration(audioId, duration);
    } catch (_) {
      _updateAudioDuration(audioId, Duration.zero);
    } finally {
      await player.dispose();
    }
  }

  void _updateAudioDuration(String audioId, Duration duration) {
    final updated = [
      for (final audio in state.audios)
        if (audio.id == audioId) audio.copyWith(duration: duration) else audio,
    ];

    var newEnd = state.selectionEnd;
    if (state.selectedAudioId == audioId) {
      final desiredEnd = state.selectionStart + state.highlightLength;
      newEnd = desiredEnd > duration ? duration : desiredEnd;
    }

    state = state.copyWith(audios: updated, selectionEnd: newEnd);
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

  Duration _minDuration(Duration a, Duration b) => a < b ? a : b;

  Duration _clamp(Duration v, Duration min, Duration max) {
    if (v < min) return min;
    if (v > max) return max;
    return v;
  }

  Duration _clampEnd(Duration end, Duration audioLen) {
    if (end < Duration.zero) return Duration.zero;
    if (end > audioLen) return audioLen;
    return end;
  }

  bool _hasRealFilePath(UploadedAudio audio) {
    return audio.path.isNotEmpty && audio.path != audio.fileName;
  }

  UploadedAudio? _findAudio(String audioId) {
    for (final audio in state.audios) {
      if (audio.id == audioId) return audio;
    }
    return null;
  }

  void _updateAudioData(
    String audioId,
    UploadedAudio current, {
    required Uint8List bytes,
    required int fileSize,
    required Duration duration,
    required bool clearReadStream,
  }) {
    final updated = [
      for (final audio in state.audios)
        if (audio.id == audioId)
          UploadedAudio(
            id: current.id,
            name: current.name,
            fileName: current.fileName,
            fileBytes: bytes,
            readStream: clearReadStream ? null : current.readStream,
            fileSize: fileSize,
            duration: duration,
            path: current.path,
          )
        else
          audio,
    ];

    var newEnd = state.selectionEnd;
    if (state.selectedAudioId == audioId) {
      final desiredEnd = state.selectionStart + state.highlightLength;
      newEnd = desiredEnd > duration ? duration : desiredEnd;
    }

    state = state.copyWith(audios: updated, selectionEnd: newEnd);
  }

  void _setDurationProbing(String audioId, bool isProbing) {
    final ids = state.probingDurationAudioIds.toSet();
    if (isProbing) {
      ids.add(audioId);
    } else {
      ids.remove(audioId);
    }
    state = state.copyWith(probingDurationAudioIds: ids.toList());
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
}

final singleCreateControllerProvider =
    NotifierProvider<SingleCreateController, SingleCreateState>(
      SingleCreateController.new,
    );
