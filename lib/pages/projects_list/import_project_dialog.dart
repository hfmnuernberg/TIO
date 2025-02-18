import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

class ImportProjectDialog extends StatelessWidget {

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
        Project project = ProjectLibrary.fromJson(jsonData).projects[0];

        final projectLibrary = context.read<ProjectLibrary>();
        projectLibrary.addProject(project);

        if (context.mounted) {
          FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Project file imported successfully!')),
        );

        Navigator.of(context).pop(true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing project file: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No project file selected')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Import Project", style: TextStyle(color: ColorTheme.primary)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Would you like to import a project?", style: TextStyle(color: ColorTheme.primary)),
          const SizedBox(height: 10),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        TIOFlatButton(
          onPressed: () => _importFile(context),
          text: "Import",
          boldText: true,
        ),
      ],
    );
  }
}
