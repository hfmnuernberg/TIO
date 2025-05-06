import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/projects_page/projects_page.dart';
import 'package:tiomusic/services/archiver.dart';
import 'package:tiomusic/services/decorators/archiver_log_decorator.dart';
import 'package:tiomusic/services/decorators/file_picker_log_decorator.dart';
import 'package:tiomusic/services/decorators/file_references_log_decorator.dart';
import 'package:tiomusic/services/decorators/file_system_log_decorator.dart';
import 'package:tiomusic/services/decorators/media_repository_log_decorator.dart';
import 'package:tiomusic/services/decorators/project_repository_log_decorator.dart';
import 'package:tiomusic/services/file_picker.dart';
import 'package:tiomusic/services/file_references.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/impl/file_based_archiver.dart';
import 'package:tiomusic/services/impl/file_based_media_repository.dart';
import 'package:tiomusic/services/impl/file_based_project_repository.dart';
import 'package:tiomusic/services/impl/file_references_impl.dart';
import 'package:tiomusic/services/media_repository.dart';
import 'package:tiomusic/services/project_repository.dart';

import '../../mocks/file_picker_mock.dart';
import '../../mocks/in_memory_file_system_mock.dart';
import '../../utils/action_utils.dart';
import '../../utils/render_utils.dart';
import 'project_utils.dart';

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
    final archiver = ArchiverLogDecorator(FileBasedArchiver(fileSystem, mediaRepo));

    await fileSystem.init();
    await mediaRepo.init();
    final projectLibrary =
        projectRepo.existsLibrary() ? await projectRepo.loadLibrary() : ProjectLibrary.withDefaults()
          ..dismissAllTutorials();
    await projectRepo.saveLibrary(projectLibrary);
    await fileReferences.init(projectLibrary);

    providers = [
      Provider<FilePicker>(create: (_) => filePicker),
      Provider<FileSystem>(create: (_) => fileSystem),
      Provider<MediaRepository>(create: (_) => mediaRepo),
      Provider<ProjectRepository>(create: (_) => projectRepo),
      Provider<FileReferences>(create: (_) => fileReferences),
      Provider<Archiver>(create: (_) => archiver),
      ChangeNotifierProvider<ProjectLibrary>.value(value: projectLibrary),
    ];
  });

  testWidgets('exports and imports project with text', (tester) async {
    final exportedArchivePath = '${fileSystem.tmpFolderPath}/export/project.zip';
    filePickerMock.mockShareFileAndCapture(exportedArchivePath);
    filePickerMock.mockPickArchive(exportedArchivePath);
    await tester.renderScaffold(ProjectsPage(), providers);

    await tester.createProject('Project 1');
    await tester.tapAndSettle(find.byTooltip('Project details'));

    await tester.tapAndSettle(find.byTooltip('Project menu'));
    await tester.tapAndSettle(find.bySemanticsLabel('Export project'));

    await tester.tapAndSettle(find.bySemanticsLabel('Back'));

    expect(find.bySemanticsLabel('Project 1'), findsOneWidget);

    await tester.tapAndSettle(find.byTooltip('Delete project'));
    await tester.tapAndSettle(find.bySemanticsLabel('Yes'));

    expect(find.bySemanticsLabel('Project 1'), findsNothing);

    await tester.tapAndSettle(find.byTooltip('Projects menu'));
    await tester.tapAndSettle(find.bySemanticsLabel('Import project'));

    expect(find.bySemanticsLabel('Project 1'), findsOneWidget);

    await tester.tapAndSettle(find.byTooltip('Project details'));
  });
}
