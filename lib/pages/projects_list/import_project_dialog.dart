import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/util/app_snackbar.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

Future<void> showImportProjectDialog({required BuildContext context}) => showDialog(
      context: context,
      builder: (context) {
        return ImportProjectDialog(
          onDone: () => Navigator.of(context).pop(),
        );
      },
    );

class ImportProjectDialog extends StatelessWidget {
  final Function() onDone;

  const ImportProjectDialog({
    super.key,
    required this.onDone,
  });

  Future<File?> _getFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    return result == null || result.files.single.path == null ? null : File(result.files.single.path!);
  }

  Future<Project> _readProjectFromFile(File file) async {
    String jsonString = await file.readAsString();
    Map<String, dynamic> jsonData = jsonDecode(jsonString);
    return Project.fromJson(jsonData);
  }

  Future<void> _importProject(BuildContext context) async {
    try {
      final file = await _getFile();

      if (file == null) {
        showSnackbar(context: context, message: 'No project file selected')();
        onDone();
        return;
      }

      final project = await _readProjectFromFile(file);
      context.read<ProjectLibrary>().addProject(project);

      showSnackbar(context: context, message: 'Project imported successfully!')();
      onDone();
    } catch (_) {
      showSnackbar(context: context, message: 'Error importing project')();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Import Project", style: TextStyle(color: ColorTheme.primary)),
      content: Transform.translate(
        offset: const Offset(0, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Would you like to import a project?", style: TextStyle(color: ColorTheme.primary)),
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
              onPressed: () => _importProject(context),
              text: "Import",
              boldText: true,
            ),
          ],
        ),
      ],
    );
  }
}
