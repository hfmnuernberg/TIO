import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

extension WidgetTesterTunerExtension on WidgetTester {
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

  group('TunerTool - connections to other tools', () {
    testWidgets('provides connection possibility', (tester) async {
      await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
      await tester.createTunerToolInProject();

      await tester.tapAndSettle(find.bySemanticsLabel('Tuner 1'));
      await tester.pumpAndSettle(const Duration(milliseconds: 1100));

      expect(find.byTooltip('Connect another tool'), findsOneWidget);
    });

    testWidgets('shows connection bottom sheet when connection button pressed', (tester) async {
      await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
      await tester.createTunerToolInProject();

      await tester.tapAndSettle(find.bySemanticsLabel('Tuner 1'));
      await tester.pumpAndSettle(const Duration(milliseconds: 1100));

      await tester.tapAndSettle(find.byTooltip('Connect another tool'));

      expect(connectionDialog, findsOneWidget);
    });

    group('connection to existing tools', () {
      testWidgets('shows media-player tools', (tester) async {
        await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
        await tester.createTunerToolInProject();
        await tester.tapAndSettle(find.byTooltip('Add new tool'));
        await tester.createMediaPlayerToolInProject();

        await tester.tapAndSettle(find.bySemanticsLabel('Tuner 1'));
        await tester.pumpAndSettle(const Duration(milliseconds: 1100));
        await tester.tapAndSettle(find.byTooltip('Connect another tool'));

        expect(tester.withinConnectionDialog(find.bySemanticsLabel('Media Player 1')), findsOneWidget);
      });

      testWidgets('shows metronome tools', (tester) async {
        await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
        await tester.createTunerToolInProject();
        await tester.tapAndSettle(find.byTooltip('Add new tool'));
        await tester.createMetronomeToolInProject();

        await tester.tapAndSettle(find.bySemanticsLabel('Tuner 1'));
        await tester.pumpAndSettle(const Duration(milliseconds: 1100));
        await tester.tapAndSettle(find.byTooltip('Connect another tool'));

        expect(tester.withinConnectionDialog(find.bySemanticsLabel('Metronome 1')), findsOneWidget);
      });
    });
  });
}
