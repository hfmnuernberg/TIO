import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/pages/project_page/project_page.dart';

import '../../utils/action_utils.dart';
import '../../utils/project_utils.dart';
import '../../utils/render_utils.dart';
import '../../utils/test_context.dart';

final connectionDialog = find.byWidgetPredicate(
  (widget) => widget is Semantics && widget.properties.label == 'Connect another tool',
);

extension WidgetTesterMetronomeExtension on WidgetTester {
  Future<void> openConnectionDialog() async {
    await tapAndSettle(find.byTooltip('Connect another tool'));
  }

  Finder withinConnectionDialog(FinderBase<Element> matching) =>
      find.descendant(of: connectionDialog, matching: matching);
}

void main() {
  late TestContext context;

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await NoteHandler.createNoteBeatLengthMap();
  });

  setUp(() async {
    context = TestContext();
    await context.init(project: Project.defaultThumbnail('Test Project'));
  });

  group('MetronomeTool - connections to other tools', () {
    testWidgets('provides connection possibility', (tester) async {
      await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
      await tester.createMetronomeToolInProject();

      await tester.tapAndSettle(find.bySemanticsLabel('Metronome 1'));

      expect(find.byTooltip('Connect another tool'), findsOneWidget);
    });

    group('connection to existing tools', () {
      testWidgets('shows media-player tools', (tester) async {
        await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
        await tester.createMetronomeToolInProject();
        await tester.tapAndSettle(find.byTooltip('Add new tool'));
        await tester.createMediaPlayerToolInProject();

        await tester.tapAndSettle(find.bySemanticsLabel('Metronome 1'));
        await tester.openConnectionDialog();

        expect(tester.withinConnectionDialog(find.bySemanticsLabel('Media Player 1')), findsOneWidget);
      });

      testWidgets('shows tuner tools', (tester) async {
        await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
        await tester.createMetronomeToolInProject();
        await tester.tapAndSettle(find.byTooltip('Add new tool'));
        await tester.createTunerToolInProject();

        await tester.tapAndSettle(find.bySemanticsLabel('Metronome 1'));
        await tester.openConnectionDialog();

        expect(tester.withinConnectionDialog(find.bySemanticsLabel('Tuner 1')), findsOneWidget);
      });
    });

    group('connection to new/not-existing tools', () {
      testWidgets('shows media-player tools', (tester) async {
        await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
        await tester.createMetronomeToolInProject();

        await tester.tapAndSettle(find.bySemanticsLabel('Metronome 1'));
        await tester.openConnectionDialog();

        expect(tester.withinConnectionDialog(find.bySemanticsLabel('Media Player')), findsOneWidget);
      });

      testWidgets('shows tuner tools', (tester) async {
        await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
        await tester.createMetronomeToolInProject();

        await tester.tapAndSettle(find.bySemanticsLabel('Metronome 1'));
        await tester.openConnectionDialog();

        expect(tester.withinConnectionDialog(find.bySemanticsLabel('Tuner')), findsOneWidget);
      });

      testWidgets('does not show metronome tools because tool is metronome itself', (tester) async {
        await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
        await tester.createMetronomeToolInProject();

        await tester.tapAndSettle(find.bySemanticsLabel('Metronome 1'));
        await tester.openConnectionDialog();

        expect(tester.withinConnectionDialog(find.bySemanticsLabel('Metronome')), findsNothing);
      });
    });
  });
}
