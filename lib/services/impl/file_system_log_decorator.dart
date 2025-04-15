import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/util/log.dart';

class FileSystemLogDecorator implements FileSystem {
  static final _logger = createPrefixLogger('FileSystem');

  final FileSystem _fs;

  FileSystemLogDecorator(this._fs);

  @override
  Future<void> init() {
    _logger.t('init()');
    return _fs.init();
  }

  @override
  late final String appFolderPath;

  @override
  late final String tmpFolderPath;

  @override
  String toAbsoluteFilePath(String relativeFilePath) {
    final absoluteFilePath = _fs.toAbsoluteFilePath(relativeFilePath);
    _logger.t('toAbsoluteFilePath($relativeFilePath): $absoluteFilePath');
    return absoluteFilePath;
  }

  @override
  String toRelativeFilePath(String absoluteFilePath) {
    final relativeFilePath = _fs.toAbsoluteFilePath(absoluteFilePath);
    _logger.t('toRelativeFilePath($absoluteFilePath): $relativeFilePath');
    return relativeFilePath;
  }

  @override
  Future<void> createFolder(String absoluteFolderPath) {
    // TODO: implement createFolder
    throw UnimplementedError();
  }

  @override
  Future<void> deleteFile(String absoluteFilePath) {
    // TODO: implement deleteFile
    throw UnimplementedError();
  }

  @override
  bool existsFile(String absoluteFilePath) {
    // TODO: implement existsFile
    throw UnimplementedError();
  }

  @override
  Future<bool> existsFileAfterGracePeriod(String absoluteFilePath) {
    // TODO: implement existsFileAfterGracePeriod
    throw UnimplementedError();
  }

  @override
  Future<List<String>> listFiles(String absoluteFolderPath) {
    // TODO: implement listFiles
    throw UnimplementedError();
  }

  @override
  Future<List<int>> loadFileAsBytes(String absoluteFilePath) {
    // TODO: implement loadFileAsBytes
    throw UnimplementedError();
  }

  @override
  Future<String> loadFileAsString(String absoluteFilePath) {
    // TODO: implement loadFileAsString
    throw UnimplementedError();
  }

  @override
  Future<String?> pickAudio() {
    // TODO: implement pickAudio
    throw UnimplementedError();
  }

  @override
  Future<String?> pickImage() {
    // TODO: implement pickImage
    throw UnimplementedError();
  }

  @override
  Future<void> saveFileAsBytes(String absoluteFilePath, List<int> data) {
    // TODO: implement saveFileAsBytes
    throw UnimplementedError();
  }

  @override
  Future<void> saveFileAsString(String absoluteFilePath, String data) {
    // TODO: implement saveFileAsString
    throw UnimplementedError();
  }

  @override
  Future<bool> shareFile(String absoluteFilePath) {
    // TODO: implement shareFile
    throw UnimplementedError();
  }

  @override
  String toBasename(String filePath) {
    // TODO: implement toBasename
    throw UnimplementedError();
  }

  @override
  String? toExtension(String filePath) {
    // TODO: implement toExtension
    throw UnimplementedError();
  }

  @override
  String toFilename(String filePath) {
    // TODO: implement toFilename
    throw UnimplementedError();
  }

  // @override
  // String toFilename(String filePath) => basename(filePath);
  //
  // @override
  // String toBasename(String filePath) => basenameWithoutExtension(filePath);
  //
  // @override
  // String? toExtension(String filePath) => filePath.isEmpty ? null : filePath.split('.').lastOrNull;
  //
  // @override
  // bool existsFile(String absoluteFilePath) => File(absoluteFilePath).existsSync();
  //
  // @override
  // Future<bool> existsFileAfterGracePeriod(String absoluteFilePath) async {
  //   const maxAttempts = 5;
  //   const waitTimeInMs = 100;
  //   for (int attempts = 0; attempts < maxAttempts; attempts++) {
  //     if (existsFile(absoluteFilePath)) return true;
  //     await Future.delayed(const Duration(milliseconds: waitTimeInMs));
  //   }
  //   return false;
  // }
  //
  // @override
  // Future<List<String>> listFiles(String absoluteFolderPath) =>
  //     Directory(absoluteFolderPath).list().map((event) => event.path).toList();
  //
  // @override
  // Future<String> loadFileAsString(String absoluteFilePath) => File(absoluteFilePath).readAsString();
  //
  // @override
  // Future<List<int>> loadFileAsBytes(String absoluteFilePath) => File(absoluteFilePath).readAsBytes();
  //
  // @override
  // Future<void> saveFileAsString(String absoluteFilePath, String data) => File(absoluteFilePath).writeAsString(data);
  //
  // @override
  // Future<void> saveFileAsBytes(String absoluteFilePath, List<int> data) => File(absoluteFilePath).writeAsBytes(data);
  //
  // @override
  // Future<void> deleteFile(String absoluteFilePath) => File(absoluteFilePath).delete();
  //
  // @override
  // Future<void> createFolder(String absoluteFolderPath) => Directory(absoluteFolderPath).create(recursive: true);
  //
  // @override
  // Future<String?> pickAudio() async => (await _filePicker.pickFiles(type: fp.FileType.audio))?.files.single.path;
  //
  // @override
  // Future<String?> pickImage() async => (await _imagePicker.pickImage())?.path;
  //
  // @override
  // Future<bool> shareFile(String absoluteFilePath) async =>
  //     (await _sharePlus.shareXFiles([XFile(absoluteFilePath)])).status != ShareResultStatus.success;
}
