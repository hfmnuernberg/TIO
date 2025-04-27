import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tiomusic/app.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/archiver.dart';
import 'package:tiomusic/services/decorators/archiver_log_decorator.dart';
import 'package:tiomusic/services/decorators/file_picker_log_decorator.dart';
import 'package:tiomusic/services/decorators/file_references_log_decorator.dart';
import 'package:tiomusic/services/decorators/file_system_log_decorator.dart';
import 'package:tiomusic/services/decorators/media_repository_log_decorator.dart';
import 'package:tiomusic/services/decorators/project_repository_log_decorator.dart';
import 'package:tiomusic/services/file_picker.dart';
import 'package:tiomusic/services/file_references.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/impl/file_based_archiver.dart';
import 'package:tiomusic/services/impl/file_based_media_repository.dart';
import 'package:tiomusic/services/impl/file_based_project_repository.dart';
import 'package:tiomusic/services/impl/file_picker_impl.dart';
import 'package:tiomusic/services/impl/file_references_impl.dart';
import 'package:tiomusic/services/impl/file_system_impl.dart';
import 'package:tiomusic/services/media_repository.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/splash_app.dart';

Future<void> main() async {
  runApp(
    MultiProvider(
      providers: _getProviders(),
      child: SplashApp(key: UniqueKey(), returnProjectLibraryAndTheme: runMainApp),
    ),
  );
}

void runMainApp(ProjectLibrary projectLibrary, ThemeData? theme) {
  runApp(MultiProvider(providers: _getProviders(), child: App(projectLibrary: projectLibrary, ourTheme: theme)));
}

List<SingleChildWidget> _getProviders() {
  final filePicker = FilePickerLogDecorator(FilePickerImpl());
  final fileSystem = FileSystemLogDecorator(FileSystemImpl());
  final projectRepo = ProjectRepositoryLogDecorator(FileBasedProjectRepository(fileSystem));
  final mediaRepo = MediaRepositoryLogDecorator(FileBasedMediaRepository(fileSystem));
  final fileReferences = FileReferencesLogDecorator(FileReferencesImpl(mediaRepo));
  final archiver = ArchiverLogDecorator(FileBasedArchiver(fileSystem, mediaRepo));

  return [
    Provider<FilePicker>(create: (_) => filePicker),
    Provider<FileSystem>(create: (_) => fileSystem),
    Provider<ProjectRepository>(create: (_) => projectRepo),
    Provider<MediaRepository>(create: (_) => mediaRepo),
    Provider<FileReferences>(create: (_) => fileReferences),
    Provider<Archiver>(create: (_) => archiver),
  ];
}
