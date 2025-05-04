import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/text_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/services/file_picker.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/util/app_snackbar.dart';
import 'package:tiomusic/util/log.dart';
import 'package:tiomusic/util/util_functions.dart';

Future<void> _updateTextBlock(BuildContext context, String text) async {
  final textBlock = Provider.of<ProjectBlock>(context, listen: false) as TextBlock;
  textBlock.content = text;
  textBlock.timeLastModified = getCurrentDateTime();
}

Future<String?> importText(BuildContext context) async {
  final l10n = context.l10n;
  try {
    final fs = context.read<FileSystem>();
    final filePicker = context.read<FilePicker>();

    final filePath = await filePicker.pickTextFile();
    if (filePath == null) {
      if (!context.mounted) return null;
      showSnackbar(context: context, message: l10n.textImportNoFileSelected)();
      return null;
    }

    final text = await fs.loadFileAsString(filePath);
    if (!context.mounted) return null;

    if (text.isEmpty) {
      showSnackbar(context: context, message: l10n.textImportError)();
      return null;
    }

    await _updateTextBlock(context, text);

    if (context.mounted) showSnackbar(context: context, message: l10n.textImportSuccess)();

    return text;
  } catch (e) {
    createPrefixLogger('importText').e('Unable to import text.', error: e);
    if (context.mounted) showSnackbar(context: context, message: l10n.textImportError)();
    return null;
  }
}
