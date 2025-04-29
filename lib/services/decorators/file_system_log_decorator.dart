import 'package:tiomusic/services/decorators/log_decorator_utils.dart';
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
  late final String appFolderPath = _fs.appFolderPath;

  @override
  late final String tmpFolderPath = _fs.tmpFolderPath;

  @override
  String toAbsoluteFilePath(String relativeFilePath) {
    final absoluteFilePath = _fs.toAbsoluteFilePath(relativeFilePath);
    _logger.t('toAbsoluteFilePath($relativeFilePath): ${shortenPath(absoluteFilePath)}');
    return absoluteFilePath;
  }

  @override
  String toRelativeFilePath(String absoluteFilePath) {
    final relativeFilePath = _fs.toRelativeFilePath(absoluteFilePath);
    _logger.t('toRelativeFilePath(${shortenPath(absoluteFilePath)}): $relativeFilePath');
    return relativeFilePath;
  }

  @override
  Future<void> createFolder(String absoluteFolderPath) async {
    _logger.t('createFolder(${shortenPath(absoluteFolderPath)})');
    return _fs.createFolder(absoluteFolderPath);
  }

  @override
  Future<void> deleteFile(String absoluteFilePath) async {
    _logger.t('deleteFile(${shortenPath(absoluteFilePath)})');
    return _fs.deleteFile(absoluteFilePath);
  }

  @override
  bool existsFile(String absoluteFilePath) {
    final result = _fs.existsFile(absoluteFilePath);
    _logger.t('existsFile(${shortenPath(absoluteFilePath)}): $result');
    return result;
  }

  @override
  Future<bool> existsFileAfterGracePeriod(String absoluteFilePath) async {
    final result = await _fs.existsFileAfterGracePeriod(absoluteFilePath);
    _logger.t('existsFileAfterGracePeriod(${shortenPath(absoluteFilePath)}): $result');
    return result;
  }

  @override
  Future<List<String>> listFiles(String absoluteFolderPath) async {
    final files = await _fs.listFiles(absoluteFolderPath);
    _logger.t('listFiles(${shortenPath(absoluteFolderPath)}): ${files.length} files');
    return files;
  }

  @override
  Future<List<int>> loadFileAsBytes(String absoluteFilePath) async {
    final bytes = await _fs.loadFileAsBytes(absoluteFilePath);
    _logger.t('loadFileAsBytes(${shortenPath(absoluteFilePath)}): ${bytes.length} bytes');
    return bytes;
  }

  @override
  Future<String> loadFileAsString(String absoluteFilePath) async {
    final content = await _fs.loadFileAsString(absoluteFilePath);
    _logger.t('loadFileAsString(${shortenPath(absoluteFilePath)}): ${content.length} chars');
    return content;
  }

  @override
  Future<void> saveFileAsBytes(String absoluteFilePath, List<int> data) async {
    _logger.t('saveFileAsBytes(${shortenPath(absoluteFilePath)}, ${data.length} bytes)');
    return _fs.saveFileAsBytes(absoluteFilePath, data);
  }

  @override
  Future<void> saveFileAsString(String absoluteFilePath, String data) async {
    _logger.t('saveFileAsString(${shortenPath(absoluteFilePath)}, ${data.length} chars)');
    return _fs.saveFileAsString(absoluteFilePath, data);
  }

  @override
  Future<void> copyFile(String absoluteSourceFilePath, String absoluteDestinationFilePath) async {
    _logger.t('copyFile(${shortenPath(absoluteSourceFilePath)}, ${shortenPath(absoluteDestinationFilePath)})');
    return _fs.copyFile(absoluteSourceFilePath, absoluteDestinationFilePath);
  }

  @override
  String toBasename(String filePath) {
    final basename = _fs.toBasename(filePath);
    _logger.t('toBasename(${shortenPath(filePath)}): $basename');
    return basename;
  }

  @override
  String? toExtension(String filePath) {
    final ext = _fs.toExtension(filePath);
    _logger.t('toExtension(${shortenPath(filePath)}): $ext');
    return ext;
  }

  @override
  String toFilename(String filePath) {
    final filename = _fs.toFilename(filePath);
    _logger.t('toFilename(${shortenPath(filePath)}): $filename');
    return filename;
  }
}
