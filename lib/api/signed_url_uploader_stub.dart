import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'signed_url_upload_result.dart';

Future<SignedUrlUploadResult> putSignedUrlBytesImpl(
  Uri uri, {
  required String mimeType,
  required Uint8List bytes,
  void Function(double progress)? onProgress,
  void Function()? onWaitingForResponse,
}) async {
  return putSignedUrlStreamImpl(
    uri,
    mimeType: mimeType,
    stream: Stream<List<int>>.value(bytes),
    contentLength: bytes.length,
    onProgress: onProgress,
    onWaitingForResponse: onWaitingForResponse,
  );
}

Future<SignedUrlUploadResult> putSignedUrlStreamImpl(
  Uri uri, {
  required String mimeType,
  required Stream<List<int>> stream,
  required int contentLength,
  void Function(double progress)? onProgress,
  void Function()? onWaitingForResponse,
}) async {
  final request = http.StreamedRequest('PUT', uri);
  request.headers['Content-Type'] = mimeType;
  request.contentLength = contentLength;

  final responseFuture = request.send();
  try {
    await request.sink.addStream(
      _trackUploadProgress(stream, contentLength, onProgress),
    );
  } finally {
    await request.sink.close();
  }

  onWaitingForResponse?.call();
  final response = await responseFuture;
  return SignedUrlUploadResult(statusCode: response.statusCode);
}

Stream<List<int>> _trackUploadProgress(
  Stream<List<int>> stream,
  int contentLength,
  void Function(double progress)? onProgress,
) async* {
  var uploaded = 0;
  if (contentLength > 0) onProgress?.call(0);
  await for (final chunk in stream) {
    uploaded += chunk.length;
    yield chunk;
    if (contentLength > 0) {
      onProgress?.call((uploaded / contentLength).clamp(0, 1).toDouble());
    }
  }
  if (contentLength > 0) onProgress?.call(1);
}
