import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/models/project.dart';
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
}

void main() {
  late TestContext context;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    context = TestContext();
    await context.init(project: Project.defaultThumbnail('Test Project'));
  });

  group('MediaPlayerTool - start and stop on marker settings page', () {
    testWidgets('starts the playback on button click', (tester) async {
      await prepareAndOpenMediaPlayer(tester, context);
      await tester.scrollToAndTapAndSettle('Open files');
      await tester.scrollToAndTapAndSettle('Markers');

      await tester.tapAndSettle(find.byTooltip('Play'));
      context.audioSystemMock.verifyMediaPlayerStartCalled();
    });
  });
}
