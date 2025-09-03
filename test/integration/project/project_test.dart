import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/pages/project_page/project_page.dart';

import '../../utils/action_utils.dart';
import '../../utils/project_utils.dart';
import '../../utils/render_utils.dart';
import '../../utils/test_context.dart';

extension WidgetTesterPumpExtension on WidgetTester {
  Finder withinEmptyList(FinderBase<Element> matching) =>
      find.descendant(of: find.bySemanticsLabel('Empty tool list'), matching: matching);

  Finder withinList(FinderBase<Element> matching) =>
      find.descendant(of: find.bySemanticsLabel('Tool list'), matching: matching);
}

void main() {
  late TestContext context;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    context = TestContext();
    await context.init(project: Project.defaultThumbnail('Test Project'));
  });

  testWidgets('shows empty tool list with tool suggestions initially', (tester) async {
    await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);

    expect(tester.withinEmptyList(find.bySemanticsLabel('Tuner')), findsOneWidget);
    expect(tester.withinEmptyList(find.bySemanticsLabel('Piano')), findsOneWidget);
    expect(tester.withinEmptyList(find.bySemanticsLabel('Metronome')), findsOneWidget);
  });

  testWidgets('shows text tool when one text tool was added', (tester) async {
    await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
    expect(find.bySemanticsLabel('Tool list'), findsNothing);

    await tester.createTextToolInProject('Text 1');
    expect(tester.withinList(find.bySemanticsLabel('Text 1')), findsOneWidget);
  });

  testWidgets('shows piano tool when piano tool was added', (tester) async {
    await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
    expect(find.bySemanticsLabel('Tool list'), findsNothing);

    await tester.createPianoToolInProject();
    expect(tester.withinList(find.bySemanticsLabel('Piano 1')), findsOneWidget);
  });

  testWidgets('deletes tool when tool was deleted', (tester) async {
    await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);

    await tester.createTextToolInProject('Text 1');
    expect(tester.withinList(find.bySemanticsLabel('Text 1')), findsOneWidget);

    await tester.tapAndSettle(find.byTooltip('Project menu'));
    await tester.tapAndSettle(find.bySemanticsLabel('Edit tools'));
    await tester.tapAndSettle(find.byTooltip('Delete tool'));
    await tester.tapAndSettle(find.bySemanticsLabel('Yes'));

    expect(tester.withinList(find.bySemanticsLabel('Text 1')), findsNothing);
  });

  group('next tool navigation', () {
    testWidgets('navigate to next tool when multiple tools were added', (tester) async {
      await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);

      await tester.createImageToolInProject();
      await tester.tapAndSettle(find.byTooltip('Add new tool'));
      await tester.createTextToolInProject('Text 1');

      await tester.tapAndSettle(find.bySemanticsLabel('Text 1'));
      await tester.tapAndSettle(find.byTooltip('Go to next tool'));

      expect(find.bySemanticsLabel('Please select an image or take a photo.'), findsOneWidget);
      expect(find.bySemanticsLabel('Text field'), findsNothing);
    });

    testWidgets('does not have other buttons', (tester) async {
      await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);

      await tester.createImageToolInProject();
      await tester.tapAndSettle(find.byTooltip('Add new tool'));
      await tester.createTextToolInProject('Text 1');

      await tester.tapAndSettle(find.bySemanticsLabel('Text 1'));

      expect(find.byTooltip('Go to next tool'), findsOneWidget);
      expect(find.byTooltip('Go to next tool of the same type'), findsNothing);
      expect(find.byTooltip('Go to previous tool'), findsNothing);
      expect(find.byTooltip('Go to previous tool of the same type'), findsNothing);
    });
  });

  group('previous tool navigation', () {
    testWidgets('navigate to previous tool when multiple tools were added', (tester) async {
      await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);

      await tester.createTextToolInProject('Text 1');
      await tester.tapAndSettle(find.byTooltip('Add new tool'));
      await tester.createImageToolInProject();

      await tester.tapAndSettle(find.bySemanticsLabel('Text 1'));
      await tester.tapAndSettle(find.byTooltip('Go to previous tool'));

      expect(find.bySemanticsLabel('Please select an image or take a photo.'), findsOneWidget);
      expect(find.bySemanticsLabel('Text field'), findsNothing);
    });

    testWidgets('does not have other buttons', (tester) async {
      await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);

      await tester.createTextToolInProject('Text 1');
      await tester.tapAndSettle(find.byTooltip('Add new tool'));
      await tester.createImageToolInProject();

      await tester.tapAndSettle(find.bySemanticsLabel('Text 1'));

      expect(find.byTooltip('Go to previous tool'), findsOneWidget);
      expect(find.byTooltip('Go to next tool'), findsNothing);
      expect(find.byTooltip('Go to next tool of the same type'), findsNothing);
      expect(find.byTooltip('Go to previous tool of the same type'), findsNothing);
    });
  });

  group('next tool of same type navigation', () {
    testWidgets('navigate to next tool of same type when multiple tools of same type were added', (tester) async {
      await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);

      await tester.createTextToolInProject('Text 1');
      await tester.tapAndSettle(find.byTooltip('Add new tool'));
      await tester.createImageToolInProject();
      await tester.tapAndSettle(find.byTooltip('Add new tool'));
      await tester.createTextToolInProject('Text 2');
      await tester.tapAndSettle(find.bySemanticsLabel('Text 2'));
      expect(tester.getSemantics(find.bySemanticsLabel('Text field')).value, 'Text 2 text content');

      await tester.tapAndSettle(find.byTooltip('Go to next tool of the same type'));

      expect(find.bySemanticsLabel('Please select an image or take a photo.'), findsNothing);
      expect(tester.getSemantics(find.bySemanticsLabel('Text field')).value, 'Text 1 text content');
    });

    testWidgets('does not have previous buttons', (tester) async {
      await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);

      await tester.createTextToolInProject('Text 1');
      await tester.tapAndSettle(find.byTooltip('Add new tool'));
      await tester.createImageToolInProject();
      await tester.tapAndSettle(find.byTooltip('Add new tool'));
      await tester.createTextToolInProject('Text 2');

      await tester.tapAndSettle(find.bySemanticsLabel('Text 2'));

      expect(find.byTooltip('Go to next tool'), findsOneWidget);
      expect(find.byTooltip('Go to next tool of the same type'), findsOneWidget);
      expect(find.byTooltip('Go to previous tool'), findsNothing);
      expect(find.byTooltip('Go to previous tool of the same type'), findsNothing);
    });
  });

  group('previous tool of same type navigation', () {
    testWidgets('navigate to previous tool of same type when multiple tools of same type were added', (tester) async {
      await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);

      await tester.createTextToolInProject('Text 1');
      await tester.tapAndSettle(find.byTooltip('Add new tool'));
      await tester.createImageToolInProject();
      await tester.tapAndSettle(find.byTooltip('Add new tool'));
      await tester.createTextToolInProject('Text 2');
      await tester.tapAndSettle(find.bySemanticsLabel('Text 1'));
      expect(tester.getSemantics(find.bySemanticsLabel('Text field')).value, 'Text 1 text content');

      await tester.tapAndSettle(find.byTooltip('Go to previous tool of the same type'));

      expect(find.bySemanticsLabel('Please select an image or take a photo.'), findsNothing);
      expect(tester.getSemantics(find.bySemanticsLabel('Text field')).value, 'Text 2 text content');
    });

    testWidgets('does not have next buttons', (tester) async {
      await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);

      await tester.createTextToolInProject('Text 1');
      await tester.tapAndSettle(find.byTooltip('Add new tool'));
      await tester.createImageToolInProject();
      await tester.tapAndSettle(find.byTooltip('Add new tool'));
      await tester.createTextToolInProject('Text 2');

      await tester.tapAndSettle(find.bySemanticsLabel('Text 1'));

      expect(find.byTooltip('Go to previous tool'), findsOneWidget);
      expect(find.byTooltip('Go to previous tool of the same type'), findsOneWidget);
      expect(find.byTooltip('Go to next tool'), findsNothing);
      expect(find.byTooltip('Go to next tool of the same type'), findsNothing);
    });
  });
}
