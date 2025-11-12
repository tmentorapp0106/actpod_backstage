import 'dart:typed_data';

import 'package:actpod_studio/features/api/api.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:mime/mime.dart' as m;

class UploadApi {
  Future<String> uploadStoryContent(String filename, Uint8List bytes) async {
    final mimeType = _MimeHelper.resolve(
      filename,
      headerBytes: bytes.take(32).toList().cast<int>().asUint8List(),
    );
    final contentType = _MimeHelper.toBackendContentType(filename);

    var req = {"contentType": contentType};
    Response getUrlResponse = await DioClient.handelPostWithToken(
      "/file/story/content",
      req,
    );

    final response = await http.put(
      Uri.parse(getUrlResponse.data['data']['signedUrl']),
      headers: {'Content-Type': mimeType},
      body: bytes,
    );

    if (response.statusCode != 200) {
      throw Exception('Upload failed: ${response.statusCode}');
    }
    return getUrlResponse.data['data']['publicUrl'];
  }

  Future<String> uploadStoryImage(String filename, Uint8List bytes) async {
    Response getUrlResponse = await DioClient.handelPostWithToken(
      "/file/story/image",
      {},
    );

    final response = await http.put(
      Uri.parse(getUrlResponse.data['data']['signedUrl']),
      headers: {'Content-Type': 'application/octet-stream'},
      body: bytes,
    );

    if (response.statusCode != 200) {
      throw Exception('Upload failed: ${response.statusCode}');
    }
    return getUrlResponse.data['data']['publicUrl'];
  }
}

extension Uint8ListExt on List<int> {
  Uint8List asUint8List() => Uint8List.fromList(this);
}

class _MimeHelper {
  static const _fallback = {
    '.mp3': 'audio/mpeg',
    '.m4a': 'audio/mp4', // 常見；有些系統用 audio/x-m4a 也可
    '.wav': 'audio/wav',
    '.aac': 'audio/aac',
    '.flac': 'audio/flac',
    '.ogg': 'audio/ogg',
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.png': 'image/png',
  };

  /// 推斷 MIME；先嘗試用 mime 包，失敗就用副檔名 fallback
  static String resolve(String filename, {Uint8List? headerBytes}) {
    final ext = p.extension(filename).toLowerCase();
    final byMime = m.lookupMimeType(filename, headerBytes: headerBytes);
    return byMime ?? _fallback[ext] ?? 'application/octet-stream';
  }

  /// 你後端目前要的 contentType（mp3 / m4a ...）字串
  static String toBackendContentType(String filename) {
    final ext = p.extension(filename).toLowerCase();
    switch (ext) {
      case '.mp3':
        return 'mp3';
      case '.m4a':
        return 'm4a';
      case '.wav':
        return 'wav';
      case '.aac':
        return 'aac';
      case '.flac':
        return 'flac';
      case '.ogg':
        return 'ogg';
      case '.jpg':
        return 'jpg';
      case '.jpeg':
        return 'jpeg';
      case '.png':
        return 'png';
      default:
        throw Exception('Unsupported file type: $ext');
    }
  }
}
