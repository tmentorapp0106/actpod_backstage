import 'package:file_picker/file_picker.dart';

import 'audio_file_picker_stub.dart'
    if (dart.library.js_interop) 'audio_file_picker_web.dart';

Future<List<PlatformFile>?> pickAudioFiles({
  required List<String> allowedExtensions,
}) {
  return pickAudioFilesImpl(allowedExtensions: allowedExtensions);
}
