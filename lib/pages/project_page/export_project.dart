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
  String jsonString = jsonEncode(project.toJson());
  await tmpProjectFile.writeAsString(jsonString);
}

Future<File> _createTmpProjectFile(FileSystem fs, Project project) async {
  final tmpProjectFile = File('${fs.tmpFolderPath}/tio-music-project.json');
  await _writeProjectToFile(project, tmpProjectFile);
  return tmpProjectFile;
}

Future<File> _copyMediaToFile(FileSystem fs, String relativePath) {
  final sourceFile = File('${fs.appFolderPath}/$relativePath');
  final destPath = '${fs.tmpFolderPath}/${_getMediaFileName(relativePath)}';
  return sourceFile.copy(destPath);
}

Future<List<File>> _createTmpImageFiles(FileSystem fs, Project project) async {
  final imageFiles = await Future.wait(
    project.blocks
        .whereType<ImageBlock>()
        .whereNot((block) => block.relativePath.isEmpty)
        .map((block) => _copyMediaToFile(fs, block.relativePath)),
  );
  final mediaPlayerFiles = await Future.wait(
    project.blocks
        .whereType<MediaPlayerBlock>()
        .whereNot((block) => block.relativePath.isEmpty)
        .map((block) => _copyMediaToFile(fs, block.relativePath)),
  );
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
  final projectFile = await _createTmpProjectFile(fs, project);
  final imageFiles = await _createTmpImageFiles(fs, project);
  final files = [projectFile, ...imageFiles];

  final archive = await _writeFilesToArchive(fs, files, project);

  _deleteTmpFiles(files);

  return archive;
}

Future<void> exportProject(BuildContext context, Project project) async {
  final fs = context.read<FileSystem>();
  try {
    final archiveFile = await _archiveProject(fs, project);

    if (!context.mounted) return;
    final success = await fs.shareFile(archiveFile.path);
    await archiveFile.delete();

    if (!success) {
      if (context.mounted) showSnackbar(context: context, message: context.l10n.projectExportCancelled)();
      return;
    }

    if (context.mounted) showSnackbar(context: context, message: context.l10n.projectExportSuccess)();
  } catch (e) {
    final logger = createPrefixLogger('ExportProject');
    logger.e('Unable to export project.', error: e);
    if (context.mounted) showSnackbar(context: context, message: context.l10n.projectExportError)();
  }
}
