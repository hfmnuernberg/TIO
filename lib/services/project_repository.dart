import 'package:tiomusic/models/project_library.dart';

mixin ProjectRepository {
  bool existsLibrary();

  Future<ProjectLibrary> loadLibrary();

  Future<void> saveLibrary(ProjectLibrary projectLibrary);

  Future<void> deleteLibrary();
}
