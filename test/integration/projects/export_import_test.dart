import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/projects_list/projects_list.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/impl/file_system_impl.dart';

import '../../mocks/file_picker_mock.dart';
import '../../mocks/image_picker_mock.dart';
import '../../mocks/path_provider_mock.dart';
import '../../mocks/share_plus_mock.dart';
import '../../utils/action_utils.dart';
import '../../utils/render_utils.dart';
import 'project_utils.dart';

void main() {
  late SharePlusMock sharePlusMock;
  late ImagePickerMock imagePickerMock;
  late FilePickerMock filePickerMock;
  late PathProviderMock pathProviderMock;
  late List<SingleChildWidget> providers;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() {
    sharePlusMock = SharePlusMock()..mockShareXFile(ShareResult('TODO', ShareResultStatus.success));
    filePickerMock = FilePickerMock();
    imagePickerMock = ImagePickerMock();
    pathProviderMock =
        PathProviderMock()
          ..mockGetTemporaryDirectory(Directory.systemTemp)
          ..mockGetApplicationDocumentsDirectory(Directory.systemTemp);

    providers = [
      ChangeNotifierProvider<ProjectLibrary>.value(value: ProjectLibrary.withDefaults()..dismissAllTutorials()),
      Provider<FileSystem>(
        create: (_) => FileSystemImpl(pathProviderMock, filePickerMock, imagePickerMock, sharePlusMock),
      ),
    ];
  });

  testWidgets('exports and imports project with text', (tester) async {
    await tester.runAsync(() async {
      await tester.renderScaffold(ProjectsList(), providers);

      await tester.createProject('Project 1');
      await tester.tapAndSettle(find.byTooltip('Project details'));

      await tester.tapAndSettle(find.byTooltip('Project menu'));
      await tester.tapAndSettle(find.bySemanticsLabel('Export Project'));
      await tester.tapAndSettle(find.bySemanticsLabel('Export'));

      await tester.tapAndSettle(find.bySemanticsLabel('Back'));

      await tester.tapAndSettle(find.byTooltip('Project list menu'));
      await tester.tapAndSettle(find.bySemanticsLabel('Import Project'));

      debugDumpSemanticsTree();

      expect(find.bySemanticsLabel('Project 1'), findsOneWidget);
    });
  });
}
