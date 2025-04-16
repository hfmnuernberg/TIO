import 'package:file_picker/file_picker.dart';
import 'package:tiomusic/services/file_picker.dart' as tio;

class FilePickerDelegate implements tio.FilePicker {
  @override
  Future<FilePickerResult?> pickFiles({FileType type = FileType.any}) => FilePicker.platform.pickFiles(type: type);
}
