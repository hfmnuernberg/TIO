import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/pages/project_page/project_page.dart';

import '../../utils/action_utils.dart';
import '../../utils/project_utils.dart';
import '../../utils/render_utils.dart';
import '../../utils/test_context.dart';

extension WidgetTesterMediaPlayerExtension on WidgetTester {
  Finder withinSettingsTile(String title, FinderBase<Element> matching) =>
      find.descendant(of: find.bySemanticsLabel(title), matching: matching);
}

void main() {
  late TestContext context;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    context = TestContext();
    await context.init(project: Project.defaultThumbnail('Test Project'));
  });

  group('MediaPlayerTool - Settings', () {
    testWidgets('sets volume', (tester) async {
      await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
      await tester.createMediaPlayerToolInProject();
      await tester.tapAndSettle(find.bySemanticsLabel('Media Player 1'));
      expect(tester.withinSettingsTile('Volume', find.bySemanticsLabel('0.5')), findsOneWidget);
      await tester.ensureVisible(find.bySemanticsLabel('Volume'));
      await tester.tapAndSettle(find.bySemanticsLabel('Volume'));

      await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));
      await tester.tapAndSettle(find.bySemanticsLabel('Submit'));

      expect(tester.withinSettingsTile('Volume', find.bySemanticsLabel('0.6')), findsOneWidget);
    });

    testWidgets('does not set volume on cancel', (tester) async {
      await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
      await tester.createMediaPlayerToolInProject();
      await tester.tapAndSettle(find.bySemanticsLabel('Media Player 1'));
      expect(tester.withinSettingsTile('Volume', find.bySemanticsLabel('0.5')), findsOneWidget);
      await tester.ensureVisible(find.bySemanticsLabel('Volume'));
      await tester.tapAndSettle(find.bySemanticsLabel('Volume'));

      await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));
      await tester.tapAndSettle(find.bySemanticsLabel('Cancel'));

      expect(tester.withinSettingsTile('Volume', find.bySemanticsLabel('0.5')), findsOneWidget);
      expect(tester.withinSettingsTile('Volume', find.bySemanticsLabel('0.6')), findsNothing);
    });

    testWidgets('resets volume on reset', (tester) async {
      await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
      await tester.createMediaPlayerToolInProject();
      await tester.tapAndSettle(find.bySemanticsLabel('Media Player 1'));
      expect(tester.withinSettingsTile('Volume', find.bySemanticsLabel('0.5')), findsOneWidget);
      await tester.ensureVisible(find.bySemanticsLabel('Volume'));
      await tester.tapAndSettle(find.bySemanticsLabel('Volume'));

      await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));
      await tester.tapAndSettle(find.bySemanticsLabel('Reset'));
      await tester.tapAndSettle(find.bySemanticsLabel('Submit'));

      expect(tester.withinSettingsTile('Volume', find.bySemanticsLabel('0.5')), findsOneWidget);
      expect(tester.withinSettingsTile('Volume', find.bySemanticsLabel('0.6')), findsNothing);
    });
  });
}
