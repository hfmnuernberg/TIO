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

extension WidgetTesterTunerExtension on WidgetTester {
  Future<void> openTunerAndSettle() async {
    await tapAndSettle(find.bySemanticsLabel('Tuner 1'));
    await pumpAndSettle(const Duration(milliseconds: 1100));
  }

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

  group('Tuner - connections to other tools', () {
    group('connection to existing tools', () {
      testWidgets('shows metronome', (tester) async {
        await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
        await tester.createTunerToolInProject();
        await tester.tapAndSettle(find.byTooltip('Add new tool'));
        await tester.createMetronomeToolInProject();

        await tester.openTunerAndSettle();
        await tester.openConnectionDialog();

        expect(tester.withinConnectionDialog(find.bySemanticsLabel('Metronome 1')), findsOneWidget);
      });
    });

    group('connection to new/none existing tools', () {
      testWidgets('shows metronome', (tester) async {
        await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
        await tester.createTunerToolInProject();

        await tester.openTunerAndSettle();
        await tester.openConnectionDialog();

        expect(tester.withinConnectionDialog(find.bySemanticsLabel('Metronome')), findsOneWidget);
      });

      testWidgets('does not show tuner because tool is tuner itself', (tester) async {
        await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
        await tester.createTunerToolInProject();

        await tester.openTunerAndSettle();
        await tester.openConnectionDialog();

        expect(tester.withinConnectionDialog(find.bySemanticsLabel('Tuner')), findsNothing);
      });
    });
  });
}
