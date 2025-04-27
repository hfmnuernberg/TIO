import 'package:image_picker/image_picker.dart';
import 'package:tiomusic/services/image_picker.dart' as tio;

class ImagePickerDelegate implements tio.ImagePicker {
  @override
  Future<XFile?> pickImage() => ImagePicker().pickImage(source: ImageSource.gallery);
}
