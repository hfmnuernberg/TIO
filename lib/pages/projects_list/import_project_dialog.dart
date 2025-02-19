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
            onCancel: () => Navigator.of(context).pop(),
            );
      },
    );

class ImportProjectDialog extends StatelessWidget {
  final Function() onCancel;

  const ImportProjectDialog({super.key, required this.onCancel});

  Future<void> _importFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      final file = File(filePath);
      try {
        String jsonString = await file.readAsString();
        Map<String, dynamic> jsonData = jsonDecode(jsonString);
        Project project = Project.fromJson(jsonData);

        final projectLibrary = context.read<ProjectLibrary>();
        projectLibrary.addProject(project);

        showSnackbar(context: context, message: 'Project file imported successfully!')();

        Navigator.of(context).pop(true);
      } catch (e) {
        showSnackbar(context: context, message: 'Error importing project file: $e')();
      }
    } else {
      showSnackbar(context: context, message: 'No project file selected')();
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
              onPressed: onCancel,
              child: Text('Cancel'),
            ),
            TIOFlatButton(
              onPressed: () => _importFile(context),
              text: "Import",
              boldText: true,
            ),
          ],
        ),
      ],
    );
  }
}
