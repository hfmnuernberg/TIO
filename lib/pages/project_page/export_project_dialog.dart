import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tiomusic/models/blocks/image_block.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/util/app_snackbar.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

String _sanitizeString(String value) =>
    value.trim().replaceAll(RegExp(r'\W+'), '-').replaceAll(RegExp(r'^-+|-+$'), '').toLowerCase();

String _getMediaFileName(String value) => value.substring(6);

Future<void> showExportProjectDialog({required BuildContext context, required Project project}) => showDialog(
  context: context,
  builder: (context) {
    return ExportProjectDialog(project: project, onDone: () => Navigator.of(context).pop());
  },
);

class ExportProjectDialog extends StatelessWidget {
  final Project project;
  final Function() onDone;

  const ExportProjectDialog({super.key, required this.project, required this.onDone});

  Future<File> _writeProjectToFile(Project project, File tmpProjectFile) async {
    String jsonString = jsonEncode(project.toJson());
    return await tmpProjectFile.writeAsString(jsonString);
  }

  Future<File> _createTmpProjectFile(Project project) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/tio-music-${_sanitizeString(project.title)}.json';

    return _writeProjectToFile(project, File(filePath));
  }

  Future<File> _copyImageToFile(ImageBlock block, Directory directory) async {
    final sourceFile = File('${directory.path}/${block.relativePath}');
    final destPath = '${directory.path}/${_getMediaFileName(block.relativePath)}.jpg';
    return await sourceFile.copy(destPath);
  }

  Future<List<File>> _createTmpImageFiles(Project project) async {
    final directory = await getApplicationDocumentsDirectory();
    List<File> files = [];

    for (final block in project.blocks) {
      if (block is ImageBlock) {
        final file = await _copyImageToFile(block, directory);
        files.add(file);
      }
    }

    return files;
  }

  Future<File> _writeFilesToArchive(File projectFile, List<File> imageFiles) async {
    final directory = await getApplicationDocumentsDirectory();
    final zipPath = '${directory.path}/tio-music-${_sanitizeString(project.title)}.zip';

    final archive = Archive();

    final projectBytes = await projectFile.readAsBytes();
    archive.addFile(ArchiveFile(basename(projectFile.path), projectBytes.length, projectBytes));

    for (final imageFile in imageFiles) {
      final imageFileBytes = await imageFile.readAsBytes();
      archive.addFile(ArchiveFile(basename(imageFile.path), imageFileBytes.length, imageFileBytes));
    }

    final zipData = ZipEncoder().encode(archive);
    final zipFile = File(zipPath);
    await zipFile.writeAsBytes(zipData);

    return zipFile;
  }

  _deleteTmpFiles(projectFile, imageFiles) async {
    await projectFile.delete();
    for (final file in imageFiles) {
      await file.delete();
    }
  }

  Future<File> _archiveProject(Project project) async {
    final projectFile = await _createTmpProjectFile(project);
    final imageFiles = await _createTmpImageFiles(project);

    final archive = await _writeFilesToArchive(projectFile, imageFiles);

    _deleteTmpFiles(projectFile, imageFiles);

    return archive;
  }

  Future<void> _exportProject(BuildContext context) async {
    try {
      final archiveFile = await _archiveProject(project);

      final result = await Share.shareXFiles([XFile(archiveFile.path)]);
      await archiveFile.delete();

      if (result.status == ShareResultStatus.dismissed) {
        showSnackbar(context: context, message: 'Project export cancelled')();
        onDone();
        return;
      }

      showSnackbar(context: context, message: 'Project exported successfully!')();
      onDone();
    } catch (_) {
      showSnackbar(context: context, message: 'Error exporting project')();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Export Project", style: TextStyle(color: ColorTheme.primary)),
      content: Transform.translate(
        offset: const Offset(0, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Do you really want to export the project?", style: TextStyle(color: ColorTheme.primary)),
            const SizedBox(height: 10),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(onPressed: onDone, child: Text('Cancel')),
            TIOFlatButton(onPressed: () => _exportProject(context), text: "Export", boldText: true),
          ],
        ),
      ],
    );
  }
}
