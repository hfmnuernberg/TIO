import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tiomusic/services/file_picker.dart' as tio;

class FilePickerImpl implements tio.FilePicker {
  @override
  Future<String?> pickArchive() async =>
      (await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['zip']))?.files.single.path;

  @override
  Future<String?> pickAudio() async => (await FilePicker.platform.pickFiles(type: FileType.audio))?.files.single.path;

  @override
  Future<List<String>?> pickMultipleImages({required int limit}) async {
    final List<XFile> images = await ImagePicker().pickMultiImage(limit: limit);
    return images.map((xfile) => xfile.path).toList();
  }

  @override
  Future<String?> pickTextFile() async =>
      (await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['txt']))?.files.single.path;

  @override
  Future<bool> shareFile(String absoluteFilePath) async =>
      (await SharePlus.instance.share(ShareParams(files: [XFile(absoluteFilePath)]))).status ==
      ShareResultStatus.success;
}
