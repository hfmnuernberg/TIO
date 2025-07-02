import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/project_page/project_page.dart';
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

import '../../mocks/file_picker_mock.dart';
import '../../mocks/audio_system_mock.dart';
import '../../mocks/in_memory_file_system_mock.dart';
import '../../utils/action_utils.dart';
import '../../utils/project_utils.dart';
import '../../utils/render_utils.dart';

void main() {
  late AudioSystem audioSystemMock;
  late FileSystem inMemoryFileSystem;
  late FilePickerMock filePickerMock;
  late List<SingleChildWidget> providers;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    audioSystemMock = AudioSystemMock();
    inMemoryFileSystem = FileSystemLogDecorator(InMemoryFileSystemMock());
    filePickerMock = FilePickerMock(inMemoryFileSystem);

    final audioSystem = AudioSystemLogDecorator(audioSystemMock);
    final filePicker = FilePickerLogDecorator(filePickerMock);
    final mediaRepo = MediaRepositoryLogDecorator(FileBasedMediaRepository(inMemoryFileSystem));
    final projectRepo = ProjectRepositoryLogDecorator(FileBasedProjectRepository(inMemoryFileSystem));
    final fileReferences = FileReferencesLogDecorator(FileReferencesImpl(mediaRepo));

    await inMemoryFileSystem.init();
    await mediaRepo.init();
    final projectLibrary =
        projectRepo.existsLibrary() ? await projectRepo.loadLibrary() : ProjectLibrary.withDefaults()
          ..dismissAllTutorials();
    await projectRepo.saveLibrary(projectLibrary);
    await fileReferences.init(projectLibrary);
    final project = Project.defaultThumbnail('Test Project');

    providers = [
      Provider<AudioSystem>(create: (_) => audioSystem),
      Provider<FilePicker>(create: (_) => filePicker),
      Provider<FileSystem>(create: (_) => inMemoryFileSystem),
      Provider<MediaRepository>(create: (_) => mediaRepo),
      Provider<ProjectRepository>(create: (_) => projectRepo),
      Provider<FileReferences>(create: (_) => fileReferences),
      ChangeNotifierProvider<ProjectLibrary>.value(value: projectLibrary),
      ChangeNotifierProvider<Project>.value(value: project),
    ];
  });

  group('MediaPlayerTool', () {
    testWidgets('uploads file', (tester) async {
      final filePath = '${inMemoryFileSystem.tmpFolderPath}/audio_file.wav';
      inMemoryFileSystem.saveFileAsBytes(filePath, File('assets/test/ping.wav').readAsBytesSync());
      filePickerMock.mockPickAudioFromFileSystem([filePath]);
      filePickerMock.mockPickAudioFromMediaLibrary([filePath]);

      await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), providers);
      await tester.createMediaPlayerToolInProject();

      await tester.tapAndSettle(find.bySemanticsLabel('Media Player 1'));
      await tester.tapAndSettle(find.bySemanticsLabel('Open files'));

      expect(find.textContaining('audio_file'), findsOneWidget);
    });
  });
}
