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
  Future<String?> pickAudio() async {
    final absoluteFilePath = await _filePicker.pickAudio();
    _logger.t('pickAudio(): ${shortenPath(absoluteFilePath)}');
    return absoluteFilePath;
  }

  @override
  Future<String?> pickImage() async {
    final absoluteFilePath = await _filePicker.pickImage();
    _logger.t('pickImage(): ${shortenPath(absoluteFilePath)}');
    return absoluteFilePath;
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
