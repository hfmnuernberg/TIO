import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/pages/projects_page/projects_page.dart';

import '../../utils/action_utils.dart';
import '../../utils/render_utils.dart';
import '../../utils/test_context.dart';

extension WidgetTesterPumpExtension on WidgetTester {
  Future<void> createProjectWithoutTool(String title) async {
    await tapAndSettle(find.byTooltip('New project'));
    await enterTextAndSettle(find.bySemanticsLabel('New project'), title);
    await tapAndSettle(find.bySemanticsLabel('Submit'));
  }

  Future<void> createAndOpenTool(String tool) async {
    await tapAndSettle(find.bySemanticsLabel(tool));
    await enterTextAndSettle(find.bySemanticsLabel('Tool title'), '$tool 1');
    await tapAndSettle(find.bySemanticsLabel('Submit'));
  }

  Future<void> completeInitialTutorial() async {
    await tapAndSettle(find.bySemanticsLabel('Next'));
    await tapAndSettle(find.bySemanticsLabel('Next'));
    await tapAndSettle(find.bySemanticsLabel('Next'));
    await tapAndSettle(find.bySemanticsLabel('Next'));
    await tapAndSettle(find.bySemanticsLabel('Next'));
  }
}

void main() {
  late TestContext context;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    context = TestContext();
    await context.init();
  });

  testWidgets('shows projects tutorial initially', (tester) async {
    await tester.renderScaffold(ProjectsPage(), context.providers);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    expect(find.bySemanticsLabel(RegExp('Welcome! You can use')), findsOneWidget);

    await tester.tapAndSettle(find.bySemanticsLabel('Next'));
    expect(find.bySemanticsLabel('Tap here to create a new project.'), findsOneWidget);

    await tester.tapAndSettle(find.bySemanticsLabel('Cancel'));
    expect(find.bySemanticsLabel('Tap here to create a new project.'), findsNothing);
  });

  testWidgets('shows project tutorial initially', (tester) async {
    await tester.renderScaffold(ProjectsPage(), context.providers);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    await tester.completeInitialTutorial();
    await tester.createProjectWithoutTool('Project 1');

    await tester.createAndOpenTool('Text');
    await tester.tapAndSettle(find.bySemanticsLabel('Next'));
    await tester.tapAndSettle(find.bySemanticsLabel('Back'));

    expect(find.bySemanticsLabel('Tap here to edit the title of your project.'), findsOneWidget);

    await tester.tapAndSettle(find.bySemanticsLabel('Next'));
    expect(find.bySemanticsLabel(RegExp('Tap the plus icon to add')), findsOneWidget);

    await tester.tapAndSettle(find.bySemanticsLabel('Cancel'));
    expect(find.bySemanticsLabel(RegExp('Tap the plus icon to add')), findsNothing);
  });

  testWidgets('shows text tool tutorial initially', (tester) async {
    await tester.renderScaffold(ProjectsPage(), context.providers);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    await tester.completeInitialTutorial();
    await tester.createProjectWithoutTool('Project 1');

    await tester.createAndOpenTool('Text');

    expect(find.bySemanticsLabel('Tap here to copy your tool to another project.'), findsOneWidget);

    await tester.tapAndSettle(find.bySemanticsLabel('Cancel'));
    expect(find.bySemanticsLabel('Tap here to copy your tool to another project.'), findsNothing);
  });

  testWidgets('shows image tool tutorial initially', (tester) async {
    await tester.renderScaffold(ProjectsPage(), context.providers);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    await tester.completeInitialTutorial();
    await tester.createProjectWithoutTool('Project 1');

    await tester.createAndOpenTool('Image');

    expect(find.bySemanticsLabel('Tap here to copy your tool to another project.'), findsOneWidget);

    await tester.tapAndSettle(find.bySemanticsLabel('Next'));
    expect(find.bySemanticsLabel('Tap here to copy your tool to another project.'), findsNothing);
  });

  testWidgets('shows media player tool tutorial initially', (tester) async {
    await tester.renderScaffold(ProjectsPage(), context.providers);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    await tester.completeInitialTutorial();
    await tester.createProjectWithoutTool('Project 1');

    await tester.createAndOpenTool('Media Player');

    expect(find.bySemanticsLabel('Tap here to copy your tool to another project.'), findsOneWidget);

    await tester.tapAndSettle(find.bySemanticsLabel('Next'));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(find.bySemanticsLabel(RegExp('Tap here to start and stop recording')), findsOneWidget);

    await tester.tapAndSettle(find.bySemanticsLabel('Cancel'));
    expect(find.bySemanticsLabel(RegExp('Tap here to start and stop recording')), findsNothing);
  });
}
