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
      (await FilePicker.pickFile(type: FileType.custom, allowedExtensions: ['zip']))?.path;

  @override
  Future<List<String?>?> pickAudioFromFileSystem({required bool isMultipleAllowed}) => _pickFiles(
    type: FileType.custom,
    allowedExtensions: TIOMusicParams.audioFormats,
    isMultipleAllowed: isMultipleAllowed,
  );

  @override
  Future<List<String?>?> pickAudioFromMediaLibrary({required bool isMultipleAllowed}) async {
    if (Platform.isIOS) return _pickAudioFromIosMediaLibrary(isMultipleAllowed: isMultipleAllowed);
    return _pickFiles(type: FileType.audio, isMultipleAllowed: isMultipleAllowed);
  }

  Future<List<String?>?> _pickFiles({
    required FileType type,
    List<String>? allowedExtensions,
    required bool isMultipleAllowed,
  }) async {
    if (!isMultipleAllowed) {
      final file = await FilePicker.pickFile(type: type, allowedExtensions: allowedExtensions);
      return file == null ? null : [file.path];
    }
    final files = await FilePicker.pickFiles(type: type, allowedExtensions: allowedExtensions);
    return files.isEmpty ? null : files.map((file) => file.path).toList();
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
      (await FilePicker.pickFile(type: FileType.custom, allowedExtensions: ['txt']))?.path;

  @override
  Future<bool> shareFile(String absoluteFilePath) async =>
      (await SharePlus.instance.share(
        ShareParams(files: [XFile(absoluteFilePath)], sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1)),
      )).status ==
      ShareResultStatus.success;
}
