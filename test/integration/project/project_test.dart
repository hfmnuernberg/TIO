import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/project_page/project_page.dart';
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
import '../../mocks/in_memory_file_system_mock.dart';
import '../../utils/action_utils.dart';
import '../../utils/project_utils.dart';
import '../../utils/render_utils.dart';

extension WidgetTesterPumpExtension on WidgetTester {
  Finder withinEmptyList(FinderBase<Element> matching) =>
      find.descendant(of: find.bySemanticsLabel('Empty tool list'), matching: matching);

  Finder withinList(FinderBase<Element> matching) =>
      find.descendant(of: find.bySemanticsLabel('Tool list'), matching: matching);
}

void main() {
  late FileSystem fileSystem;
  late FilePickerMock filePickerMock;
  late List<SingleChildWidget> providers;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    fileSystem = FileSystemLogDecorator(InMemoryFileSystemMock());
    filePickerMock = FilePickerMock(fileSystem);
    final filePicker = FilePickerLogDecorator(filePickerMock);
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
    final project = Project.defaultThumbnail('Test Project');

    providers = [
      Provider<FilePicker>(create: (_) => filePicker),
      Provider<FileSystem>(create: (_) => fileSystem),
      Provider<MediaRepository>(create: (_) => mediaRepo),
      Provider<ProjectRepository>(create: (_) => projectRepo),
      Provider<FileReferences>(create: (_) => fileReferences),
      ChangeNotifierProvider<ProjectLibrary>.value(value: projectLibrary),
      ChangeNotifierProvider<Project>.value(value: project),
    ];
  });

  testWidgets('shows empty tool list with tool suggestions initially', (tester) async {
    await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), providers);

    expect(tester.withinEmptyList(find.bySemanticsLabel('Tuner')), findsOneWidget);
    expect(tester.withinEmptyList(find.bySemanticsLabel('Piano')), findsOneWidget);
    expect(tester.withinEmptyList(find.bySemanticsLabel('Metronome')), findsOneWidget);
  });

  testWidgets('shows one tool when one tool was added', (tester) async {
    await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), providers);
    expect(find.bySemanticsLabel('Tool list'), findsNothing);

    await tester.tapAndSettle(find.bySemanticsLabel('Text'));
    await tester.enterTextAndSettle(find.bySemanticsLabel('Tool title'), 'Text 1');
    await tester.tapAndSettle(find.bySemanticsLabel('Submit'));
    await tester.enterTextAndSettle(find.bySemanticsLabel('Text field'), 'Test text');
    await tester.tapAndSettle(find.bySemanticsLabel('Back'));

    expect(tester.withinList(find.bySemanticsLabel('Text 1')), findsOneWidget);
  });

  testWidgets('deletes tool when tool was deleted', (tester) async {
    await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), providers);

    await tester.tapAndSettle(find.bySemanticsLabel('Text'));
    await tester.enterTextAndSettle(find.bySemanticsLabel('Tool title'), 'Text 1');
    await tester.tapAndSettle(find.bySemanticsLabel('Submit'));
    await tester.enterTextAndSettle(find.bySemanticsLabel('Text field'), 'Test text');
    await tester.tapAndSettle(find.bySemanticsLabel('Back'));

    expect(tester.withinList(find.bySemanticsLabel('Text 1')), findsOneWidget);

    await tester.tapAndSettle(find.byTooltip('Project menu'));
    await tester.tapAndSettle(find.bySemanticsLabel('Edit tools'));
    await tester.tapAndSettle(find.byTooltip('Delete tool'));
    await tester.tapAndSettle(find.bySemanticsLabel('Yes'));

    expect(tester.withinList(find.bySemanticsLabel('Text 1')), findsNothing);
  });

  testWidgets('navigate between tools when multiple tools was added', (tester) async {
    await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), providers);

    await tester.createTextToolInProject('Test text');
    await tester.tapAndSettle(find.bySemanticsLabel('Back'));

    await tester.tapAndSettle(find.byTooltip('Add new tool'));
    await tester.createImageToolInProject();
    await tester.tapAndSettle(find.bySemanticsLabel('Back'));

    await tester.tapAndSettle(find.bySemanticsLabel('Text 1'));
    expect(find.bySemanticsLabel('Text field'), findsOneWidget);

    await tester.tapAndSettle(find.byTooltip('Go to previous tool'));
    expect(find.bySemanticsLabel('Please select an image or take a photo.'), findsOneWidget);
    expect(find.bySemanticsLabel('Text 1'), findsNothing);
  });
}
