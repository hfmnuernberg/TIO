import 'dart:io';

import 'package:file_picker/file_picker.dart' as fp;
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tiomusic/services/file_picker.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/image_picker.dart';
import 'package:tiomusic/services/path_provider.dart';
import 'package:tiomusic/services/share_plus.dart';

class FileSystemImpl implements FileSystem {
  final PathProvider _pathProvider;
  final FilePicker _filePicker;
  final ImagePicker _imagePicker;
  final SharePlus _sharePlus;

  FileSystemImpl(this._pathProvider, this._filePicker, this._imagePicker, this._sharePlus);

  @override
  Future<void> init() async {
    appFolderPath = (await _pathProvider.getApplicationDocumentsDirectory()).path;
    tmpFolderPath = (await _pathProvider.getTemporaryDirectory()).path;
  }

  @override
  late final String appFolderPath;

  @override
  late final String tmpFolderPath;

  @override
  String toAbsoluteFilePath(String relativeFilePath) => '$appFolderPath/$relativeFilePath';

  @override
  String toRelativeFilePath(String absoluteFilePath) => absoluteFilePath.substring(appFolderPath.length + 1);

  @override
  String toFilename(String filePath) => basename(filePath);

  @override
  String toBasename(String filePath) => basenameWithoutExtension(filePath);

  @override
  String? toExtension(String filePath) => filePath.isEmpty ? null : filePath.split('.').lastOrNull;

  @override
  bool existsFile(String absoluteFilePath) => File(absoluteFilePath).existsSync();

  @override
  Future<bool> existsFileAfterGracePeriod(String absoluteFilePath) async {
    const maxAttempts = 5;
    const waitTimeInMs = 100;
    for (int attempts = 0; attempts < maxAttempts; attempts++) {
      if (existsFile(absoluteFilePath)) return true;
      await Future.delayed(const Duration(milliseconds: waitTimeInMs));
    }
    return false;
  }

  @override
  Future<List<String>> listFiles(String absoluteFolderPath) =>
      Directory(absoluteFolderPath).list().map((event) => event.path).toList();

  @override
  Future<String> loadFileAsString(String absoluteFilePath) => File(absoluteFilePath).readAsString();

  @override
  Future<List<int>> loadFileAsBytes(String absoluteFilePath) => File(absoluteFilePath).readAsBytes();

  @override
  Future<void> saveFileAsString(String absoluteFilePath, String data) => File(absoluteFilePath).writeAsString(data);

  @override
  Future<void> saveFileAsBytes(String absoluteFilePath, List<int> data) => File(absoluteFilePath).writeAsBytes(data);

  @override
  Future<void> deleteFile(String absoluteFilePath) => File(absoluteFilePath).delete();

  @override
  Future<void> createFolder(String absoluteFolderPath) => Directory(absoluteFolderPath).create(recursive: true);

  @override
  Future<String?> pickAudio() async => (await _filePicker.pickFiles(type: fp.FileType.audio))?.files.single.path;

  @override
  Future<String?> pickImage() async => (await _imagePicker.pickImage())?.path;

  @override
  Future<bool> shareFile(String absoluteFilePath) async =>
      (await _sharePlus.shareXFiles([XFile(absoluteFilePath)])).status != ShareResultStatus.success;
}
