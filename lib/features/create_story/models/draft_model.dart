// story_draft.dart
import 'package:flutter/foundation.dart';

/// 用來暫存「上架故事」五個步驟的資料
class StoryDraft {
  /// Step 1 - 上傳音檔
  String? audioPath;          // 本地檔案路徑（或上傳後的 URL）
  String? audioUrl;           // 若已上傳，可記錄雲端網址
  Duration? audioDuration;    // 可選，後續可存播放長度

  /// Step 2 - 故事內容
  String title = '';
  String? description;
  String? coverImagePath;     // 封面圖片路徑（若有）

  /// Step 3 - 擷取精華
  Duration? highlightStart;
  Duration? highlightEnd;

  /// Step 4 - 上架設定
  bool isPaid = false;
  DateTime? publishAt;        // 預定發布時間（可為 null 表示立即）
  List<String> collaborators = []; // 協作者名稱或 email

  /// Step 5 - 系統層或後端所需
  String? storyId;            // 編輯既有故事時用
  bool isDraftSaved = false;  // 是否已儲存成草稿

  StoryDraft({
    this.audioPath,
    this.audioUrl,
    this.audioDuration,
    this.title = '',
    this.description,
    this.coverImagePath,
    this.highlightStart,
    this.highlightEnd,
    this.isPaid = false,
    this.publishAt,
    List<String>? collaborators,
    this.storyId,
    this.isDraftSaved = false,
  }) : collaborators = collaborators ?? [];

  StoryDraft copyWith({
    String? audioPath,
    String? audioUrl,
    Duration? audioDuration,
    String? title,
    String? description,
    String? coverImagePath,
    Duration? highlightStart,
    Duration? highlightEnd,
    bool? isPaid,
    DateTime? publishAt,
    List<String>? collaborators,
    String? storyId,
    bool? isDraftSaved, String? transitionMusicPath,
  }) {
    return StoryDraft(
      audioPath: audioPath ?? this.audioPath,
      audioUrl: audioUrl ?? this.audioUrl,
      audioDuration: audioDuration ?? this.audioDuration,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      highlightStart: highlightStart ?? this.highlightStart,
      highlightEnd: highlightEnd ?? this.highlightEnd,
      isPaid: isPaid ?? this.isPaid,
      publishAt: publishAt ?? this.publishAt,
      collaborators: collaborators ?? List.from(this.collaborators),
      storyId: storyId ?? this.storyId,
      isDraftSaved: isDraftSaved ?? this.isDraftSaved,
    );
  }

  /// 簡單判斷是否必填欄位都填完
  bool get isComplete =>
      audioPath != null &&
      title.trim().isNotEmpty &&
      description != null;

  /// 轉 JSON：可拿來儲存草稿或上傳後端
  Map<String, dynamic> toJson() {
    return {
      'audioPath': audioPath,
      'audioUrl': audioUrl,
      'audioDuration': audioDuration?.inMilliseconds,
      'title': title,
      'description': description,
      'coverImagePath': coverImagePath,
      'highlightStart': highlightStart?.inMilliseconds,
      'highlightEnd': highlightEnd?.inMilliseconds,
      'isPaid': isPaid,
      'publishAt': publishAt?.toIso8601String(),
      'collaborators': collaborators,
      'storyId': storyId,
      'isDraftSaved': isDraftSaved,
    };
  }

  factory StoryDraft.fromJson(Map<String, dynamic> json) {
    return StoryDraft(
      audioPath: json['audioPath'],
      audioUrl: json['audioUrl'],
      audioDuration: json['audioDuration'] != null
          ? Duration(milliseconds: json['audioDuration'])
          : null,
      title: json['title'] ?? '',
      description: json['description'],
      coverImagePath: json['coverImagePath'],
      highlightStart: json['highlightStart'] != null
          ? Duration(milliseconds: json['highlightStart'])
          : null,
      highlightEnd: json['highlightEnd'] != null
          ? Duration(milliseconds: json['highlightEnd'])
          : null,
      isPaid: json['isPaid'] ?? false,
      publishAt: json['publishAt'] != null
          ? DateTime.tryParse(json['publishAt'])
          : null,
      collaborators: (json['collaborators'] as List?)?.cast<String>() ?? [],
      storyId: json['storyId'],
      isDraftSaved: json['isDraftSaved'] ?? false,
    );
  }

  @override
  String toString() {
    return 'StoryDraft(title: $title, audio: $audioPath, highlight: $highlightStart~$highlightEnd, publishAt: $publishAt)';
  }
}
