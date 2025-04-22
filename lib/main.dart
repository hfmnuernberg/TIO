import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tiomusic/app.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/file_references.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/impl/file_based_media_repository.dart';
import 'package:tiomusic/services/impl/file_based_project_library_repository.dart';
import 'package:tiomusic/services/impl/file_picker_delegate.dart';
import 'package:tiomusic/services/impl/file_references_impl.dart';
import 'package:tiomusic/services/impl/file_system_impl.dart';
import 'package:tiomusic/services/impl/file_system_log_decorator.dart';
import 'package:tiomusic/services/impl/image_picker_delegate.dart';
import 'package:tiomusic/services/impl/path_provider_delegate.dart';
import 'package:tiomusic/services/impl/share_plus_delegate.dart';
import 'package:tiomusic/services/media_repository.dart';
import 'package:tiomusic/services/project_library_repository.dart';
import 'package:tiomusic/splash_app.dart';

Future<void> main() async {
  runApp(
    MultiProvider(
      providers: getProviders(),
      child: SplashApp(key: UniqueKey(), returnProjectLibraryAndTheme: runMainApp),
    ),
  );
}

void runMainApp(ProjectLibrary projectLibrary, ThemeData? theme) {
  runApp(MultiProvider(providers: getProviders(), child: App(projectLibrary: projectLibrary, ourTheme: theme)));
}

List<SingleChildWidget> getProviders() {
  final sharePlus = SharePlusDelegate();
  final pathProvider = PathProviderDelegate();
  final filePicker = FilePickerDelegate();
  final imagePicker = ImagePickerDelegate();

  final fileSystem = FileSystemImpl(pathProvider, filePicker, imagePicker, sharePlus);
  final fileSystemWithLogging = FileSystemLogDecorator(fileSystem);
  final projectLibraryRepo = FileBasedProjectLibraryRepository(fileSystemWithLogging);
  final mediaRepo = FileBasedMediaRepository(fileSystemWithLogging);
  final fileReferences = FileReferencesImpl(mediaRepo);

  return [
    Provider<FileSystem>(create: (_) => fileSystemWithLogging),
    Provider<ProjectLibraryRepository>(create: (_) => projectLibraryRepo),
    Provider<MediaRepository>(create: (_) => mediaRepo),
    Provider<FileReferences>(create: (_) => fileReferences),
  ];
}
