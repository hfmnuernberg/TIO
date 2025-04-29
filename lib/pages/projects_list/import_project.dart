import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/archiver.dart';
import 'package:tiomusic/services/file_picker.dart';
import 'package:tiomusic/services/file_references.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/app_snackbar.dart';
import 'package:tiomusic/util/log.dart';

Future<void> importProject(BuildContext context) async {
  try {
    final filePicker = context.read<FilePicker>();
    final archiver = context.read<Archiver>();
    final projectRepo = context.read<ProjectRepository>();
    final fileReferences = context.read<FileReferences>();
    final projectLibrary = context.read<ProjectLibrary>();

    final archivePath = await filePicker.pickArchive();
    if (archivePath == null) {
      if (!context.mounted) return;
      showSnackbar(context: context, message: context.l10n.projectsImportNoFileSelected)();
      return;
    }

    final project = await archiver.extractProject(archivePath);
    if (!context.mounted) return;

    projectLibrary.addProject(project);
    await projectRepo.saveLibrary(projectLibrary);
    await fileReferences.init(projectLibrary);

    if (context.mounted) showSnackbar(context: context, message: context.l10n.projectsImportSuccess)();
  } catch (e) {
    createPrefixLogger('importProject').e('Unable to import project.', error: e);
    if (context.mounted) showSnackbar(context: context, message: context.l10n.projectsImportError)();
  }
}
