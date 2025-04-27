import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/image_block.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/util/app_snackbar.dart';
import 'package:tiomusic/util/log.dart';

const String mediaFolder = 'media';

String _sanitizeString(String value) =>
    value.trim().replaceAll(RegExp(r'\W+'), '-').replaceAll(RegExp(r'^-+|-+$'), '').toLowerCase();

String _getMediaFileName(String value) => value.substring('$mediaFolder/'.length);

Future<void> _writeProjectToFile(Project project, File tmpProjectFile) async {
  print('====== _writeProjectToFile 1');
  String jsonString = jsonEncode(project.toJson());
  print('====== _writeProjectToFile 2');
  await tmpProjectFile.writeAsString(jsonString);
  print('====== _writeProjectToFile 3');
}

Future<File> _createTmpProjectFile(FileSystem fs, Project project) async {
  print('===== _createTmpProjectFile 1');
  final tmpProjectFile = File('${fs.tmpFolderPath}/tio-music-project.json');
  print('===== _createTmpProjectFile 2');
  await _writeProjectToFile(project, tmpProjectFile);
  print('===== _createTmpProjectFile 3');
  return tmpProjectFile;
}

Future<File> _copyMediaToFile(FileSystem fs, String relativePath) {
  final sourceFile = File('${fs.appFolderPath}/$relativePath');
  final destPath = '${fs.tmpFolderPath}/${_getMediaFileName(relativePath)}';
  return sourceFile.copy(destPath);
}

Future<List<File>> _createTmpImageFiles(FileSystem fs, Project project) async {
  print('===== _createTmpImageFiles 1');
  final imageFiles = await Future.wait(
    project.blocks
        .whereType<ImageBlock>()
        .whereNot((block) => block.relativePath.isEmpty)
        .map((block) => _copyMediaToFile(fs, block.relativePath)),
  );
  print('===== _createTmpImageFiles 2');
  final mediaPlayerFiles = await Future.wait(
    project.blocks
        .whereType<MediaPlayerBlock>()
        .whereNot((block) => block.relativePath.isEmpty)
        .map((block) => _copyMediaToFile(fs, block.relativePath)),
  );
  print('===== _createTmpImageFiles 3');
  return [...imageFiles, ...mediaPlayerFiles];
}

Future<File> _writeFilesToArchive(FileSystem fs, List<File> files, Project project) async {
  final archivePath = '${fs.tmpFolderPath}/tio-music-${_sanitizeString(project.title)}.zip';

  final archive = Archive();

  for (final file in files) {
    final fileBytes = await file.readAsBytes();
    archive.addFile(ArchiveFile(basename(file.path), fileBytes.length, fileBytes));
  }

  final archiveData = ZipEncoder().encode(archive);
  final archiveFile = File(archivePath);
  await archiveFile.writeAsBytes(archiveData);

  return archiveFile;
}

Future<void> _deleteTmpFiles(List<File> files) async {
  await Future.wait(files.map<Future<FileSystemEntity>>((file) => file.delete()).toList());
}

Future<File> _archiveProject(FileSystem fs, Project project) async {
  print('==== _archiveProject 1');
  final projectFile = await _createTmpProjectFile(fs, project);
  print('==== _archiveProject 2');
  final imageFiles = await _createTmpImageFiles(fs, project);
  final files = [projectFile, ...imageFiles];

  final archive = await _writeFilesToArchive(fs, files, project);

  _deleteTmpFiles(files);

  return archive;
}

Future<void> exportProject(BuildContext context, Project project) async {
  print('=== exportProject 1');
  final fs = context.read<FileSystem>();
  try {
    final archiveFile = await _archiveProject(fs, project);
    print('=== exportProject 2');
    if (!context.mounted) return;
    print('=== exportProject 3');
    final success = await fs.shareFile(archiveFile.path);
    print('=== exportProject 4');
    await archiveFile.delete();
    print('=== exportProject 5');

    if (!success) {
      print('=== exportProject 6.a.1');
      if (context.mounted) showSnackbar(context: context, message: context.l10n.projectExportCancelled)();
      print('=== exportProject 6.a.2');
      return;
    }
    print('=== exportProject 6.b');
    if (context.mounted) showSnackbar(context: context, message: context.l10n.projectExportSuccess)();
    print('=== exportProject 7');
  } catch (e) {
    print('=== exportProject error');
    final logger = createPrefixLogger('ExportProject');
    logger.e('Unable to export project.', error: e);
    if (context.mounted) showSnackbar(context: context, message: context.l10n.projectExportError)();
  }
}
