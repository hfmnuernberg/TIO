import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tiomusic/models/blocks/image_block.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/util/app_snackbar.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

const String mediaFolder = 'media';
const String disclaimer =
    'By exporting and sharing this project, you confirm that you have the necessary rights and permissions for all included content (e.g., text, images, audio recordings) and that you do not violate intellectual property laws or personal rights. You also confirm that you have obtained consent from any individuals depicted or recorded, as required by data protection regulations (including GDPR). If you lack such rights or consents, you must not export and share this project. The creators of this app are not liable for any legal claims arising from your use of this feature.';

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
  final Project project;
  final Function() onDone;

  const ExportProjectDialog({super.key, required this.project, required this.onDone});

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

  Future<File> _writeFilesToArchive(List<File> files) async {
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

    final archive = await _writeFilesToArchive(files);

    _deleteTmpFiles(files);

    return archive;
  }

  Future<void> _exportProject(BuildContext context) async {
    try {
      final archiveFile = await _archiveProject(project);

      final result = await Share.shareXFiles([XFile(archiveFile.path)]);
      await archiveFile.delete();

      if (result.status == ShareResultStatus.dismissed) {
        if (context.mounted) showSnackbar(context: context, message: 'Project export cancelled')();
        onDone();
        return;
      }

      if (context.mounted) showSnackbar(context: context, message: 'Project exported successfully!')();
      onDone();
    } catch (_) {
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
          children: const [Text(disclaimer, style: TextStyle(color: ColorTheme.primary)), SizedBox(height: 10)],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(onPressed: onDone, child: Text('Cancel')),
            TIOFlatButton(onPressed: () => _exportProject(context), text: 'Confirm', boldText: true),
          ],
        ),
      ],
    );
  }
}
