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
  Future<String?> pickAudio() async {
    final path = await _fs.pickAudio();
    _logger.t('pickAudio(): $path');
    return path;
  }

  @override
  Future<String?> pickImage() async {
    final path = await _fs.pickImage();
    _logger.t('pickImage(): $path');
    return path;
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
  Future<bool> shareFile(String absoluteFilePath) async {
    final result = await _fs.shareFile(absoluteFilePath);
    _logger.t('shareFile(${shortenPath(absoluteFilePath)}): $result');
    return result;
  }

  @override
  String toBasename(String filePath) {
    final basename = _fs.toBasename(filePath);
    _logger.t('toBasename($filePath): $basename');
    return basename;
  }

  @override
  String? toExtension(String filePath) {
    final ext = _fs.toExtension(filePath);
    _logger.t('toExtension($filePath): $ext');
    return ext;
  }

  @override
  String toFilename(String filePath) {
    final filename = _fs.toFilename(filePath);
    _logger.t('toFilename($filePath): $filename');
    return filename;
  }
}
