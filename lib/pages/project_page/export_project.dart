import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/services/archiver.dart';
import 'package:tiomusic/services/file_picker.dart';
import 'package:tiomusic/util/app_snackbar.dart';
import 'package:tiomusic/util/log.dart';

const String mediaFolder = 'media';

Future<void> exportProject(BuildContext context, Project project) async {
  try {
    final filePicker = context.read<FilePicker>();
    final archiver = context.read<Archiver>();

    final archivePath = await archiver.archiveProject(project);
    if (!context.mounted) return;

    final success = await filePicker.shareFile(archivePath);

    await archiver.deleteArchive(archivePath);
    if (!context.mounted) return;

    showSnackbar(
      context: context,
      message: success ? context.l10n.projectExportSuccess : context.l10n.projectExportCancelled,
    )();
  } catch (e) {
    createPrefixLogger('exportProject').e('Unable to export project.', error: e);
    if (context.mounted) showSnackbar(context: context, message: context.l10n.projectExportError)();
  }
}
