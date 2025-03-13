import 'package:tiomusic/models/project_library.dart';

mixin ProjectLibraryRepository {
  bool exists();

  Future<ProjectLibrary> load();

  Future<void> save(ProjectLibrary projectLibrary);

  Future<void> delete();
}
