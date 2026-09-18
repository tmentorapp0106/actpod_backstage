import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

import 'signed_url_upload_result.dart';

Future<SignedUrlUploadResult> putSignedUrlBytesImpl(
  Uri uri, {
  required String mimeType,
  required Uint8List bytes,
  void Function(double progress)? onProgress,
  void Function()? onWaitingForResponse,
}) {
  final completer = Completer<SignedUrlUploadResult>();
  final xhr = XMLHttpRequest();

  late final StreamSubscription<ProgressEvent> progressSub;
  late final StreamSubscription<ProgressEvent> loadSub;
  late final StreamSubscription<ProgressEvent> errorSub;
  late final StreamSubscription<ProgressEvent> abortSub;

  Future<void> cleanUp() async {
    await progressSub.cancel();
    await loadSub.cancel();
    await errorSub.cancel();
    await abortSub.cancel();
  }

  progressSub = EventStreamProviders.progressEvent.forTarget(xhr.upload).listen(
    (event) {
      if (event.lengthComputable && event.total > 0) {
        onProgress?.call((event.loaded / event.total).clamp(0, 1).toDouble());
      } else if (bytes.isNotEmpty) {
        onProgress?.call((event.loaded / bytes.length).clamp(0, 1).toDouble());
      }
    },
  );

  loadSub = EventStreamProviders.loadEvent.forTarget(xhr).listen((event) async {
    onProgress?.call(1);
    onWaitingForResponse?.call();
    if (!completer.isCompleted) {
      completer.complete(SignedUrlUploadResult(statusCode: xhr.status));
    }
    await cleanUp();
  });

  errorSub = EventStreamProviders.errorEvent.forTarget(xhr).listen((
    event,
  ) async {
    if (!completer.isCompleted) {
      completer.complete(SignedUrlUploadResult(statusCode: xhr.status));
    }
    await cleanUp();
  });

  abortSub = EventStreamProviders.abortEvent.forTarget(xhr).listen((
    event,
  ) async {
    if (!completer.isCompleted) {
      completer.complete(SignedUrlUploadResult(statusCode: xhr.status));
    }
    await cleanUp();
  });

  xhr.open('PUT', uri.toString(), true);
  xhr.setRequestHeader('Content-Type', mimeType);
  onProgress?.call(0);
  xhr.send(bytes.toJS);

  return completer.future;
}

Future<SignedUrlUploadResult> putSignedUrlStreamImpl(
  Uri uri, {
  required String mimeType,
  required Stream<List<int>> stream,
  required int contentLength,
  void Function(double progress)? onProgress,
  void Function()? onWaitingForResponse,
}) async {
  final bytes = await _readAllBytes(stream, contentLength);
  return putSignedUrlBytesImpl(
    uri,
    mimeType: mimeType,
    bytes: bytes,
    onProgress: onProgress,
    onWaitingForResponse: onWaitingForResponse,
  );
}

Future<Uint8List> _readAllBytes(
  Stream<List<int>> stream,
  int contentLength,
) async {
  final builder = BytesBuilder(copy: false);
  await for (final chunk in stream) {
    builder.add(chunk);
  }
  return builder.takeBytes();
}
