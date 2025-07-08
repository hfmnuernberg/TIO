import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/models/tuner_type.dart';
import 'package:tiomusic/pages/project_page/project_page.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/decorators/audio_system_log_decorator.dart';
import 'package:tiomusic/services/decorators/file_references_log_decorator.dart';
import 'package:tiomusic/services/decorators/file_system_log_decorator.dart';
import 'package:tiomusic/services/decorators/media_repository_log_decorator.dart';
import 'package:tiomusic/services/decorators/project_repository_log_decorator.dart';
import 'package:tiomusic/services/file_references.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/impl/file_based_media_repository.dart';
import 'package:tiomusic/services/impl/file_based_project_repository.dart';
import 'package:tiomusic/services/impl/file_references_impl.dart';
import 'package:tiomusic/services/media_repository.dart';
import 'package:tiomusic/services/project_repository.dart';

import '../../mocks/audio_system_mock.dart';
import '../../mocks/in_memory_file_system_mock.dart';
import '../../utils/action_utils.dart';
import '../../utils/project_utils.dart';
import '../../utils/render_utils.dart';

extension WidgetTesterTunerExtension on WidgetTester {
  void expectTunerSelected(TunerType expected) {
    final selected = widget<ToggleButtons>(find.byType(ToggleButtons)).isSelected;

    for (int i = 0; i < selected.length; i++) {
      if (i == expected.index) {
        expect(selected[i], isTrue, reason: 'Expected ${expected.name} to be selected');
      } else {
        expect(selected[i], isFalse, reason: 'Expected only ${expected.name} to be selected');
      }
    }
  }
}

void main() {
  late AudioSystem audioSystemMock;
  late FileSystem inMemoryFileSystem;
  late List<SingleChildWidget> providers;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    audioSystemMock = AudioSystemMock();
    inMemoryFileSystem = FileSystemLogDecorator(InMemoryFileSystemMock());

    final audioSystem = AudioSystemLogDecorator(audioSystemMock);
    final mediaRepo = MediaRepositoryLogDecorator(FileBasedMediaRepository(inMemoryFileSystem));
    final projectRepo = ProjectRepositoryLogDecorator(FileBasedProjectRepository(inMemoryFileSystem));
    final fileReferences = FileReferencesLogDecorator(FileReferencesImpl(mediaRepo));

    final projectLibrary =
        projectRepo.existsLibrary() ? await projectRepo.loadLibrary() : ProjectLibrary.withDefaults()
          ..dismissAllTutorials();
    await projectRepo.saveLibrary(projectLibrary);
    final project = Project.defaultThumbnail('Test Project');

    providers = [
      Provider<AudioSystem>(create: (_) => audioSystem),
      Provider<FileSystem>(create: (_) => inMemoryFileSystem),
      Provider<MediaRepository>(create: (_) => mediaRepo),
      Provider<ProjectRepository>(create: (_) => projectRepo),
      Provider<FileReferences>(create: (_) => fileReferences),
      ChangeNotifierProvider<ProjectLibrary>.value(value: projectLibrary),
      ChangeNotifierProvider<Project>.value(value: project),
    ];
  });

  group('TunerTool', () {
    group('Instrument page', () {
      testWidgets('default instrument is selected', (tester) async {
        await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), providers);
        await tester.createTunerToolInProject();

        await tester.tapAndSettle(find.bySemanticsLabel('Tuner 1'));
        await tester.pumpAndSettle(const Duration(milliseconds: 1100));
        await tester.ensureVisible(find.bySemanticsLabel('Instrument'));
        await tester.tapAndSettle(find.bySemanticsLabel('Instrument'));

        tester.expectTunerSelected(TunerType.chromatic);
      });
    });
  });
}
