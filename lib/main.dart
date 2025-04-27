import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tiomusic/app.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/decorators/file_references_log_decorator.dart';
import 'package:tiomusic/services/decorators/media_repository_log_decorator.dart';
import 'package:tiomusic/services/decorators/project_library_repository_log_decorator.dart';
import 'package:tiomusic/services/file_references.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/impl/file_based_media_repository.dart';
import 'package:tiomusic/services/impl/file_based_project_library_repository.dart';
import 'package:tiomusic/services/delegates/file_picker_delegate.dart';
import 'package:tiomusic/services/impl/file_references_impl.dart';
import 'package:tiomusic/services/impl/file_system_impl.dart';
import 'package:tiomusic/services/decorators/file_system_log_decorator.dart';
import 'package:tiomusic/services/delegates/image_picker_delegate.dart';
import 'package:tiomusic/services/delegates/path_provider_delegate.dart';
import 'package:tiomusic/services/delegates/share_plus_delegate.dart';
import 'package:tiomusic/services/media_repository.dart';
import 'package:tiomusic/services/project_library_repository.dart';
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
  final sharePlus = SharePlusDelegate();
  final pathProvider = PathProviderDelegate();
  final filePicker = FilePickerDelegate();
  final imagePicker = ImagePickerDelegate();

  final fileSystem = FileSystemLogDecorator(FileSystemImpl(pathProvider, filePicker, imagePicker, sharePlus));
  final projectLibraryRepo = ProjectLibraryRepositoryLogDecorator(FileBasedProjectLibraryRepository(fileSystem));
  final mediaRepo = MediaRepositoryLogDecorator(FileBasedMediaRepository(fileSystem));
  final fileReferences = FileReferencesLogDecorator(FileReferencesImpl(mediaRepo));

  return [
    Provider<FileSystem>(create: (_) => fileSystem),
    Provider<ProjectLibraryRepository>(create: (_) => projectLibraryRepo),
    Provider<MediaRepository>(create: (_) => mediaRepo),
    Provider<FileReferences>(create: (_) => fileReferences),
  ];
}
