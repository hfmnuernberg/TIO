import 'dart:convert';

import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/project_library_repository.dart';
import 'package:tiomusic/util/log.dart';

const _projectLibraryFilename = 'json_data.txt';

class FileBasedProjectLibraryRepository implements ProjectLibraryRepository {
  static final _logger = createPrefixLogger('ProjectLibraryRepo');

  final FileSystem _fs;

  FileBasedProjectLibraryRepository(this._fs);

  String get _projectLibraryPath => '${_fs.appFolderPath}/$_projectLibraryFilename';

  @override
  bool exists() {
    _logger.t('Checking if project library exists.');
    return _fs.existsFile(_projectLibraryPath);
  }

  @override
  Future<ProjectLibrary> load() async {
    _logger.t('Loading project library.');
    return ProjectLibrary.fromJson(jsonDecode(await _fs.loadFileAsString(_projectLibraryPath)));
  }

  @override
  Future<void> save(ProjectLibrary projectLibrary) async {
    _logger.t('Saving project library.');
    await _fs.saveFileAsString(_projectLibraryPath, jsonEncode(projectLibrary.toJson()));
  }

  @override
  Future<void> delete() async {
    _logger.t('Deleting project library.');
    if (exists()) await _fs.deleteFile(_projectLibraryPath);
  }
}
