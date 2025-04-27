import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/projects_list/projects_list.dart';
import 'package:tiomusic/services/decorators/file_references_log_decorator.dart';
import 'package:tiomusic/services/decorators/media_repository_log_decorator.dart';
import 'package:tiomusic/services/decorators/project_library_repository_log_decorator.dart';
import 'package:tiomusic/services/file_references.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/impl/file_based_media_repository.dart';
import 'package:tiomusic/services/impl/file_based_project_library_repository.dart';
import 'package:tiomusic/services/impl/file_references_impl.dart';
import 'package:tiomusic/services/impl/file_system_impl.dart';
import 'package:tiomusic/services/decorators/file_system_log_decorator.dart';
import 'package:tiomusic/services/media_repository.dart';
import 'package:tiomusic/services/project_library_repository.dart';

import '../../mocks/file_picker_mock.dart';
import '../../mocks/image_picker_mock.dart';
import '../../mocks/in_memory_file_system_mock.dart';
import '../../mocks/path_provider_mock.dart';
import '../../mocks/share_plus_mock.dart';
import '../../utils/action_utils.dart';
import '../../utils/render_utils.dart';
import 'project_utils.dart';

void main() {
  late List<SingleChildWidget> providers;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    final fileSystem = FileSystemLogDecorator(InMemoryFileSystemMock());
    final mediaRepo = MediaRepositoryLogDecorator(FileBasedMediaRepository(fileSystem));
    final projectLibraryRepo = ProjectLibraryRepositoryLogDecorator(FileBasedProjectLibraryRepository(fileSystem));
    final fileReferences = FileReferencesLogDecorator(FileReferencesImpl(mediaRepo));

    await fileSystem.init();
    await mediaRepo.init();
    final projectLibrary =
    projectLibraryRepo.exists() ? await projectLibraryRepo.load() : ProjectLibrary.withDefaults()
      ..dismissAllTutorials();
    await projectLibraryRepo.save(projectLibrary);
    await fileReferences.init(projectLibrary);

    providers = [
      Provider<FileSystem>(create: (_) => fileSystem),
      Provider<MediaRepository>(create: (_) => mediaRepo),
      Provider<ProjectLibraryRepository>(create: (_) => projectLibraryRepo),
      Provider<FileReferences>(create: (_) => fileReferences),
      ChangeNotifierProvider<ProjectLibrary>.value(value: projectLibrary),
    ];
  });

  testWidgets('exports and imports project with text', (tester) async {
    await tester.renderScaffold(ProjectsList(), providers);

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
  });
}
