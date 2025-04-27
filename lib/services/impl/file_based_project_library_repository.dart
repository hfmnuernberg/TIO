import 'dart:convert';

import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/project_library_repository.dart';

const _projectLibraryFilename = 'json_data.txt';

class FileBasedProjectLibraryRepository implements ProjectLibraryRepository {
  final FileSystem _fs;

  FileBasedProjectLibraryRepository(this._fs);

  String get _projectLibraryPath => '${_fs.appFolderPath}/$_projectLibraryFilename';

  @override
  bool exists() => _fs.existsFile(_projectLibraryPath);

  @override
  Future<ProjectLibrary> load() async => ProjectLibrary.fromJson(jsonDecode(await _fs.loadFileAsString(_projectLibraryPath)));

  @override
  Future<void> save(ProjectLibrary projectLibrary) async => _fs.saveFileAsString(_projectLibraryPath, jsonEncode(projectLibrary.toJson()));

  @override
  Future<void> delete() async {
    if (exists()) await _fs.deleteFile(_projectLibraryPath);
  }

  @override
  Future<void> export() async {
    throw UnimplementedError();
  }

  @override
  Future<void> import() async {
    throw UnimplementedError();
  }
}
