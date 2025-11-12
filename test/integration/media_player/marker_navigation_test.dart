import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/pages/project_page/project_page.dart';

import '../../utils/action_utils.dart';
import '../../utils/project_utils.dart';
import '../../utils/render_utils.dart';
import '../../utils/test_context.dart';

Future<void> prepareAndOpenMediaPlayer(WidgetTester tester, TestContext context) async {
  await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
  await tester.createMediaPlayerToolInProject();
  await tester.tapAndSettle(find.bySemanticsLabel('Media Player 1'));
}

extension WidgetTesterMediaPlayerExtension on WidgetTester {
  Finder withinSettingsTile(String title, FinderBase<Element> matching) =>
      find.descendant(of: find.bySemanticsLabel(title), matching: matching);

  Future<void> scrollToAndTapAndSettle(String label) async {
    await ensureVisible(find.bySemanticsLabel(label));
    await tapAndSettle(find.bySemanticsLabel(label));
  }

  Future<void> addMarkerAtPosition(double relativePosition) async {
    await scrollToAndTapAndSettle('Markers');
    final slider = find.byType(Slider);
    final left = getTopLeft(slider);
    final right = getTopRight(slider);
    final y = getCenter(slider).dy;
    final target = Offset(left.dx + (right.dx - left.dx) * relativePosition, y);

    await tapAt(target);
    await tapAndSettle(find.bySemanticsLabel('Add marker'));
    await tapAndSettle(find.bySemanticsLabel('Submit'));
  }
}

void main() {
  late TestContext context;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    context = TestContext();
    await context.init(project: Project.defaultThumbnail('Test Project'));
  });

  group('MediaPlayerTool - marker navigation', () {
    testWidgets('shows marker navigation buttons when markers available', (tester) async {
      await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
      await tester.createMediaPlayerToolInProject();
      await tester.tapAndSettle(find.bySemanticsLabel('Media Player 1'));

      await tester.scrollToAndTapAndSettle('Markers');
      await tester.tapAndSettle(find.bySemanticsLabel('Add marker'));
      await tester.tapAndSettle(find.bySemanticsLabel('Submit'));
      expect(tester.withinSettingsTile('Markers', find.bySemanticsLabel('1')), findsOneWidget);

      expect(find.byTooltip('Back to previous marker'), findsOneWidget);
      expect(find.byTooltip('Forward to next marker'), findsOneWidget);
    });

    testWidgets('hides marker navigation buttons when no markers set', (tester) async {
      await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
      await tester.createMediaPlayerToolInProject();
      await tester.tapAndSettle(find.bySemanticsLabel('Media Player 1'));

      expect(find.byTooltip('Back to previous marker'), findsNothing);
      expect(find.byTooltip('Forward to next marker'), findsNothing);
    });

    testWidgets('skips forward to next marker on button select', (tester) async {
      await prepareAndOpenMediaPlayer(tester, context);
      await tester.addMarkerAtPosition(0.5);
      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionNeverCalled();

      await tester.ensureVisible(find.byTooltip('Forward to next marker'));
      await tester.tapAndSettle(find.byTooltip('Forward to next marker'));

      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(0.5);
    });

    testWidgets('skips forward to first marker on button select when last marker reached', (tester) async {
      await prepareAndOpenMediaPlayer(tester, context);
      await tester.addMarkerAtPosition(0.5);
      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionNeverCalled();

      await tester.ensureVisible(find.byTooltip('Forward to next marker'));
      await tester.tapAndSettle(find.byTooltip('Forward to next marker'));

      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(0.5);

      await tester.tapAndSettle(find.byTooltip('Forward to next marker'));
      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(0.5);
    });

    testWidgets('skips backwards to previous marker on button select', (tester) async {
      await prepareAndOpenMediaPlayer(tester, context);
      await tester.addMarkerAtPosition(0.5);
      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionNeverCalled();

      await tester.ensureVisible(find.byTooltip('Back to previous marker'));
      await tester.tapAndSettle(find.byTooltip('Back to previous marker'));

      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(0.5);
    });

    testWidgets('skips backwards to last marker on button select when first marker reached', (tester) async {
      await prepareAndOpenMediaPlayer(tester, context);
      await tester.addMarkerAtPosition(0.5);
      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionNeverCalled();

      await tester.ensureVisible(find.byTooltip('Back to previous marker'));
      await tester.tapAndSettle(find.byTooltip('Back to previous marker'));

      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(0.5);

      await tester.tapAndSettle(find.byTooltip('Back to previous marker'));

      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(0.5);
    });
  });
}
