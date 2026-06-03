import 'dart:typed_data';

/// 發布方式（即時 / 排程）
enum PublishMode { now, schedule }

/// 音檔模型（視需求擴充：遠端 URL、檔案大小、封面等）
class UploadedAudio {
  final String id;
  final String name;
  final String fileName;
  final Uint8List fileBytes;
  final Duration duration;
  final String path;

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
