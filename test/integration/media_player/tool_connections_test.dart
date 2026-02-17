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

extension WidgetTesterMediaPlayerExtension on WidgetTester {
  Future<void> openConnectionDialog() async {
    await tapAndSettle(find.byTooltip('Connect another tool'));
  }

  Finder withinConnectionDialog(FinderBase<Element> matching) =>
      find.descendant(of: connectionDialog, matching: matching);

  Finder withinList(FinderBase<Element> matching) =>
      find.descendant(of: find.bySemanticsLabel('Tool list'), matching: matching);
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

  group('MediaPlayer - connections to other tools', () {
    group('connection to existing tools', () {
      testWidgets('shows metronome', (tester) async {
        await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
        await tester.createMediaPlayerToolInProject();
        await tester.tapAndSettle(find.byTooltip('Add new tool'));
        await tester.createMetronomeToolInProject();

        await tester.tapAndSettle(find.bySemanticsLabel('Media Player 1'));
        await tester.openConnectionDialog();

        expect(tester.withinConnectionDialog(find.bySemanticsLabel('Metronome 1')), findsOneWidget);
      });

      testWidgets('connects selected tool', (tester) async {
        await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
        await tester.createMediaPlayerToolInProject();
        await tester.tapAndSettle(find.byTooltip('Add new tool'));
        await tester.createTunerToolInProject();

        await tester.tapAndSettle(find.bySemanticsLabel('Media Player 1'));
        await tester.openConnectionDialog();
        await tester.tapAndSettle(find.bySemanticsLabel('Tuner 1'));
        await tester.pumpAndSettle(const Duration(milliseconds: 1100));

        expect(find.bySemanticsLabel('440 Hz'), findsOneWidget);
      });
    });

    group('connection to new/none existing tools', () {
      testWidgets('shows metronome', (tester) async {
        await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
        await tester.createMediaPlayerToolInProject();

        await tester.tapAndSettle(find.bySemanticsLabel('Media Player 1'));
        await tester.openConnectionDialog();

        expect(tester.withinConnectionDialog(find.bySemanticsLabel('Metronome')), findsOneWidget);
      });

      testWidgets('adds and connects selected tool', (tester) async {
        await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
        await tester.createMediaPlayerToolInProject();

        await tester.tapAndSettle(find.bySemanticsLabel('Media Player 1'));
        await tester.openConnectionDialog();

        await tester.tapAndSettle(find.bySemanticsLabel('Tuner'));
        await tester.enterTextAndSettle(find.bySemanticsLabel('Tool title'), 'Tuner 1');
        await tester.tapAndSettle(find.bySemanticsLabel('Submit'));
        await tester.pumpAndSettle(const Duration(milliseconds: 1100));

        expect(find.bySemanticsLabel('440 Hz'), findsOneWidget);

        await tester.tapAndSettle(find.bySemanticsLabel('Back'));

        expect(tester.withinList(find.bySemanticsLabel('Tuner 1')), findsOneWidget);
      });

      testWidgets('shows media-player because media-player to media-player connection is allowed', (tester) async {
        await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
        await tester.createMediaPlayerToolInProject();

        await tester.tapAndSettle(find.bySemanticsLabel('Media Player 1'));
        await tester.openConnectionDialog();

        expect(tester.withinConnectionDialog(find.bySemanticsLabel('Media Player')), findsOneWidget);
      });
    });
  });
}
