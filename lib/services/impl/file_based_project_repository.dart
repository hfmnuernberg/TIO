import 'dart:convert';

import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/project_repository.dart';

const _projectLibraryFilename = 'json_data.txt';

class FileBasedProjectRepository implements ProjectRepository {
  final FileSystem _fs;

  FileBasedProjectRepository(this._fs);

  String get _projectLibraryPath => '${_fs.appFolderPath}/$_projectLibraryFilename';

  @override
  bool existsLibrary() => _fs.existsFile(_projectLibraryPath);

  @override
  Future<ProjectLibrary> loadLibrary() async =>
      ProjectLibrary.fromJson(jsonDecode(await _fs.loadFileAsString(_projectLibraryPath)));

  @override
  Future<void> saveLibrary(ProjectLibrary projectLibrary) async =>
      _fs.saveFileAsString(_projectLibraryPath, jsonEncode(projectLibrary.toJson()));

  @override
  Future<void> deleteLibrary() async {
    if (existsLibrary()) await _fs.deleteFile(_projectLibraryPath);
  }
}
