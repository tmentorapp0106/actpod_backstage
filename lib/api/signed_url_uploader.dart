import 'dart:typed_data';

import 'signed_url_upload_result.dart';
import 'signed_url_uploader_stub.dart'
    if (dart.library.js_interop) 'signed_url_uploader_web.dart';

Future<SignedUrlUploadResult> putSignedUrlBytes(
  Uri uri, {
  required String mimeType,
  required Uint8List bytes,
  void Function(double progress)? onProgress,
  void Function()? onWaitingForResponse,
}) {
  return putSignedUrlBytesImpl(
    uri,
    mimeType: mimeType,
    bytes: bytes,
    onProgress: onProgress,
    onWaitingForResponse: onWaitingForResponse,
  );
}

Future<SignedUrlUploadResult> putSignedUrlStream(
  Uri uri, {
  required String mimeType,
  required Stream<List<int>> stream,
  required int contentLength,
  void Function(double progress)? onProgress,
  void Function()? onWaitingForResponse,
}) {
  return putSignedUrlStreamImpl(
    uri,
    mimeType: mimeType,
    stream: stream,
    contentLength: contentLength,
    onProgress: onProgress,
    onWaitingForResponse: onWaitingForResponse,
  );
}
