import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/services/file_picker.dart';
import 'package:tiomusic/services/file_system.dart';

class FilePickerMock extends Mock implements FilePicker {
  final FileSystem? _fs;

  FilePickerMock([this._fs]);

  void mockPickArchive(String? path) => when(pickArchive).thenAnswer((_) async => path);
  void mockPickAudio(String? path) => when(pickAudio).thenAnswer((_) async => path);
  void mockPickMultipleImages(List<String>? paths) => when(pickMultipleImages).thenAnswer((_) async => paths);
  void mockPickTextFile(String? path) => when(pickTextFile).thenAnswer((_) async => path);

  void mockShareFile(bool success) => when(() => shareFile(any())).thenAnswer((invocation) async => success);

  void mockShareFileAndCapture(String path) => when(() => shareFile(any())).thenAnswer((invocation) async {
    if (_fs == null) return false;
    final lastSharedFilePath = invocation.positionalArguments.first as String?;
    if (lastSharedFilePath == null) return false;
    _fs.copyFile(lastSharedFilePath, path);
    return true;
  });
}
