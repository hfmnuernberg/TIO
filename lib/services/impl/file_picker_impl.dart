import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tiomusic/services/file_picker.dart' as tio;
import 'package:tiomusic/services/impl/ios_media_library_picker.dart';
import 'package:tiomusic/util/constants/constants.dart';

class FilePickerImpl implements tio.FilePicker {
  final IosMediaLibraryPicker _iosMediaLibraryPicker = IosMediaLibraryPicker();

  @override
  Future<String?> pickArchive() async =>
      (await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['zip']))?.files.single.path;

  @override
  Future<List<String?>?> pickAudioFromFileSystem({required bool isMultipleAllowed}) async =>
      (await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: TIOMusicParams.audioFormats,
        allowMultiple: isMultipleAllowed,
      ))?.paths;

  @override
  Future<List<String?>?> pickAudioFromMediaLibrary({required bool isMultipleAllowed}) async {
    if (Platform.isIOS) return _pickAudioFromIosMediaLibrary(isMultipleAllowed: isMultipleAllowed);
    return (await FilePicker.platform.pickFiles(type: FileType.audio, allowMultiple: isMultipleAllowed))?.paths;
  }

  Future<List<String?>?> _pickAudioFromIosMediaLibrary({required bool isMultipleAllowed}) async {
    final result = await _iosMediaLibraryPicker.pickAudio(allowMultiple: isMultipleAllowed);
    if (result == null) return null;

    final List<String?> paths = [...result.paths];
    for (int i = 0; i < result.skippedCount; i++) {
      paths.add(null);
    }
    return paths;
  }

  @override
  Future<List<String>> pickImages({required int limit}) async =>
      (await ImagePicker().pickMultiImage(limit: limit)).map((xfile) => xfile.path).toList();

  @override
  Future<String?> pickTextFile() async =>
      (await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['txt']))?.files.single.path;

  @override
  Future<bool> shareFile(String absoluteFilePath) async =>
      (await SharePlus.instance.share(
        ShareParams(files: [XFile(absoluteFilePath)], sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1)),
      )).status ==
      ShareResultStatus.success;
}
