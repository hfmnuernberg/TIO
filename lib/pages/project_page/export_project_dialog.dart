import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

class ExportProjectDialog extends StatelessWidget {
  final String title;

  const ExportProjectDialog({super.key, required this.title});

  Future<String> _writeJsonFile(BuildContext context) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$title.json';
    final file = File(filePath);
    final projectLibrary = context.read<ProjectLibrary>();

    Map<String, dynamic> jsonData = projectLibrary.toJson();
    String jsonString = jsonEncode(jsonData);

    await file.writeAsString(jsonString);
    return filePath;
  }

  Future<void> _exportFile(BuildContext context) async {
    try {
      final filePath = await _writeJsonFile(context);

      await Share.shareXFiles([XFile(filePath)]);

      Navigator.of(context).pop();
    } catch (e) {
      print('Error exporting project file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting project file')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Export Project", style: TextStyle(color: ColorTheme.primary)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Do you really want to export the project?", style: TextStyle(color: ColorTheme.primary)),
          const SizedBox(height: 10),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        TIOFlatButton(
          onPressed: () => _exportFile(context),
          text: "Export",
          boldText: true,
        ),
      ],
    );
  }
}
