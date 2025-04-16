import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/file_references.dart';
import 'package:tiomusic/services/project_library_repository.dart';
import 'package:tiomusic/util/app_snackbar.dart';
import 'package:tiomusic/util/log.dart';

Future<File?> _getFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['zip']);

  return result == null || result.files.single.path == null ? null : File(result.files.single.path!);
}

Future<Project> _readProjectFromArchiveFile(ArchiveFile archiveFile) async {
  final jsonString = utf8.decode(archiveFile.content as List<int>);
  final Map<String, dynamic> jsonData = jsonDecode(jsonString);
  return Project.fromJson(jsonData);
}

Future<void> _writeMediaFileFromArchiveFile(ArchiveFile archiveFile, Directory directory) async {
  final mediaFile = File('${directory.path}/media/${archiveFile.name}');
  await mediaFile.writeAsBytes(archiveFile.content as List<int>);
}

Future<Project?> _extractArchive(BuildContext context, File archiveFile) async {
  final directory = await getApplicationDocumentsDirectory();
  final bytes = await archiveFile.readAsBytes();
  final archive = ZipDecoder().decodeBytes(bytes);

  Project? project;

  for (final file in archive) {
    if (file.name.endsWith('.json')) {
      project = await _readProjectFromArchiveFile(file);
    } else {
      await _writeMediaFileFromArchiveFile(file, directory);
    }
  }

  return project;
}

Future<void> importProject(BuildContext context) async {
  final l10n = context.l10n;

  final projectLibraryRepo = context.read<ProjectLibraryRepository>();
  final fileReferences = context.read<FileReferences>();
  final projectLibrary = context.read<ProjectLibrary>();

  try {
    final file = await _getFile();

    if (file == null) {
      if (context.mounted) showSnackbar(context: context, message: l10n.projectsImportNoFileSelected)();
      return;
    }

    if (!context.mounted) return;

    final project = await _extractArchive(context, file);

    if (project == null) {
      if (context.mounted) showSnackbar(context: context, message: l10n.projectsImportError)();
      return;
    }

    if (!context.mounted) return;

    projectLibrary.addProject(project);
    await projectLibraryRepo.save(projectLibrary);
    await fileReferences.init(projectLibrary);

    if (context.mounted) showSnackbar(context: context, message: l10n.projectsImportSuccess)();
  } catch (e) {
    final logger = createPrefixLogger('ImportProject');
    logger.e('Unable to import project.', error: e);
    if (context.mounted) showSnackbar(context: context, message: l10n.projectsImportError)();
  }
}
