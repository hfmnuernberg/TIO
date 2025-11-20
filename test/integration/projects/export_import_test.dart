import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/pages/projects_page/projects_page.dart';

import '../../utils/action_utils.dart';
import '../../utils/render_utils.dart';
import '../../utils/project_utils.dart';
import '../../utils/test_context.dart';

extension WidgetTesterPumpExtension on WidgetTester {
  Future<void> minimizeTipOfTheDay() async =>
      dragFromCenterToTargetAndSettle(find.bySemanticsLabel('Projects').first, const Offset(0, -1000));
}

void main() {
  late TestContext context;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    context = TestContext();
    await context.init();
  });

  testWidgets('exports and imports project with text', (tester) async {
    final exportedArchivePath = '${context.inMemoryFileSystem.tmpFolderPath}/export/project.zip';
    context.filePickerMock.mockShareFileAndCapture(exportedArchivePath);
    context.filePickerMock.mockPickArchive(exportedArchivePath);
    await tester.renderScaffold(ProjectsPage(), context.providers);

    await tester.createProject('Project 1');
    await tester.minimizeTipOfTheDay();
    await tester.tapAndSettle(find.byTooltip('Project details'));

    await tester.tapAndSettle(find.byTooltip('Project menu'));
    await tester.tapAndSettle(find.bySemanticsLabel('Export project'));

    await tester.tapAndSettle(find.bySemanticsLabel('Back'));

    expect(find.bySemanticsLabel('Project 1'), findsOneWidget);

    await tester.tapAndSettle(find.byTooltip('Edit projects'));
    await tester.tapAndSettle(find.byTooltip('Delete project'));
    await tester.tapAndSettle(find.bySemanticsLabel('Yes'));

    expect(find.bySemanticsLabel('Project 1'), findsNothing);

    await tester.tapAndSettle(find.byTooltip('Projects menu'));
    await tester.tapAndSettle(find.bySemanticsLabel('Import project'));

    expect(find.bySemanticsLabel('Project 1'), findsOneWidget);

    await tester.tapAndSettle(find.byTooltip('Projects menu'));
    await tester.tapAndSettle(find.bySemanticsLabel('Finish editing'));
    await tester.tapAndSettle(find.byTooltip('Project details'));
  });
}
