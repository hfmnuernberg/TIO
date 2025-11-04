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

  Future<void> scrollToAndTapAndSettle(String label) async {
    await ensureVisible(find.bySemanticsLabel(label));
    await tapAndSettle(find.bySemanticsLabel(label));
  }
}

void main() {
  late TestContext context;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    context = TestContext();
    await context.init(project: Project.defaultThumbnail('Test Project'));
  });

  group('MediaPlayerTool - Settings', () {
    group('set volume page', () {
      testWidgets('sets volume', (tester) async {
        await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
        await tester.createMediaPlayerToolInProject();
        await tester.tapAndSettle(find.bySemanticsLabel('Media Player 1'));
        expect(tester.withinSettingsTile('Volume', find.bySemanticsLabel('0.5')), findsOneWidget);
        await tester.scrollToAndTapAndSettle('Volume');

        await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));
        await tester.tapAndSettle(find.bySemanticsLabel('Submit'));

        expect(tester.withinSettingsTile('Volume', find.bySemanticsLabel('0.6')), findsOneWidget);
      });

      testWidgets('does not set volume on cancel', (tester) async {
        await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
        await tester.createMediaPlayerToolInProject();
        await tester.tapAndSettle(find.bySemanticsLabel('Media Player 1'));
        expect(tester.withinSettingsTile('Volume', find.bySemanticsLabel('0.5')), findsOneWidget);
        await tester.scrollToAndTapAndSettle('Volume');

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
        await tester.scrollToAndTapAndSettle('Volume');

        await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));
        await tester.tapAndSettle(find.bySemanticsLabel('Reset'));
        await tester.tapAndSettle(find.bySemanticsLabel('Submit'));

        expect(tester.withinSettingsTile('Volume', find.bySemanticsLabel('0.5')), findsOneWidget);
        expect(tester.withinSettingsTile('Volume', find.bySemanticsLabel('0.6')), findsNothing);
      });
    });

    group('edit markers page', () {
      testWidgets('sets marker', (tester) async {
        await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
        await tester.createMediaPlayerToolInProject();
        await tester.tapAndSettle(find.bySemanticsLabel('Media Player 1'));
        expect(tester.withinSettingsTile('Markers', find.bySemanticsLabel('0')), findsOneWidget);

        await tester.scrollToAndTapAndSettle('Markers');
        await tester.tapAndSettle(find.bySemanticsLabel('Add marker'));
        expect(find.byTooltip('Marker'), findsOneWidget);

        await tester.tapAndSettle(find.bySemanticsLabel('Submit'));
        expect(tester.withinSettingsTile('Markers', find.bySemanticsLabel('1')), findsOneWidget);
      });

      testWidgets('does not set marker on cancel', (tester) async {
        await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
        await tester.createMediaPlayerToolInProject();
        await tester.tapAndSettle(find.bySemanticsLabel('Media Player 1'));

        await tester.scrollToAndTapAndSettle('Markers');
        await tester.tapAndSettle(find.bySemanticsLabel('Add marker'));
        await tester.tapAndSettle(find.bySemanticsLabel('Cancel'));

        expect(tester.withinSettingsTile('Markers', find.bySemanticsLabel('1')), findsNothing);
      });

      testWidgets('deletes marker when selected before', (tester) async {
        await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
        await tester.createMediaPlayerToolInProject();
        await tester.tapAndSettle(find.bySemanticsLabel('Media Player 1'));

        await tester.scrollToAndTapAndSettle('Markers');
        await tester.tapAndSettle(find.bySemanticsLabel('Add marker'));
        expect(find.byTooltip('Marker'), findsOneWidget);

        await tester.tapAndSettle(find.byTooltip('Marker'));
        await tester.tapAndSettle(find.bySemanticsLabel('Remove selected marker'));
        expect(find.byTooltip('Marker'), findsNothing);

        await tester.tapAndSettle(find.bySemanticsLabel('Submit'));
        expect(tester.withinSettingsTile('Markers', find.bySemanticsLabel('1')), findsNothing);
      });

      testWidgets('resets marker on reset', (tester) async {
        await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
        await tester.createMediaPlayerToolInProject();
        await tester.tapAndSettle(find.bySemanticsLabel('Media Player 1'));
        expect(tester.withinSettingsTile('Markers', find.bySemanticsLabel('0')), findsOneWidget);

        await tester.scrollToAndTapAndSettle('Markers');
        await tester.tapAndSettle(find.bySemanticsLabel('Add marker'));
        await tester.scrollToAndTapAndSettle('Reset');
        expect(find.byTooltip('Marker'), findsNothing);

        await tester.tapAndSettle(find.bySemanticsLabel('Submit'));
        expect(tester.withinSettingsTile('Markers', find.bySemanticsLabel('1')), findsNothing);
      });
    });
  });
}
