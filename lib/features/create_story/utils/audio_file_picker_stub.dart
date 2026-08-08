import 'package:file_picker/file_picker.dart';

Future<List<PlatformFile>?> pickAudioFilesImpl({
  required List<String> allowedExtensions,
}) async {
  final result = await FilePicker.platform.pickFiles(
    allowMultiple: false,
    type: FileType.custom,
    allowedExtensions: allowedExtensions,
    withData: false,
    withReadStream: true,
  );
  return result?.files;
}
