import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/text_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/util/app_snackbar.dart';
import 'package:tiomusic/util/util_functions.dart';

Future<File?> _getFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['txt']);

  return result == null || result.files.single.path == null ? null : File(result.files.single.path!);
}

Future<void> _updateTextBlock(BuildContext context, String text) async {
  final textBlock = Provider.of<ProjectBlock>(context, listen: false) as TextBlock;
  textBlock.content = text;
  textBlock.timeLastModified = getCurrentDateTime();
}

Future<String?> importText(BuildContext context) async {
  final l10n = context.l10n;
  String? importedText;

  try {
    final file = await _getFile();

    if (file == null) {
      if (context.mounted) showSnackbar(context: context, message: l10n.textImportNoFileSelected)();
      return null;
    }

    if (!context.mounted) return null;

    final text = await file.readAsString();

    if (text.isEmpty) {
      if (context.mounted) showSnackbar(context: context, message: l10n.textImportError)();
      return null;
    }

    if (!context.mounted) return null;

    _updateTextBlock(context, text);

    importedText = text;

    if (context.mounted) showSnackbar(context: context, message: l10n.textImportSuccess)();
  } catch (_) {
    if (context.mounted) showSnackbar(context: context, message: l10n.textImportError)();
  }

  return importedText;
}
