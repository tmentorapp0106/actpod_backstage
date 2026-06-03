import 'dart:typed_data';

import 'package:actpod_studio/api/api.dart';
import 'package:actpod_studio/api/response/upload_response/upload_package_image.dart';
import 'package:actpod_studio/api/response/upload_response/upload_story_content.dart';
import 'package:actpod_studio/api/response/upload_response/upload_story_image.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:mime/mime.dart' as m;

class UploadApi {
  Future<UploadStoryContentResponse> uploadStoryContent(
    String filename,
    Uint8List bytes,
  ) async {
    final mimeType = _MimeHelper.resolve(
      filename,
      headerBytes: bytes.take(32).toList().cast<int>().asUint8List(),
    );
    final contentType = _MimeHelper.toBackendContentType(filename);

    var req = {"contentType": contentType};
    final getUrlResponse = await DioClient.handelPostWithToken(
      "/file/story/content",
      req,
    );
    final uploadStoryContentResponse = UploadStoryContentResponse.fromResponse(
      getUrlResponse,
    );

    final response = await http.put(
      Uri.parse(uploadStoryContentResponse.signedUrl),
      headers: {'Content-Type': mimeType},
      body: bytes,
    );

    if (response.statusCode != 200) {
      throw Exception('Upload failed: ${response.statusCode}');
    }
    return uploadStoryContentResponse;
  }

  Future<UploadStoryContentResponse> uploadStoryContentStream(
    String filename,
    Stream<List<int>> stream,
    int contentLength,
  ) async {
    final mimeType = _MimeHelper.resolve(filename);
    final contentType = _MimeHelper.toBackendContentType(filename);

    var req = {"contentType": contentType};
    final getUrlResponse = await DioClient.handelPostWithToken(
      "/file/story/content",
      req,
    );
    final uploadStoryContentResponse = UploadStoryContentResponse.fromResponse(
      getUrlResponse,
    );

    final request = http.StreamedRequest(
      'PUT',
      Uri.parse(uploadStoryContentResponse.signedUrl),
    );
    request.headers['Content-Type'] = mimeType;
    request.contentLength = contentLength;
    await request.sink.addStream(stream);
    await request.sink.close();

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Upload failed: ${response.statusCode}');
    }
    return uploadStoryContentResponse;
  }

  Future<UploadStoryImageResponse> uploadStoryImage(
    String filename,
    Uint8List bytes,
  ) async {
    final getUrlResponse = await DioClient.handelPostWithToken(
      "/file/story/image",
      {},
    );
    final uploadStoryImageResponse = UploadStoryImageResponse.fromResponse(
      getUrlResponse,
    );

    final response = await http.put(
      Uri.parse(uploadStoryImageResponse.signedUrl),
      headers: {'Content-Type': 'application/octet-stream'},
      body: bytes,
    );

    if (response.statusCode != 200) {
      throw Exception('Upload failed: ${response.statusCode}');
    }
    return uploadStoryImageResponse;
  }

  Future<UploadPackageImageResponse> uploadPackageImage(
    String filename,
    Uint8List bytes,
  ) async {
    final getUrlResponse = await DioClient.handelPostWithToken(
      "/file/package/image",
      {},
    );
    final uploadPackageImageResponse = UploadPackageImageResponse.fromResponse(
      getUrlResponse,
    );

    final response = await http.put(
      Uri.parse(uploadPackageImageResponse.signedUrl),
      headers: {'Content-Type': 'application/octet-stream'},
      body: bytes,
    );

    if (response.statusCode != 200) {
      throw Exception('Upload failed: ${response.statusCode}');
    }
    return uploadPackageImageResponse;
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
