import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/util/app_snackbar.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

String _sanitizeString(String value) =>
    value.trim().replaceAll(RegExp(r'\W+'), '-').replaceAll(RegExp(r'^-+|-+$'), '').toLowerCase();

Future<void> showExportProjectDialog({required BuildContext context, required String title}) => showDialog(
      context: context,
      builder: (context) {
        return ExportProjectDialog(
          title: title,
          onDone: () => Navigator.of(context).pop(),
        );
      },
    );

class ExportProjectDialog extends StatelessWidget {
  final String title;
  final Function() onDone;

  const ExportProjectDialog({
    super.key,
    required this.title,
    required this.onDone,
  });

  Future<File> _getFile(Project project) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/tio-music-${_sanitizeString(project.title)}.json';
    return File(filePath);
  }

  Future<void> _writeProjectToFile(Project project, File file) async {
    String jsonString = jsonEncode(project.toJson());
    await file.writeAsString(jsonString);
  }

  Future<void> _exportProject(BuildContext context) async {
    try {
      final project = context.read<ProjectLibrary>().projects.first;
      final tmpFile = await _getFile(project);

      await _writeProjectToFile(project, tmpFile);
      await Share.shareXFiles([XFile(tmpFile.path)]);
      await tmpFile.delete();

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
            TextButton(
              onPressed: onDone,
              child: Text('Cancel'),
            ),
            TIOFlatButton(
              onPressed: () => _exportProject(context),
              text: "Export",
              boldText: true,
            ),
          ],
        ),
      ],
    );
  }
}
