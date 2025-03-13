import 'package:file_picker/file_picker.dart';

mixin FilePicker {
  Future<FilePickerResult?> pickFiles({FileType type});
}
