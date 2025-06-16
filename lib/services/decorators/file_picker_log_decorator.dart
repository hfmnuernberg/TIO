import 'package:tiomusic/services/file_picker.dart';
import 'package:tiomusic/services/decorators/log_decorator_utils.dart';
import 'package:tiomusic/util/log.dart';

class FilePickerLogDecorator implements FilePicker {
  static final _logger = createPrefixLogger('FilePicker');

  final FilePicker _filePicker;

  FilePickerLogDecorator(this._filePicker);

  @override
  Future<String?> pickArchive() async {
    final absoluteFilePath = await _filePicker.pickArchive();
    _logger.t('pickArchive(): ${shortenPath(absoluteFilePath)}');
    return absoluteFilePath;
  }

  @override
  Future<String?> pickAudioFromFileSystem() async {
    final absoluteFilePath = await _filePicker.pickAudioFromFileSystem();
    _logger.t('pickAudioFromAppFileSystem(): ${shortenPath(absoluteFilePath)}');
    return absoluteFilePath;
  }

  @override
  Future<String?> pickAudioFromMediaLibrary() async {
    final absoluteFilePath = await _filePicker.pickAudioFromMediaLibrary();
    _logger.t('pickAudioFromMediaLibrary(): ${shortenPath(absoluteFilePath)}');
    return absoluteFilePath;
  }

  @override
  Future<List<String>> pickImages({required int limit}) async {
    final absoluteFilePaths = await _filePicker.pickImages(limit: limit);
    _logger.t('pickImages(): ${absoluteFilePaths.map(shortenPath).join(", ")}');
    return absoluteFilePaths;
  }

  @override
  Future<String?> pickTextFile() async {
    final absoluteFilePath = await _filePicker.pickTextFile();
    _logger.t('pickText(): ${shortenPath(absoluteFilePath)}');
    return absoluteFilePath;
  }

  @override
  Future<bool> shareFile(String absoluteFilePath) async {
    final success = await _filePicker.shareFile(absoluteFilePath);
    _logger.t('shareFile(${shortenPath(absoluteFilePath)}): $success');
    return success;
  }
}
