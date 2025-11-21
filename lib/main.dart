import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tiomusic/app.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/archiver.dart';
import 'package:tiomusic/services/audio_session.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/decorators/archiver_log_decorator.dart';
import 'package:tiomusic/services/decorators/audio_session_log_decorator.dart';
import 'package:tiomusic/services/decorators/audio_system_log_decorator.dart';
import 'package:tiomusic/services/decorators/file_picker_log_decorator.dart';
import 'package:tiomusic/services/decorators/file_references_log_decorator.dart';
import 'package:tiomusic/services/decorators/file_system_log_decorator.dart';
import 'package:tiomusic/services/decorators/flash_cards_log_decorator.dart';
import 'package:tiomusic/services/decorators/media_repository_log_decorator.dart';
import 'package:tiomusic/services/decorators/project_repository_log_decorator.dart';
import 'package:tiomusic/services/decorators/wakelock_log_decorator.dart';
import 'package:tiomusic/services/file_picker.dart';
import 'package:tiomusic/services/file_references.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/flash_cards.dart';
import 'package:tiomusic/services/impl/audio_session_impl.dart';
import 'package:tiomusic/services/impl/file_based_archiver.dart';
import 'package:tiomusic/services/impl/file_based_media_repository.dart';
import 'package:tiomusic/services/impl/file_based_project_repository.dart';
import 'package:tiomusic/services/impl/file_picker_impl.dart';
import 'package:tiomusic/services/impl/file_references_impl.dart';
import 'package:tiomusic/services/impl/file_system_impl.dart';
import 'package:tiomusic/services/impl/flash_cards_impl.dart';
import 'package:tiomusic/services/impl/rust_based_audio_system.dart';
import 'package:tiomusic/services/impl/wakelock_plus_delegate.dart';
import 'package:tiomusic/services/media_repository.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/services/wakelock.dart';
import 'package:tiomusic/splash_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final platform = ImagePickerPlatform.instance;
  if (platform is ImagePickerAndroid) {
    platform.useAndroidPhotoPicker = true;
  }

  runApp(
    MultiProvider(
      providers: _getProviders(),
      child: SplashApp(key: UniqueKey(), returnProjectLibraryAndTheme: runMainApp),
    ),
  );
}

void runMainApp(ProjectLibrary projectLibrary, ThemeData? theme) {
  runApp(
    MultiProvider(
      providers: _getProviders(),
      child: App(projectLibrary: projectLibrary, ourTheme: theme),
    ),
  );
}

List<SingleChildWidget> _getProviders() {
  final audioSystem = AudioSystemLogDecorator(RustBasedAudioSystem());
  final audioSession = AudioSessionLogDecorator(AudioSessionImpl());
  final filePicker = FilePickerLogDecorator(FilePickerImpl());
  final fileSystem = FileSystemLogDecorator(FileSystemImpl());
  final projectRepo = ProjectRepositoryLogDecorator(FileBasedProjectRepository(fileSystem));
  final mediaRepo = MediaRepositoryLogDecorator(FileBasedMediaRepository(fileSystem));
  final fileReferences = FileReferencesLogDecorator(FileReferencesImpl(mediaRepo));
  final archiver = ArchiverLogDecorator(FileBasedArchiver(fileSystem, mediaRepo));
  final wakelock = WakelockLogDecorator(WakelockPlusDelegate());
  final flashCards = FlashCardsLogDecorator(FlashCardsImpl(projectRepo));

  return [
    Provider<AudioSystem>(create: (_) => audioSystem),
    Provider<AudioSession>(create: (_) => audioSession),
    Provider<FilePicker>(create: (_) => filePicker),
    Provider<FileSystem>(create: (_) => fileSystem),
    Provider<ProjectRepository>(create: (_) => projectRepo),
    Provider<MediaRepository>(create: (_) => mediaRepo),
    Provider<FileReferences>(create: (_) => fileReferences),
    Provider<Archiver>(create: (_) => archiver),
    Provider<Wakelock>(create: (_) => wakelock),
    Provider<FlashCards>(create: (_) => flashCards),
  ];
}
