import 'dart:async';
import 'dart:js_interop';

import 'package:file_picker/file_picker.dart';
import 'package:web/web.dart';

const _chunkSize = 1000 * 1000;

Future<List<PlatformFile>?> pickAudioFilesImpl({
  required List<String> allowedExtensions,
}) async {
  final completer = Completer<List<PlatformFile>?>();
  final uploadInput = HTMLInputElement()
    ..type = 'file'
    ..multiple = false
    ..accept = allowedExtensions.map((ext) => '.$ext').join(',')
    ..style.display = 'none';

  var changeEventTriggered = false;
  late final StreamSubscription<Event> changeSub;
  late final StreamSubscription<Event> cancelSub;

  Future<void> cleanUp() async {
    await changeSub.cancel();
    await cancelSub.cancel();
    uploadInput.remove();
  }

  changeSub = EventStreamProviders.changeEvent.forTarget(uploadInput).listen((
    event,
  ) async {
    if (changeEventTriggered) return;
    changeEventTriggered = true;

    final files = uploadInput.files;
    if (files == null || files.length == 0) {
      if (!completer.isCompleted) completer.complete(null);
      await cleanUp();
      return;
    }

    final file = files.item(0);
    if (file == null) {
      if (!completer.isCompleted) completer.complete(null);
      await cleanUp();
      return;
    }

    final blobUrl = URL.createObjectURL(file);
    if (!completer.isCompleted) {
      completer.complete([
        PlatformFile(
          name: file.name,
          path: blobUrl,
          size: file.size,
          readStream: _openFileReadStream(file),
        ),
      ]);
    }
    await cleanUp();
  });

  cancelSub = EventStreamProviders.cancelEvent.forTarget(uploadInput).listen((
    event,
  ) async {
    if (!changeEventTriggered && !completer.isCompleted) {
      completer.complete(null);
      await cleanUp();
    }
  });

  document.body?.children.add(uploadInput);
  uploadInput.click();
  return completer.future;
}

Stream<List<int>> _openFileReadStream(File file) async* {
  final reader = FileReader();
  var start = 0;

  while (start < file.size) {
    final end = start + _chunkSize > file.size ? file.size : start + _chunkSize;
    final blob = file.slice(start, end);
    reader.readAsArrayBuffer(blob);
    await EventStreamProviders.loadEvent.forTarget(reader).first;

    final result = reader.result;
    if (result == null) continue;
    if (result.isA<JSArrayBuffer>()) {
      yield (result as JSArrayBuffer).toDart.asUint8List();
      start += _chunkSize;
      continue;
    }
    if (result.isA<JSArray>()) {
      yield (result as JSArray).toDart.cast<int>();
      start += _chunkSize;
    }
  }
}
