import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tiomusic/models/project.dart';
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
import 'package:tiomusic/services/impl/file_based_archiver.dart';
import 'package:tiomusic/services/impl/file_based_media_repository.dart';
import 'package:tiomusic/services/impl/file_based_project_repository.dart';
import 'package:tiomusic/services/impl/file_references_impl.dart';
import 'package:tiomusic/services/impl/flash_cards_impl.dart';
import 'package:tiomusic/services/media_repository.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/services/wakelock.dart';

import '../mocks/audio_session_mock.dart';
import '../mocks/audio_system/audio_system_mock.dart';
import '../mocks/file_picker_mock.dart';
import '../mocks/in_memory_file_system_mock.dart';
import '../mocks/wakelock_mock.dart';

class TestContext {
  final FileSystem inMemoryFileSystem = FileSystemLogDecorator(InMemoryFileSystemMock());

  final AudioSystemMock audioSystemMock = AudioSystemMock();
  late final audioSystem = AudioSystemLogDecorator(audioSystemMock);

  final AudioSessionMock audioSessionMock = AudioSessionMock();
  late final audioSession = AudioSessionLogDecorator(audioSessionMock);

  late final FilePickerMock filePickerMock = FilePickerMock(inMemoryFileSystem);
  late final filePicker = FilePickerLogDecorator(filePickerMock);

  late final mediaRepo = MediaRepositoryLogDecorator(FileBasedMediaRepository(inMemoryFileSystem));
  late final fileReferences = FileReferencesLogDecorator(FileReferencesImpl(mediaRepo));

  late final archiver = ArchiverLogDecorator(FileBasedArchiver(inMemoryFileSystem, mediaRepo));

  late final projectRepo = ProjectRepositoryLogDecorator(FileBasedProjectRepository(inMemoryFileSystem));

  final WakelockMock wakelockMock = WakelockMock();
  late final wakelock = WakelockLogDecorator(wakelockMock);

  late final flashCards = FlashCardsLogDecorator(FlashCardsImpl(projectRepo, Random(42)));

  late final List<SingleChildWidget> providers;

  Future<void> init({bool dismissTutorials = true, Project? project}) async {
    await inMemoryFileSystem.init();
    await mediaRepo.init();

    var projectLibrary = projectRepo.existsLibrary() ? await projectRepo.loadLibrary() : ProjectLibrary.withDefaults();

    if (dismissTutorials) projectLibrary.dismissAllTutorials();

    await projectRepo.saveLibrary(projectLibrary);
    await fileReferences.init(projectLibrary);
    await flashCards.init();

    providers = [
      Provider<AudioSystem>(create: (_) => audioSystem),
      Provider<AudioSession>(create: (_) => audioSession),
      Provider<FilePicker>(create: (_) => filePicker),
      Provider<FileSystem>(create: (_) => inMemoryFileSystem),
      Provider<MediaRepository>(create: (_) => mediaRepo),
      Provider<ProjectRepository>(create: (_) => projectRepo),
      Provider<FileReferences>(create: (_) => fileReferences),
      Provider<Archiver>(create: (_) => archiver),
      Provider<Wakelock>(create: (_) => wakelock),
      Provider<FlashCards>(create: (_) => flashCards),
      ChangeNotifierProvider<ProjectLibrary>.value(value: projectLibrary),
      if (project != null) ChangeNotifierProvider<Project>.value(value: project),
    ];
  }
}
