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
import 'package:tiomusic/widgets/card_list_tile.dart';

import '../../mocks/in_memory_file_system_mock.dart';
import '../../utils/action_utils.dart';
import '../../utils/render_utils.dart';
import '../../utils/project_utils.dart';

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
        projectRepo.existsLibrary() ? await projectRepo.loadLibrary() : ProjectLibrary.withDefaults()
          ..dismissAllTutorials();
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

  testWidgets('shows no projects initially', (tester) async {
    await tester.renderScaffold(ProjectsPage(), providers);

    expect(find.bySemanticsLabel('Please click on "+" to create a new project.'), findsOneWidget);
  });

  testWidgets('shows one project when one project was added', (tester) async {
    await tester.renderScaffold(ProjectsPage(), providers);

    await tester.createProject('Project 1');

    expect(find.bySemanticsLabel('Project 1'), findsOneWidget);
    expect(find.bySemanticsLabel('Please click on "+" to create a new project.'), findsNothing);
  });

  testWidgets('deletes project when project was deleted', (tester) async {
    await tester.renderScaffold(ProjectsPage(), providers);

    await tester.createProject('Project 1');
    await tester.tapAndSettle(find.byTooltip('Projects menu'));
    await tester.tapAndSettle(find.bySemanticsLabel('Edit projects'));
    await tester.tapAndSettle(find.byTooltip('Delete project'));
    await tester.tapAndSettle(find.bySemanticsLabel('Yes'));

    expect(find.bySemanticsLabel('Project 1'), findsNothing);
    expect(find.bySemanticsLabel('Please click on "+" to create a new project.'), findsOneWidget);
  });

  testWidgets('changes order when project is moved during editing', (tester) async {
    await tester.renderScaffold(ProjectsPage(), providers);
    await tester.createProject('Project 1');
    await tester.createProject('Project 2');

    final projects = tester.widgetList<CardListTile>(find.byType(CardListTile)).toList();
    final projectTitles = projects.map((tile) => tile.title).toList();
    expect(projectTitles, equals(['Project 2', 'Project 1']));

    await tester.tapAndSettle(find.byTooltip('Projects menu'));
    await tester.tapAndSettle(find.bySemanticsLabel('Edit projects'));
    await tester.dragFromCenterToTargetAndSettle(find.byTooltip('Reorder').first, const Offset(0, 500));

    final updatedProjects = tester.widgetList<CardListTile>(find.byType(CardListTile)).toList();
    final updatedProjectTitles = updatedProjects.map((tile) => tile.title).toList();

    expect(updatedProjectTitles, equals(['Project 1', 'Project 2']));
  });

  testWidgets('does not change order when project is moved too less during editing', (tester) async {
    await tester.renderScaffold(ProjectsPage(), providers);
    await tester.createProject('Project 1');
    await tester.createProject('Project 2');

    await tester.tapAndSettle(find.byTooltip('Projects menu'));
    await tester.tapAndSettle(find.bySemanticsLabel('Edit projects'));
    await tester.dragFromCenterToTargetAndSettle(find.byTooltip('Reorder').first, const Offset(0, 10));

    final projects = tester.widgetList<CardListTile>(find.byType(CardListTile)).toList();
    final projectTitles = projects.map((tile) => tile.title).toList();

    expect(projectTitles, equals(['Project 2', 'Project 1']));
  });
}
