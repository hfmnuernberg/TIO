import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/image_block.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/util/app_snackbar.dart';

const String mediaFolder = 'media';

String _sanitizeString(String value) =>
    value.trim().replaceAll(RegExp(r'\W+'), '-').replaceAll(RegExp(r'^-+|-+$'), '').toLowerCase();

String _getMediaFileName(String value) => value.substring('$mediaFolder/'.length);

Future<File> _writeProjectToFile(Project project, File tmpProjectFile) async {
  String jsonString = jsonEncode(project.toJson());
  return tmpProjectFile.writeAsString(jsonString);
}

Future<File> _createTmpProjectFile(Project project) async {
  final tmpDirectory = await getTemporaryDirectory();
  final tmpProjectFile = File('${tmpDirectory.path}/tio-music-project.json');

  return _writeProjectToFile(project, tmpProjectFile);
}

Future<File> _copyMediaToFile(String relativePath) async {
  final directory = await getApplicationDocumentsDirectory();
  final tmpDirectory = await getTemporaryDirectory();

  final sourceFile = File('${directory.path}/$relativePath');
  final destPath = '${tmpDirectory.path}/${_getMediaFileName(relativePath)}';

  return sourceFile.copy(destPath);
}

Future<List<File>> _createTmpImageFiles(Project project) async {
  final imageFiles = await Future.wait(
    project.blocks
        .whereType<ImageBlock>()
        .map((block) => block.relativePath)
        .whereNot((relativePath) => relativePath == '')
        .map(_copyMediaToFile),
  );

  final mediaPlayerFiles = await Future.wait(
    project.blocks
        .whereType<MediaPlayerBlock>()
        .map((block) => block.relativePath)
        .whereNot((relativePath) => relativePath == '')
        .map(_copyMediaToFile),
  );
  return [...imageFiles, ...mediaPlayerFiles];
}

Future<File> _writeFilesToArchive(List<File> files, Project project) async {
  final tmpDirectory = await getTemporaryDirectory();
  final archivePath = '${tmpDirectory.path}/tio-music-${_sanitizeString(project.title)}.zip';

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

Future<File> _archiveProject(Project project) async {
  final projectFile = await _createTmpProjectFile(project);
  final imageFiles = await _createTmpImageFiles(project);
  final files = [projectFile, ...imageFiles];

  final archive = await _writeFilesToArchive(files, project);

  _deleteTmpFiles(files);

  return archive;
}

Future<void> exportProject(BuildContext context, Project project) async {
  try {
    final archiveFile = await _archiveProject(project);

    final result = await Share.shareXFiles([XFile(archiveFile.path)]);
    await archiveFile.delete();

    if (result.status == ShareResultStatus.dismissed) {
      if (context.mounted) showSnackbar(context: context, message: context.l10n.projectExportCancelled)();
      return;
    }

    if (context.mounted) showSnackbar(context: context, message: context.l10n.projectExportSuccess)();
  } catch (_) {
    if (context.mounted) showSnackbar(context: context, message: context.l10n.projectExportError)();
  }
}
