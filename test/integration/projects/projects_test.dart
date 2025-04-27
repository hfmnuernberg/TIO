import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/projects_list/projects_list.dart';
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
import 'project_utils.dart';

void main() {
  late List<SingleChildWidget> providers;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    final fileSystem = FileSystemLogDecorator(InMemoryFileSystemMock());
    final mediaRepo = MediaRepositoryLogDecorator(FileBasedMediaRepository(fileSystem));
    final projectRepo = ProjectRepositoryLogDecorator(FileBasedProjectRepository(fileSystem));
    final fileReferences = FileReferencesLogDecorator(FileReferencesImpl(mediaRepo));

    await fileSystem.init();
    await mediaRepo.init();
    final projectLibrary =
        projectRepo.existsLibrary() ? await projectRepo.loadLibrary() : ProjectLibrary.withDefaults()
          ..dismissAllTutorials();
    await projectRepo.saveLibrary(projectLibrary);
    await fileReferences.init(projectLibrary);

    providers = [
      Provider<FileSystem>(create: (_) => fileSystem),
      Provider<MediaRepository>(create: (_) => mediaRepo),
      Provider<ProjectRepository>(create: (_) => projectRepo),
      Provider<FileReferences>(create: (_) => fileReferences),
      ChangeNotifierProvider<ProjectLibrary>.value(value: projectLibrary),
    ];
  });

  testWidgets('shows no projects initially', (tester) async {
    await tester.renderScaffold(ProjectsList(), providers);

    expect(find.bySemanticsLabel('Please click on "+" to create a new project.'), findsOneWidget);
  });

  testWidgets('shows one project when one project was added', (tester) async {
    await tester.renderScaffold(ProjectsList(), providers);

    await tester.createProject('Project 1');

    expect(find.bySemanticsLabel('Project 1'), findsOneWidget);
    expect(find.bySemanticsLabel('Please click on "+" to create a new project.'), findsNothing);
  });

  testWidgets('deletes project when project was deleted', (tester) async {
    await tester.renderScaffold(ProjectsList(), providers);

    await tester.createProject('Project 1');
    await tester.tapAndSettle(find.byTooltip('Delete project'));
    await tester.tapAndSettle(find.bySemanticsLabel('Yes'));

    expect(find.bySemanticsLabel('Project 1'), findsNothing);
    expect(find.bySemanticsLabel('Please click on "+" to create a new project.'), findsOneWidget);
  });
}
