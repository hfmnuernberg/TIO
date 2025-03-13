import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tiomusic/app.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/impl/file_based_media_repository.dart';
import 'package:tiomusic/services/impl/file_based_project_library_repository.dart';
import 'package:tiomusic/services/impl/file_picker_delegate.dart';
import 'package:tiomusic/services/impl/file_system_impl.dart';
import 'package:tiomusic/services/impl/image_picker_delegate.dart';
import 'package:tiomusic/services/impl/path_provider_delegate.dart';
import 'package:tiomusic/services/impl/share_plus_delegate.dart';
import 'package:tiomusic/services/media_repository.dart';
import 'package:tiomusic/services/path_provider.dart';
import 'package:tiomusic/services/project_library_repository.dart';
import 'package:tiomusic/services/share_plus.dart';
import 'package:tiomusic/splash_app.dart';
import 'package:tiomusic/src/rust/api/simple.dart';
import 'package:tiomusic/src/rust/frb_generated.dart';

Future<void> main() async {
  await RustLib.init();
  await initRustDefaultsManually();
  runApp(
    MultiProvider(
      providers: getProviders(),
      child: SplashApp(key: UniqueKey(), returnProjectLibraryAndTheme: runMainApp),
    )
  );
}

void runMainApp(ProjectLibrary projectLibrary, ThemeData? theme) {
  runApp(
    MultiProvider(
      providers: getProviders(),
      child: App(projectLibrary: projectLibrary, ourTheme: theme),
    )
  );
}

List<SingleChildWidget> getProviders() {
  final sharePlus = SharePlusDelegate();
  final pathProvider = PathProviderDelegate();
  final filePicker = FilePickerDelegate();
  final imagePicker = ImagePickerDelegate();
  final fileSystem = FileSystemImpl(pathProvider, filePicker, imagePicker, sharePlus);
  final projectLibraryRepo = FileBasedProjectLibraryRepository(fileSystem);
  final mediaRepo = FileBasedMediaRepository(fileSystem);
  return [
    Provider<SharePlus>(create: (_) => sharePlus),
    Provider<PathProvider>(create: (_) => pathProvider),
    Provider<FileSystem>(create: (_) => fileSystem),
    Provider<ProjectLibraryRepository>(create: (_) => projectLibraryRepo),
    Provider<MediaRepository>(create: (_) => mediaRepo),
  ];
}
