import 'package:tiomusic/models/project_library.dart';

mixin FileReferences {
  Future<void> init(ProjectLibrary projectLibrary);

  int count(String relativeFilePath);

  Future<void> inc(String relativeFilePath);

  Future<void> dec(String relativeFilePath, ProjectLibrary projectLibrary);
}
