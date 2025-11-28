import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/pages/media_player/markers/edit_markers_page.dart';
import 'package:tiomusic/pages/project_page/project_page.dart';

import '../../utils/action_utils.dart';
import '../../utils/project_utils.dart';
import '../../utils/render_utils.dart';
import '../../utils/test_context.dart';

Future<void> prepareAndOpenMediaPlayer(WidgetTester tester, TestContext context) async {
  final filePath = '${context.inMemoryFileSystem.tmpFolderPath}/audio_file.wav';
  context.inMemoryFileSystem.saveFileAsBytes(filePath, File('assets/test/ping.wav').readAsBytesSync());
  context.filePickerMock.mockPickAudioFromMediaLibrary([filePath]);
  await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
  await tester.createMediaPlayerToolInProject();
  await tester.tapAndSettle(find.bySemanticsLabel('Media Player 1'));
  await tester.scrollToAndTapAndSettle('Open files');
}

extension WidgetTesterMediaPlayerExtension on WidgetTester {
  Finder withinSettingsTile(String title, FinderBase<Element> matching) =>
      find.descendant(of: find.bySemanticsLabel(title), matching: matching);

  Future<void> skipForward() async {
    await ensureVisible(find.byTooltip('Forward to next marker'));
    await tapAndSettle(find.byTooltip('Forward to next marker'));
  }

  Future<void> skipBackwards() async {
    await ensureVisible(find.byTooltip('Back to previous marker'));
    await tapAndSettle(find.byTooltip('Back to previous marker'));
  }

  Future<void> addMarkerAtPosition(double relativePosition) async {
    await scrollToAndTapAndSettle('Markers');

    await widget<EditMarkersPage>(find.byType(EditMarkersPage)).player.setPlaybackPosition(relativePosition);

    await tapAndSettle(find.byTooltip('Add marker'));
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
      await prepareAndOpenMediaPlayer(tester, context);

      await tester.scrollToAndTapAndSettle('Markers');
      await tester.tapAndSettle(find.byTooltip('Add marker'));
      await tester.tapAndSettle(find.bySemanticsLabel('Submit'));
      expect(tester.withinSettingsTile('Markers', find.bySemanticsLabel('1')), findsOneWidget);

      expect(find.byTooltip('Back to previous marker'), findsOneWidget);
      expect(find.byTooltip('Forward to next marker'), findsOneWidget);
    });

    testWidgets('hides marker navigation buttons when no markers set', (tester) async {
      await prepareAndOpenMediaPlayer(tester, context);

      expect(find.byTooltip('Back to previous marker'), findsNothing);
      expect(find.byTooltip('Forward to next marker'), findsNothing);
    });

    testWidgets('skips forward to next marker on button select', (tester) async {
      await prepareAndOpenMediaPlayer(tester, context);
      await tester.addMarkerAtPosition(0.5);
      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(0.5);

      await tester.skipBackwards();
      await tester.skipForward();

      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(0.5);
    });

    testWidgets('skips forward to end of file on button select when last marker reached', (tester) async {
      await prepareAndOpenMediaPlayer(tester, context);
      await tester.addMarkerAtPosition(0.5);

      await tester.skipForward();

      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(1);
    });

    testWidgets('skips backwards to previous marker on button select', (tester) async {
      await prepareAndOpenMediaPlayer(tester, context);
      await tester.addMarkerAtPosition(0.5);
      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(0.5);

      await tester.skipForward();
      await tester.skipBackwards();

      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(0.5);
    });

    testWidgets('skips backwards to start of file on button select when first marker reached', (tester) async {
      await prepareAndOpenMediaPlayer(tester, context);
      await tester.addMarkerAtPosition(0.5);

      await tester.skipForward();
      await tester.skipBackwards();
      await tester.skipBackwards();

      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(0);
    });
  });
}
