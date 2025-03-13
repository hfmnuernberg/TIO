import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/services/path_provider.dart';

class PathProviderMock extends Mock implements PathProvider {
  mockGetApplicationDocumentsDirectory(Directory dir) =>
      when(getApplicationDocumentsDirectory).thenAnswer((_) async => Future.value(dir));

  mockGetTemporaryDirectory(Directory dir) => when(getTemporaryDirectory).thenAnswer((_) async => Future.value(dir));
}
