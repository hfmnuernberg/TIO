import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/pages/project_page/project_page.dart';

import '../../utils/action_utils.dart';
import '../../utils/media_player_utils.dart';
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

void main() {
  late TestContext context;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    context = TestContext();
    await context.init(project: Project.defaultThumbnail('Test Project'));
    context.audioSystemMock.mockMediaPlayerLoadWav();
    mockPlayerState(context);
  });

  group('MediaPlayerTool - set trim', () {
    group('zoom and scroll', () {
      testWidgets('shows start, ending and range times initially', (tester) async {
        await prepareAndOpenMediaPlayer(tester, context);
        await tester.scrollToAndTapAndSettle('Trim');

        expect(find.textContaining('00:00:000'), findsNWidgets(2));
        expect(find.textContaining('00:10:000'), findsNWidgets(2));
      });

      testWidgets('zoom out is not enabled initially', (tester) async {
        await prepareAndOpenMediaPlayer(tester, context);
        await tester.scrollToAndTapAndSettle('Trim');

        expect(tester.getSemantics(find.byTooltip('Zoom out')).flagsCollection.isEnabled, isFalse);
      });

      testWidgets('scroll left is not enabled initially', (tester) async {
        await prepareAndOpenMediaPlayer(tester, context);
        await tester.scrollToAndTapAndSettle('Trim');

        expect(tester.getSemantics(find.byTooltip('Scroll left')).flagsCollection.isEnabled, isFalse);
      });

      testWidgets('scroll right is not enabled initially', (tester) async {
        await prepareAndOpenMediaPlayer(tester, context);
        await tester.scrollToAndTapAndSettle('Trim');

        expect(tester.getSemantics(find.byTooltip('Scroll right')).flagsCollection.isEnabled, isFalse);
      });

      testWidgets('shows new window times after zoomed in', (tester) async {
        await prepareAndOpenMediaPlayer(tester, context);
        await tester.scrollToAndTapAndSettle('Trim');

        await tester.tapAndSettle(find.byTooltip('Zoom in'));

        expect(find.textContaining('00:02:500'), findsOneWidget);
        expect(find.textContaining('00:07:500'), findsOneWidget);
      });

      testWidgets('shows new window times after scrolled left', (tester) async {
        await prepareAndOpenMediaPlayer(tester, context);
        await tester.scrollToAndTapAndSettle('Trim');
        await tester.tapAndSettle(find.byTooltip('Zoom in'));

        await tester.tapAndSettle(find.byTooltip('Scroll left'));

        expect(find.textContaining('00:00:000'), findsNWidgets(2));
        expect(find.textContaining('00:05:000'), findsOneWidget);
      });

      testWidgets('shows new window times after scrolled right', (tester) async {
        await prepareAndOpenMediaPlayer(tester, context);
        await tester.scrollToAndTapAndSettle('Trim');
        await tester.tapAndSettle(find.byTooltip('Zoom in'));

        await tester.tapAndSettle(find.byTooltip('Scroll right'));

        expect(find.textContaining('00:05:000'), findsOneWidget);
        expect(find.textContaining('00:10:000'), findsNWidgets(2));
      });

      testWidgets('shows new window times after zoomed out', (tester) async {
        await prepareAndOpenMediaPlayer(tester, context);
        await tester.scrollToAndTapAndSettle('Trim');

        await tester.tapAndSettle(find.byTooltip('Zoom in'));
        await tester.tapAndSettle(find.byTooltip('Zoom out'));

        expect(find.textContaining('00:00:000'), findsNWidgets(2));
        expect(find.textContaining('00:10:000'), findsNWidgets(2));
      });

      testWidgets('zoom in is not enabled when max zoomed in', (tester) async {
        await prepareAndOpenMediaPlayer(tester, context);
        await tester.scrollToAndTapAndSettle('Trim');

        await tester.tapAndSettle(find.byTooltip('Zoom in'));
        await tester.tapAndSettle(find.byTooltip('Zoom in'));
        await tester.tapAndSettle(find.byTooltip('Zoom in'));
        await tester.tapAndSettle(find.byTooltip('Zoom in'));
        await tester.pumpAndSettle();

        expect(tester.getSemantics(find.byTooltip('Zoom in')).flagsCollection.isEnabled, isFalse);
        expect(find.textContaining('00:04:500'), findsOneWidget);
        expect(find.textContaining('00:05:500'), findsOneWidget);
      });
    });
  });
}
