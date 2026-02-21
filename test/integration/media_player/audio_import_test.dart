import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/pages/project_page/project_page.dart';

import '../../utils/action_utils.dart';
import '../../utils/media_player_utils.dart';
import '../../utils/render_utils.dart';
import '../../utils/test_context.dart';

void main() {
  late TestContext context;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    context = TestContext();
    await context.init(project: Project.defaultThumbnail('Test Project'));
  });

  group('MediaPlayerTool', () {
    testWidgets('imports audio file', (tester) async {
      final filePath = '${context.inMemoryFileSystem.tmpFolderPath}/audio_file.wav';
      context.inMemoryFileSystem.saveFileAsBytes(filePath, File('assets/test/ping.wav').readAsBytesSync());
      context.filePickerMock.mockPickAudioFromMediaLibrary([filePath]);

      await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
      await tester.createMediaPlayerToolInProject();

      await tester.tapAndSettle(find.bySemanticsLabel('Media Player 1'));
      await tester.scrollToAndTapAndSettle('Open files');

      expect(find.textContaining('audio_file'), findsOneWidget);
    });

    testWidgets('imports multiple audio files', (tester) async {
      final filePath1 = '${context.inMemoryFileSystem.tmpFolderPath}/audio_file_01.wav';
      final filePath2 = '${context.inMemoryFileSystem.tmpFolderPath}/audio_file_02.wav';
      context.inMemoryFileSystem.saveFileAsBytes(filePath1, File('assets/test/ping.wav').readAsBytesSync());
      context.inMemoryFileSystem.saveFileAsBytes(filePath2, File('assets/test/ping.wav').readAsBytesSync());
      context.filePickerMock.mockPickAudioFromMediaLibrary([filePath1, filePath2]);

      await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);

      await tester.createMediaPlayerToolInProject();
      await tester.tapAndSettle(find.bySemanticsLabel('Media Player 1'));
      await tester.scrollToAndTapAndSettle('Open files');
      await tester.tapAndSettle(find.bySemanticsLabel('Back'));

      expect(find.bySemanticsLabel('Media Player 1'), findsOneWidget);
      expect(find.bySemanticsLabel('Media Player 1 (1)'), findsOneWidget);
    });
  });
}
