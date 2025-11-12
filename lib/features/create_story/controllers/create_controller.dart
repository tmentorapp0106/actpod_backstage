// lib/features/create_story/controllers/create_controller.dart
import 'dart:typed_data';
import 'package:actpod_studio/features/api/api.dart';
import 'package:actpod_studio/features/create_story/models/channel_model.dart';
import 'package:actpod_studio/features/create_story/models/space_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';

/// =============================================================
///  Publish Create Flow - Controller & State (Riverpod Notifier)
///  Steps: 0 Upload → 1 Detail → 2 Highlight → 3 Settings → 4 Preview
/// =============================================================

/// 發布方式（即時 / 排程）
enum PublishMode { now, schedule }

/// 音檔模型（視需求擴充：遠端 URL、檔案大小、封面等）
class UploadedAudio {
  final String id; // 內部 uid
  final String name; // 顯示名稱
  final String fileName;
  final Uint8List fileBytes;
  final Duration duration; // 音檔長度（初始可為 0，待解析後更新）
  final String path; // 本地或遠端 url/path

  const UploadedAudio({
    required this.id,
    required this.name,
    required this.fileName,
    required this.fileBytes,
    required this.duration,
    required this.path,
  });

  UploadedAudio copyWith({
    String? id,
    String? name,
    String? fileName,
    Uint8List? fileBytes,
    Duration? duration,
    String? path,
  }) {
    return UploadedAudio(
      id: id ?? this.id,
      name: name ?? this.name,
      fileName: fileName ?? this.fileName,
      fileBytes: fileBytes ?? this.fileBytes,
      duration: duration ?? this.duration,
      path: path ?? this.path,
    );
  }
}

/// 建立故事流程的整體狀態
@immutable
class CreateState {
  /// 0: Upload, 1: Detail, 2: Highlight, 3: Settings, 4: Preview
  final int currentPage;

  // ===== Detail =====
  final String? title;
  final String? description;
  final List<Space> spaces;
  final String? selectedSpace;
  final List<Channel> channels;
  final String? selectedChannel;
  final String? imageFileName;
  final Uint8List? imageFileBytes;

  // ===== Upload / Highlight =====
  final List<UploadedAudio> audios;
  final String? selectedAudioId;

  /// 精華長度（例如 20 秒）
  final Duration highlightLength;

  /// 在音檔內的精華起點/終點
  final Duration selectionStart;
  final Duration selectionEnd;
  final String? transitionMusicPath;

  // ===== Settings =====
  final int pricePodcoin; // 0 = 免費
  final PublishMode publishMode; // 即時 / 排程
  final DateTime? scheduledAt; // 排程時間（publishMode == schedule）
  final List<String> collaborators; // 合作創作者（名稱或 email）

  // ===== Others =====
  final bool isSaving;
  final String? error;

  const CreateState({
    this.currentPage = 0,
    // Detail
    this.title,
    this.description,
    this.spaces = const [],
    this.selectedSpace,
    this.channels = const [],
    this.selectedChannel,
    this.imageFileName,
    this.imageFileBytes,
    // Upload / Highlight
    this.audios = const [],
    this.selectedAudioId,
    this.highlightLength = const Duration(seconds: 20),
    this.selectionStart = Duration.zero,
    this.selectionEnd = const Duration(seconds: 20),
    this.transitionMusicPath,
    // Settings
    this.pricePodcoin = 0,
    this.publishMode = PublishMode.now,
    this.scheduledAt,
    this.collaborators = const [],
    // Others
    this.isSaving = false,
    this.error,
  });

  /// 目前選中的音檔
  UploadedAudio? get selectedAudio {
    if (selectedAudioId == null) return null;
    for (final a in audios) {
      if (a.id == selectedAudioId) return a;
    }
    return null;
  }

  /// 目前音檔長度（無音檔為 0）
  Duration get currentAudioDuration => selectedAudio?.duration ?? Duration.zero;

  bool get canPrev => currentPage > 0;

  /// 依照步驟檢查是否可前進
  bool get canNext {
    switch (currentPage) {
      case 0: // Upload
        return audios.isNotEmpty;
      case 1: // Detail
        return (title?.trim().isNotEmpty ?? false);
      case 2: // Highlight
        return selectionEnd > selectionStart && highlightLength > Duration.zero;
      case 3: // Settings
        if (publishMode == PublishMode.schedule) {
          return scheduledAt != null;
        }
        return true;
      case 4: // Preview
        return true;
      default:
        return false;
    }
  }

  /// 0~1 之間的進度
  double get progress => (currentPage + 1) / 5;

  /// 複製新狀態（scheduledAt 支援傳入 null 以清空）
  CreateState copyWith({
    int? currentPage,
    // Detail
    String? title,
    String? description,
    List<Space>? spaces,
    String? selectedSpace,
    List<Channel>? channels,
    String? selectedChannel,
    String? imageFileName,
    Uint8List? imageFileBytes,
    // Upload / Highlight
    List<UploadedAudio>? audios,
    String? selectedAudioId,
    Duration? highlightLength,
    Duration? selectionStart,
    Duration? selectionEnd,
    String? transitionMusicPath,
    // Settings
    int? pricePodcoin,
    PublishMode? publishMode,
    DateTime? scheduledAt, // 傳入 null 代表清空
    List<String>? collaborators,
    // Others
    bool? isSaving,
    String? error,
  }) {
    return CreateState(
      currentPage: currentPage ?? this.currentPage,
      // Detail
      title: title ?? this.title,
      description: description ?? this.description,
      spaces: spaces ?? this.spaces,
      selectedSpace: selectedSpace ?? this.selectedSpace,
      channels: channels ?? this.channels,
      selectedChannel: selectedChannel ?? this.selectedChannel,
      imageFileName: imageFileName ?? this.imageFileName,
      imageFileBytes: imageFileBytes ?? this.imageFileBytes,
      // Upload / Highlight
      audios: audios ?? this.audios,
      selectedAudioId: selectedAudioId ?? this.selectedAudioId,
      highlightLength: highlightLength ?? this.highlightLength,
      selectionStart: selectionStart ?? this.selectionStart,
      selectionEnd: selectionEnd ?? this.selectionEnd,
      transitionMusicPath: transitionMusicPath ?? this.transitionMusicPath,
      // Settings
      pricePodcoin: pricePodcoin ?? this.pricePodcoin,
      publishMode: publishMode ?? this.publishMode,
      scheduledAt: scheduledAt, // 允許覆寫為 null
      collaborators: collaborators ?? this.collaborators,
      // Others
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // ===== Meta =====
      'currentPage': currentPage,

      // ===== Detail =====
      'title': title,
      'description': description,
      'spaces': spaces,
      'selectedSpace': selectedSpace,
      'channels': channels,
      'selectedChannel': selectedChannel,
      'selectedAudioId': selectedAudioId,
      'highlightLength': highlightLength.inMilliseconds,
      'selectionStart': selectionStart.inMilliseconds,
      'selectionEnd': selectionEnd.inMilliseconds,
      'transitionMusicPath': transitionMusicPath,

      // ===== Settings =====
      'pricePodcoin': pricePodcoin,
      'publishMode': publishMode.name, // Enum 轉字串
      'scheduledAt': scheduledAt?.toIso8601String(),
      'collaborators': collaborators,

      // ===== Others =====
      'isSaving': isSaving,
      'error': error,
    };
  }
}

/// Riverpod Notifier：管理整個建立流程
class CreateController extends Notifier<CreateState> {
  static const int maxSteps = 5;

  // 如需暫存原始檔（含 bytes/path），用於上傳或解析時長
  final Map<String, PlatformFile> _fileCache = {};

  @override
  CreateState build() {
    return CreateState(
      currentPage: 0,
      spaces: spaces,
      channels: channels,
      pricePodcoin: 0,
      publishMode: PublishMode.now,
      scheduledAt: null,
      collaborators: [],

    );
  }

  // 設定 isSaving
  void setSaving(bool saving) {
    state = state.copyWith(isSaving: saving);
  }

  // -------------------------
  // Navigation
  // -------------------------
  void next() {
    if (state.currentPage < maxSteps - 1 && state.canNext) {
      state = state.copyWith(currentPage: state.currentPage + 1, error: null);
    }
  }

  void back() {
    if (state.currentPage > 0) {
      state = state.copyWith(currentPage: state.currentPage - 1, error: null);
    }
  }

  void jumpTo(int index) {
    final i = index.clamp(0, maxSteps - 1);
    state = state.copyWith(currentPage: i, error: null);
  }

  // 舊命名轉接
  void nextStep() => next();
  void prevStep() => back();

  // -------------------------
  // Detail setters
  // -------------------------
  void setTitle(String v) => state = state.copyWith(title: v);
  void setDescription(String v) => state = state.copyWith(description: v);
  void setSpace(String? v) => state = state.copyWith(selectedSpace: v);
  void setChannel(String? v) => state = state.copyWith(selectedChannel: v);

  // 封面
  Future<void> pickCover() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      final data = file.bytes;
      if (data == null) return;
      state = state.copyWith(imageFileBytes: Uint8List.fromList(data), imageFileName: file.name);
    } catch (e, st) {
      if (kDebugMode) {
        // 可換成你的 logger
        print('pickCover error: $e\n$st');
      }
    }
  }

  void clearCover() => state = state.copyWith(imageFileBytes: null, imageFileName: null);

  // -------------------------
  // Upload / Audio
  // -------------------------

  void setAudioFiles(List<PlatformFile> files) {
    if (files.isEmpty) return;

    final newAudios = <UploadedAudio>[];

    for (final f in files) {
      final id = '${DateTime.now().microsecondsSinceEpoch}_${f.name.hashCode}';
      _fileCache[id] = f; // ✅ 存原始檔以便解析 & 上傳
      newAudios.add(
        UploadedAudio(
          id: id,
          name: f.name,
          fileName: f.name,
          fileBytes: f.bytes ?? Uint8List(0),
          duration: Duration.zero, // 先放 0，待會回填
          path: f.path ?? f.name, // Web 會是 name
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

    // ✅ 逐一解析長度
    for (final a in newAudios) {
      _probeDurationAndUpdate(a.id);
    }
  }

  Future<void> _probeDurationAndUpdate(String audioId) async {
    final f = _fileCache[audioId];
    if (f == null) return;

    final player = AudioPlayer();

    try {
      // 1) 設定來源
      if (kIsWeb) {
        // Web：用 data:URI，但記得 MIME 要正確（mp3 -> audio/mpeg 等）
        final bytes = f.bytes;
        if (bytes == null) return;
        final mime = _mimeFromName(f.name); // 確保回傳像 'audio/mpeg'
        final uri = Uri.dataFromBytes(bytes, mimeType: mime).toString();
        await player.setUrl(uri);
      } else if (f.path != null) {
        await player.setFilePath(f.path!);
      } else if (f.bytes != null) {
        final uri = Uri.dataFromBytes(
          f.bytes!,
          mimeType: _mimeFromName(f.name),
        ).toString();
        await player.setUrl(uri);
      } else {
        return;
      }

      // 2) 取得時長：先用 set*= 返回值，若沒有，再等到 ready 或 durationStream 有值
      Duration dur =
          (player.duration ?? Duration.zero); // 這裡通常還拿不到（Web 常為 null）

      if (dur == Duration.zero) {
        // 等待播放器進入 ready/completed 狀態（代表已載入 metadata）
        // 有些情況 duration 在 ready 之後才產生，所以還要看 durationStream
        try {
          // 等到 ready（最多 3 秒）
          await player.processingStateStream
              .firstWhere(
                (s) => s == ProcessingState.ready || s == ProcessingState.completed,
              )
              .timeout(const Duration(seconds: 3));
        } catch (_) {
          // ignore timeout; 我們再嘗試從 durationStream 取值
        }

        // 嘗試從 durationStream 取得第一個非 null 的時長（最多 3 秒）
        final d = await player.durationStream
            .firstWhere((d) => d != null)
            .timeout(const Duration(seconds: 3), onTimeout: () => null);

        if (d != null) {
          dur = d;
        } else {
          // 若還是拿不到，最後再讀一次 player.duration
          dur = player.duration ?? Duration.zero;
        }
      }
      _updateAudioDuration(audioId, dur);
    } catch (e) {
      // 失敗時設 0，避免整個流程卡住
      _updateAudioDuration(audioId, Duration.zero);
    } finally {
      await player.dispose();
    }
  }

  void _updateAudioDuration(String audioId, Duration dur) {
    final updated = [
      for (final a in state.audios)
        if (a.id == audioId)
          UploadedAudio(
            id: a.id,
            name: a.name,
            fileName: a.fileName,
            fileBytes: a.fileBytes,
            duration: dur,
            path: a.path,
          )
        else
          a,
    ];

    Duration newEnd = state.selectionEnd;
    if (state.selectedAudioId == audioId) {
      final desiredEnd = state.selectionStart + state.highlightLength;
      newEnd = desiredEnd > dur ? dur : desiredEnd;
    }

    state = state.copyWith(audios: updated, selectionEnd: newEnd);
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

  /// 附加音檔（不覆蓋既有清單）
  void appendAudioFiles(List<PlatformFile> files) {
    if (files.isEmpty) return;

    final list = [...state.audios];
    for (final f in files) {
      final id = _genId(f.name);
      _fileCache[id] = f;
      list.add(
        UploadedAudio(
          id: id,
          name: f.name,
          fileName: f.name,
          fileBytes: f.bytes ?? Uint8List(0),
          duration: Duration.zero,
          path: f.path ?? f.name,
        ),
      );
    }

    // 若目前無選取，選第一個
    final selectedId = state.selectedAudioId ?? list.first.id;
    state = state.copyWith(
      audios: list,
      selectedAudioId: selectedId,
      error: null,
    );
  }

  /// 單筆加入（常用於拖拉單檔）
  void addAudio(UploadedAudio audio) {
    final list = [...state.audios, audio];
    state = state.copyWith(
      audios: list,
      selectedAudioId: state.selectedAudioId ?? audio.id,
      selectionStart: Duration.zero,
      selectionEnd: _minDuration(state.highlightLength, audio.duration),
    );
  }

  Future<void> setAudioDuration(String audioId) async {
    final audio = state.audios.firstWhere((a) => a.id == audioId);

    final player = AudioPlayer();
    await player.setUrl(audio.path); // 若是本地路徑，用 setFilePath
    final duration = player.duration ?? Duration.zero;

    final updated = state.audios.map((a) {
      if (a.id == audioId) {
        return UploadedAudio(
          id: a.id,
          name: a.name,
          fileName: a.fileName,
          fileBytes: a.fileBytes,
          duration: duration,
          path: a.path,
        );
      }
      return a;
    }).toList();

    state = state.copyWith(audios: updated);
  }

  void removeAudio(String audioId) {
    final list = state.audios.where((a) => a.id != audioId).toList();

    String? newSelectedId = state.selectedAudioId;
    if (state.selectedAudioId == audioId) {
      // 被刪除的是目前選中的音檔 → 選擇新的候選（若有）
      newSelectedId = list.isNotEmpty ? list.first.id : null;
    }

    state = state.copyWith(
      audios: list,
      selectedAudioId: newSelectedId,
      // 若已無音檔，重置選取區段
      selectionStart: list.isEmpty ? Duration.zero : state.selectionStart,
      selectionEnd: list.isEmpty ? Duration.zero : state.selectionEnd,
    );
  }

  void selectAudio(String audioId) {
    if (state.selectedAudioId == audioId) return;
    final audio = state.audios.firstWhere(
      (a) => a.id == audioId,
      orElse: () => state.audios.first,
    );
    final end = _minDuration(state.highlightLength, audio.duration);
    state = state.copyWith(
      selectedAudioId: audioId,
      selectionStart: Duration.zero,
      selectionEnd: end,
    );
  }

  // -------------------------
  // Highlight
  // -------------------------
  void setHighlightLength(Duration d) {
    final audioLen = state.currentAudioDuration;
    final end = _clampEnd(state.selectionStart + d, audioLen);
    state = state.copyWith(highlightLength: d, selectionEnd: end);
  }

  /// 移動精華「起點」，終點 = 起點 + highlightLength（自動夾限於音檔長度）
  void setSelection({required Duration start}) {
    final audioLen = state.currentAudioDuration;
    final clampedStart = _clamp(start, Duration.zero, audioLen);
    final end = _clampEnd(clampedStart + state.highlightLength, audioLen);
    state = state.copyWith(selectionStart: clampedStart, selectionEnd: end);
  }

  void setTransitionMusic(String? path) =>
      state = state.copyWith(transitionMusicPath: path);

  // -------------------------
  // Settings
  // -------------------------
  void setPrice(int podcoin) => state = state.copyWith(pricePodcoin: podcoin);

  void setPublishMode(PublishMode mode) {
    if (mode == PublishMode.now) {
      // 切回「即時」→ 清空排程時間
      state = state.copyWith(publishMode: mode, scheduledAt: null);
    } else {
      state = state.copyWith(publishMode: mode);
    }
  }

  void setScheduledAt(DateTime? dt) => state = state.copyWith(scheduledAt: dt);

  void clearScheduledAt() => state = state.copyWith(scheduledAt: null);

  void addCollaborator(String nameOrEmail) {
    final v = nameOrEmail.trim();
    if (v.isEmpty) return;
    final set = {...state.collaborators, v}; // 去重
    state = state.copyWith(collaborators: set.toList());
  }

  void removeCollaborator(String nameOrEmail) {
    final list = [...state.collaborators]..remove(nameOrEmail);
    state = state.copyWith(collaborators: list);
  }

  // -------------------------
  // Submit（僅 Preview 頁可送出）
  // -------------------------
  Future<void> submit() async {
    if (state.currentPage != 2) return;
    state = state.copyWith(isSaving: true, error: null);
    try {
      // TODO: 串接 API / 上傳 / 建立草稿
      await Future.delayed(const Duration(milliseconds: 800));
      state = state.copyWith(isSaving: false);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  // -------------------------
  // Utils
  // -------------------------
  String _genId(String seed) =>
      '${DateTime.now().microsecondsSinceEpoch}_${seed.hashCode}';

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
}

/// Provider：在 UI 以 ref.watch(createControllerProvider) 取得狀態
final createControllerProvider =
    NotifierProvider<CreateController, CreateState>(CreateController.new);
