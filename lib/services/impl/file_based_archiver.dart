import 'dart:convert';

import 'package:archive/archive_io.dart';
import 'package:collection/collection.dart';
import 'package:tiomusic/models/blocks/image_block.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/services/archiver.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/media_repository.dart';

class FileBasedArchiver implements Archiver {
  final projectFilename = 'tio-music-project.json';

  final FileSystem _fs;
  final MediaRepository _mediaRepo;

  FileBasedArchiver(this._fs, this._mediaRepo);

  String get _tmpProjectFilePath => '${_fs.tmpFolderPath}/$projectFilename';

  @override
  Future<void> init() async {}

  @override
  Future<String> archiveProject(Project project) async {
    final projectFile = await _createTmpProjectFile(project);
    final imageFiles = await _createTmpImageFiles(project);
    final files = [projectFile, ...imageFiles];

    final archivePath = await _writeFilesToArchive(files, project);

    _deleteTmpFiles(files);

    return archivePath;
  }

  @override
  Future<Project> extractProject(String archivePath) async {
    final bytes = await _fs.loadFileAsBytes(archivePath);
    final archive = ZipDecoder().decodeBytes(bytes);

    late Project project;

    for (final file in archive) {
      if (file.name.endsWith(projectFilename)) {
        project = await _readProjectFromArchiveFile(file);
      } else {
        await _writeMediaFileFromArchiveFile(file);
      }
    }

    return project;
  }

  @override
  Future<void> deleteArchive(String archivePath) async => _fs.deleteFile(archivePath);

  Future<String> _createTmpProjectFile(Project project) async {
    await _fs.saveFileAsString(_tmpProjectFilePath, jsonEncode(project.toJson()));
    return _tmpProjectFilePath;
  }

  Future<Project> _readProjectFromArchiveFile(ArchiveFile archiveFile) async {
    final jsonString = utf8.decode(archiveFile.content as List<int>);
    return Project.fromJson(jsonDecode(jsonString));
  }

  Future<List<String>> _createTmpImageFiles(Project project) async {
    final imageFiles = await Future.wait(
      project.blocks
          .whereType<ImageBlock>()
          .whereNot((block) => block.relativePath.isEmpty)
          .map((block) => _copyMediaToFile(block.relativePath)),
    );
    final mediaPlayerFiles = await Future.wait(
      project.blocks
          .whereType<MediaPlayerBlock>()
          .whereNot((block) => block.relativePath.isEmpty)
          .map((block) => _copyMediaToFile(block.relativePath)),
    );
    return [...imageFiles, ...mediaPlayerFiles];
  }

  Future<String> _copyMediaToFile(String relativePath) async {
    final destinationPath = '${_fs.tmpFolderPath}/${_fs.toFilename(relativePath)}';
    await _mediaRepo.export(relativePath, destinationPath);
    return destinationPath;
  }

  Future<void> _writeMediaFileFromArchiveFile(ArchiveFile archiveFile) async =>
      _mediaRepo.save(archiveFile.name, archiveFile.content as List<int>);

  Future<String> _writeFilesToArchive(List<String> files, Project project) async {
    final archivePath = '${_fs.tmpFolderPath}/tio-music-${_sanitizeString(project.title)}.zip';

    final archive = Archive();

    for (final file in files) {
      final fileBytes = await _fs.loadFileAsBytes(file);
      archive.addFile(ArchiveFile(_fs.toFilename(file), fileBytes.length, fileBytes));
    }

    final archiveData = ZipEncoder().encode(archive);
    await _fs.saveFileAsBytes(archivePath, archiveData);

    return archivePath;
  }

  String _sanitizeString(String value) =>
      value.trim().replaceAll(RegExp(r'\W+'), '-').replaceAll(RegExp(r'^-+|-+$'), '').toLowerCase();

  Future<void> _deleteTmpFiles(List<String> files) async => Future.wait(files.map(_fs.deleteFile).toList());
}
