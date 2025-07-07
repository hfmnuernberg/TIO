import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/decorators/audio_system_log_decorator.dart';
import 'package:tiomusic/services/decorators/file_picker_log_decorator.dart';
import 'package:tiomusic/services/decorators/file_references_log_decorator.dart';
import 'package:tiomusic/services/decorators/file_system_log_decorator.dart';
import 'package:tiomusic/services/decorators/media_repository_log_decorator.dart';
import 'package:tiomusic/services/decorators/project_repository_log_decorator.dart';
import 'package:tiomusic/services/file_picker.dart';
import 'package:tiomusic/services/file_references.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/impl/file_based_media_repository.dart';
import 'package:tiomusic/services/impl/file_based_project_repository.dart';
import 'package:tiomusic/services/impl/file_references_impl.dart';
import 'package:tiomusic/services/media_repository.dart';
import 'package:tiomusic/services/project_repository.dart';

import '../mocks/audio_system_mock.dart';
import '../mocks/file_picker_mock.dart';
import '../mocks/in_memory_file_system_mock.dart';

class TestContext {
  final FileSystem inMemoryFileSystem = FileSystemLogDecorator(InMemoryFileSystemMock());

  final AudioSystemMock audioSystemMock = AudioSystemMock();
  late final audioSystem = AudioSystemLogDecorator(audioSystemMock);

  late final FilePickerMock filePickerMock = FilePickerMock(inMemoryFileSystem);
  late final filePicker = FilePickerLogDecorator(filePickerMock);

  late final mediaRepo = MediaRepositoryLogDecorator(FileBasedMediaRepository(inMemoryFileSystem));
  late final fileReferences = FileReferencesLogDecorator(FileReferencesImpl(mediaRepo));

  late final projectRepo = ProjectRepositoryLogDecorator(FileBasedProjectRepository(inMemoryFileSystem));

  late final List<SingleChildWidget> providers;

  Future<void> init({bool dismissTutorials = true}) async {
    await inMemoryFileSystem.init();
    await mediaRepo.init();

    var projectLibrary = projectRepo.existsLibrary() ? await projectRepo.loadLibrary() : ProjectLibrary.withDefaults();

    if (dismissTutorials) projectLibrary.dismissAllTutorials();

    await projectRepo.saveLibrary(projectLibrary);
    await fileReferences.init(projectLibrary);

    providers = [
      Provider<AudioSystem>(create: (_) => audioSystem),
      Provider<FilePicker>(create: (_) => filePicker),
      Provider<FileSystem>(create: (_) => inMemoryFileSystem),
      Provider<MediaRepository>(create: (_) => mediaRepo),
      Provider<ProjectRepository>(create: (_) => projectRepo),
      Provider<FileReferences>(create: (_) => fileReferences),
      ChangeNotifierProvider<ProjectLibrary>.value(value: projectLibrary),
    ];
  }
}
