import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/blocks/image_block.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/util/app_snackbar.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/log.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

const String mediaFolder = 'media';

String _sanitizeString(String value) =>
    value.trim().replaceAll(RegExp(r'\W+'), '-').replaceAll(RegExp(r'^-+|-+$'), '').toLowerCase();

String _getMediaFileName(String value) => value.substring('$mediaFolder/'.length);

Future<void> showExportProjectDialog({required BuildContext context, required Project project}) => showDialog(
  context: context,
  builder: (context) {
    return ExportProjectDialog(project: project, onDone: () => Navigator.of(context).pop());
  },
);

class ExportProjectDialog extends StatelessWidget {
  static final _logger = createPrefixLogger('ExportProjectDialog');

  final Project project;
  final Function() onDone;

  const ExportProjectDialog({super.key, required this.project, required this.onDone});

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
      project.blocks.whereType<ImageBlock>().map((block) => _copyMediaToFile(fs, block.relativePath)),
    );
    final mediaPlayerFiles = await Future.wait(
      project.blocks.whereType<MediaPlayerBlock>().map((block) => _copyMediaToFile(fs, block.relativePath)),
    );
    return [...imageFiles, ...mediaPlayerFiles];
  }

  Future<File> _writeFilesToArchive(FileSystem fs, List<File> files) async {
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

    final archive = await _writeFilesToArchive(fs, files);

    _deleteTmpFiles(files);

    return archive;
  }

  Future<void> _exportProject(BuildContext context) async {
    final fs = context.read<FileSystem>();
    try {
      final archiveFile = await _archiveProject(fs, project);

      if (!context.mounted) return;
      final success = await fs.shareFile(archiveFile.path);
      await archiveFile.delete();

      if (!success) {
        if (context.mounted) showSnackbar(context: context, message: 'Project export cancelled')();
        onDone();
        return;
      }

      if (context.mounted) showSnackbar(context: context, message: 'Project exported successfully!')();
      onDone();
    } catch (e) {
      _logger.e('Unable to export project.', error: e);
      if (context.mounted) showSnackbar(context: context, message: 'Error exporting project')();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Project', style: TextStyle(color: ColorTheme.primary)),
      content: Transform.translate(
        offset: const Offset(0, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('Do you really want to export the project?', style: TextStyle(color: ColorTheme.primary)),
            SizedBox(height: 10),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(onPressed: onDone, child: Text('Cancel')),
            TIOFlatButton(onPressed: () => _exportProject(context), text: 'Export', boldText: true),
          ],
        ),
      ],
    );
  }
}
