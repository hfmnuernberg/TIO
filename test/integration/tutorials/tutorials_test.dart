import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/pages/projects_page/projects_page.dart';

import '../../utils/action_utils.dart';
import '../../utils/render_utils.dart';
import '../../utils/test_context.dart';
import 'tutorials_utils.dart';

void main() {
  late TestContext context;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    context = TestContext();
    await context.init(dismissTutorials: false);
  });

  tearDown(() {
    WidgetsBinding.instance.resetEpoch();
  });

  testWidgets('shows projects tutorial initially', (tester) async {
    await tester.renderScaffold(ProjectsPage(), context.providers);

    await tester.waitForTutorialNext();
    expect(find.bySemanticsLabel(RegExp('Welcome! You can use')), findsOneWidget);

    await tester.tapAndSettle(find.bySemanticsLabel('Next'));
    expect(find.bySemanticsLabel('Tap here to start using a tool.'), findsOneWidget);

    await tester.tapAndSettle(find.bySemanticsLabel('Cancel'));
    expect(find.bySemanticsLabel('Tap here to start using a tool.'), findsNothing);
  });

  testWidgets('shows project tutorial initially', (tester) async {
    await tester.renderScaffold(ProjectsPage(), context.providers);
    await tester.completeInitialTutorial();
    await tester.createProjectWithoutTool('Project 1');

    await tester.createAndOpenTool('Text');
    await tester.completeTextTutorial();
    await tester.tapAndSettle(find.bySemanticsLabel('Back'));

    await tester.waitForTutorialNext();
    expect(find.bySemanticsLabel('Tap here to edit the title of your project.'), findsOneWidget);

    await tester.tapAndSettle(find.bySemanticsLabel('Next'));
    expect(find.bySemanticsLabel(RegExp('Tap the plus icon to add')), findsOneWidget);

    await tester.tapAndSettle(find.bySemanticsLabel('Cancel'));
    expect(find.bySemanticsLabel(RegExp('Tap the plus icon to add')), findsNothing);
  });

  testWidgets('shows text tool tutorial initially', (tester) async {
    await tester.renderScaffold(ProjectsPage(), context.providers);
    await tester.completeInitialTutorial();
    await tester.createProjectWithoutTool('Project 1');

    await tester.createAndOpenTool('Text');

    await tester.waitForTutorialNext();
    expect(find.bySemanticsLabel('Tap here to copy your tool to another project.'), findsOneWidget);

    await tester.tapAndSettle(find.bySemanticsLabel('Cancel'));
    expect(find.bySemanticsLabel('Tap here to copy your tool to another project.'), findsNothing);
  });

  testWidgets('shows image tool tutorial initially', (tester) async {
    await tester.renderScaffold(ProjectsPage(), context.providers);
    await tester.completeInitialTutorial();
    await tester.createProjectWithoutTool('Project 1');

    await tester.createAndOpenTool('Image');

    await tester.waitForTutorialNext();
    expect(find.bySemanticsLabel('Tap here to copy your tool to another project.'), findsOneWidget);

    await tester.tapAndSettle(find.bySemanticsLabel('Next'));
    expect(find.bySemanticsLabel('Tap here to copy your tool to another project.'), findsNothing);
  });

  testWidgets('shows media player tool tutorial initially', (tester) async {
    await tester.renderScaffold(ProjectsPage(), context.providers);
    await tester.completeInitialTutorial();
    await tester.createProjectWithoutTool('Project 1');

    await tester.createAndOpenTool('Media Player');

    await tester.waitForTutorialNext();
    expect(find.bySemanticsLabel('Tap here to copy your tool to another project.'), findsOneWidget);

    await tester.completeParentToolTutorial();
    await tester.waitForTutorialNext();
    expect(find.bySemanticsLabel(RegExp('Tap here to start and stop recording')), findsOneWidget);

    await tester.tapAndSettle(find.bySemanticsLabel('Cancel'));
    expect(find.bySemanticsLabel(RegExp('Tap here to start and stop recording')), findsNothing);
  });

  testWidgets('shows quick tool tutorial before tool tutorial', (tester) async {
    await tester.renderScaffold(ProjectsPage(), context.providers);
    await tester.completeInitialTutorial();
    await tester.createAndOpenQuickTool('Tuner');

    await tester.waitForTutorialNext();
    expect(find.bySemanticsLabel(RegExp('Tap here to save the tool to a project.')), findsOneWidget);
    await tester.tapAndSettle(find.bySemanticsLabel('Next'));
    expect(find.bySemanticsLabel('Tap here to edit the title of your tool.'), findsOneWidget);

    await tester.tapAndSettle(find.bySemanticsLabel('Next'));
    await tester.waitForTutorialNext();
    expect(find.bySemanticsLabel(RegExp('Tap here to start and stop the tuner.')), findsOneWidget);
  });

  testWidgets('shows flash cards tutorial initially', (tester) async {
    await tester.renderScaffold(ProjectsPage(), context.providers);
    await tester.completeInitialTutorial();

    await tester.tapAndSettle(find.bySemanticsLabel('View more'));
    await tester.waitForTutorialNext();
    expect(find.bySemanticsLabel(RegExp('Use the filter buttons to filter flash cards')), findsOneWidget);

    await tester.tapAndSettle(find.bySemanticsLabel('Cancel'));
    expect(find.bySemanticsLabel(RegExp('Use the filter buttons to filter flash cards')), findsNothing);
  });

  testWidgets('shows specific tutorial steps after quick tool is saved in project', (tester) async {
    await tester.renderScaffold(ProjectsPage(), context.providers);
    await tester.completeInitialTutorial();

    await tester.createAndOpenQuickTool('Tuner');
    await tester.completeParentToolTutorial();
    await tester.completeTunerTutorial();

    await tester.goBackAndSaveQuickToolInNewProject();

    await tester.waitForTutorialNext();
    expect(find.bySemanticsLabel('Tap here to copy your tool to another project.'), findsOneWidget);

    await tester.tapAndSettle(find.bySemanticsLabel('Next'));
    await tester.waitForTutorialNext();
    expect(find.bySemanticsLabel(RegExp('Tap here to combine your Tuner with a')), findsOneWidget);
  });

  testWidgets('resets projects tutorial when reset tutorial using projects menu', (tester) async {
    await tester.renderScaffold(ProjectsPage(), context.providers);

    await tester.waitForTutorialNext();
    expect(find.bySemanticsLabel(RegExp('Welcome! You can use')), findsOneWidget);

    await tester.tapAndSettle(find.bySemanticsLabel('Cancel'));
    expect(find.bySemanticsLabel(RegExp('Welcome! You can use')), findsNothing);

    await tester.tapAndSettle(find.byTooltip('Projects menu'));
    await tester.tapAndSettle(find.bySemanticsLabel('Show tutorial'));

    await tester.waitForTutorialNext();
    expect(find.bySemanticsLabel(RegExp('Welcome! You can use')), findsOneWidget);
  });

  testWidgets('resets other tutorials when reset tutorial using projects menu', (tester) async {
    await tester.renderScaffold(ProjectsPage(), context.providers);
    await tester.completeInitialTutorial();
    await tester.createProjectWithoutTool('Project 1');

    await tester.createAndOpenTool('Text');
    await tester.waitForTutorialNext();
    expect(find.bySemanticsLabel(RegExp('Tap here to copy your tool')), findsOneWidget);

    await tester.tapAndSettle(find.bySemanticsLabel('Cancel'));
    expect(find.bySemanticsLabel(RegExp('Tap here to copy your tool')), findsNothing);

    await tester.tapAndSettle(find.bySemanticsLabel('Back'));
    await tester.tapAndSettle(find.bySemanticsLabel('Back'));
    await tester.tapAndSettle(find.byTooltip('Projects menu'));
    await tester.tapAndSettle(find.bySemanticsLabel('Show tutorial'));
    await tester.waitForTutorialNext();
    await tester.completeInitialTutorial();
    await tester.minimizeTipOfTheDay();
    await tester.tapAndSettle(find.bySemanticsLabel('Project 1'));
    await tester.completeProjectTutorial();
    await tester.tapAndSettle(find.bySemanticsLabel('Text 1'));

    await tester.waitForTutorialNext();
    expect(find.bySemanticsLabel(RegExp('Tap here to copy your tool')), findsOneWidget);
  });
}
