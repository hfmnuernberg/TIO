import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/projects_page/projects_page.dart';
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

import '../../mocks/in_memory_file_system_mock.dart';
import '../../utils/action_utils.dart';
import '../../utils/render_utils.dart';

void main() {
  late List<SingleChildWidget> providers;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    final inMemoryFileSystem = FileSystemLogDecorator(InMemoryFileSystemMock());
    final mediaRepo = MediaRepositoryLogDecorator(FileBasedMediaRepository(inMemoryFileSystem));
    final projectRepo = ProjectRepositoryLogDecorator(FileBasedProjectRepository(inMemoryFileSystem));
    final fileReferences = FileReferencesLogDecorator(FileReferencesImpl(mediaRepo));

    await inMemoryFileSystem.init();
    await mediaRepo.init();
    final projectLibrary =
        projectRepo.existsLibrary() ? await projectRepo.loadLibrary() : ProjectLibrary.withDefaults();
    await projectRepo.saveLibrary(projectLibrary);
    await fileReferences.init(projectLibrary);

    providers = [
      Provider<FileSystem>(create: (_) => inMemoryFileSystem),
      Provider<MediaRepository>(create: (_) => mediaRepo),
      Provider<ProjectRepository>(create: (_) => projectRepo),
      Provider<FileReferences>(create: (_) => fileReferences),
      ChangeNotifierProvider<ProjectLibrary>.value(value: projectLibrary),
    ];
  });

  testWidgets('shows projects tutorial initially', (tester) async {
    await tester.renderScaffold(ProjectsPage(), providers);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    expect(find.bySemanticsLabel(RegExp('Welcome! You can use')), findsOneWidget);

    await tester.tapAndSettle(find.bySemanticsLabel('Next'));
    expect(find.bySemanticsLabel('Tap here to create a new project.'), findsOneWidget);

    await tester.tapAndSettle(find.bySemanticsLabel('Cancel'));
    expect(find.bySemanticsLabel('Tap here to create a new project.'), findsNothing);
  });
}
