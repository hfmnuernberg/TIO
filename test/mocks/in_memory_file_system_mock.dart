import 'package:path/path.dart';
import 'package:tiomusic/services/file_system.dart';

class InMemoryFileSystemMock implements FileSystem {
  final _appFolderPath = '/memory/app';
  final _tmpFolderPath = '/memory/tmp';

  final Map<String, List<int>> _files = {};
  final Map<String, List<String>> _folders = {};

  @override
  Future<void> init() async {
    _folders[_appFolderPath] = [];
    _folders[_tmpFolderPath] = [];
  }

  @override
  String get appFolderPath => _appFolderPath;

  @override
  String get tmpFolderPath => _tmpFolderPath;

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
  bool existsFile(String absoluteFilePath) => _files.containsKey(absoluteFilePath);

  @override
  Future<bool> existsFileAfterGracePeriod(String absoluteFilePath) async => existsFile(absoluteFilePath);

  @override
  Future<List<String>> listFiles(String absoluteFolderPath) async => _folders[absoluteFolderPath] ?? [];

  @override
  Future<String> loadFileAsString(String absoluteFilePath) async =>
      String.fromCharCodes(await loadFileAsBytes(absoluteFilePath));

  @override
  Future<List<int>> loadFileAsBytes(String absoluteFilePath) async {
    final bytes = _files[absoluteFilePath];
    if (bytes == null) throw Exception('File not found: $absoluteFilePath');
    return bytes;
  }

  @override
  Future<void> saveFileAsString(String absoluteFilePath, String data) async =>
      saveFileAsBytes(absoluteFilePath, data.codeUnits);

  @override
  Future<void> saveFileAsBytes(String absoluteFilePath, List<int> data) async {
    _files[absoluteFilePath] = data;
    _ensureFolderExistsForFile(absoluteFilePath);
  }

  @override
  Future<void> copyFile(String absoluteSourceFilePath, String absoluteDestinationFilePath) async {
    if (!existsFile(absoluteSourceFilePath)) throw Exception('Source file not found: $absoluteSourceFilePath');
    _files[absoluteDestinationFilePath] = _files[absoluteSourceFilePath]!;
    _ensureFolderExistsForFile(absoluteDestinationFilePath);
  }

  @override
  Future<void> deleteFile(String absoluteFilePath) async {
    _files.remove(absoluteFilePath);
    _folders[_parentFolder(absoluteFilePath)]?.remove(absoluteFilePath);
  }

  @override
  Future<void> deleteIfTmpFile(String absoluteSourceFilePath) async {
    final isTemporaryFile =
        absoluteSourceFilePath.contains('/tmp') ||
        absoluteSourceFilePath.contains('/cache/') ||
        absoluteSourceFilePath.startsWith(_tmpFolderPath);
    if (isTemporaryFile && existsFile(absoluteSourceFilePath)) {
      await deleteFile(absoluteSourceFilePath);
    }
  }

  @override
  Future<void> createFolder(String absoluteFolderPath) async {
    _folders.putIfAbsent(absoluteFolderPath, () => []);
  }

  void _ensureFolderExistsForFile(String filePath) {
    final folder = _parentFolder(filePath);
    _folders.putIfAbsent(folder, () => []);
    if (!_folders[folder]!.contains(filePath)) {
      _folders[folder]!.add(filePath);
    }
  }

  String _parentFolder(String filePath) {
    final lastSlash = filePath.lastIndexOf('/');
    return lastSlash != -1 ? filePath.substring(0, lastSlash) : '/';
  }
}
