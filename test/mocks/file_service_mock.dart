import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/services/file_service.dart';

class FileServiceMock extends Mock implements FileService {
  mockGetApplicationDocumentsDirectory(Directory dir) => when(() =>
      getApplicationDocumentsDirectory()).thenAnswer((_) async => Future.value(dir));

  mockGetTemporaryDirectory(Directory dir) => when(() =>
      getTemporaryDirectory()).thenAnswer((_) async => Future.value(dir));
}
