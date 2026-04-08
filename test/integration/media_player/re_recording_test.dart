import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/pages/project_page/project_page.dart';

import '../../mocks/permission_handler_mock.dart';
import '../../utils/action_utils.dart';
import '../../utils/media_player_utils.dart';
import '../../utils/render_utils.dart';
import '../../utils/test_context.dart';

void main() {
  late TestContext context;
  late PermissionHandlerMock permissionHandlerMock;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    context = TestContext();

    permissionHandlerMock = PermissionHandlerMock()..grant();
    PermissionHandlerPlatform.instance = permissionHandlerMock;

    await context.init(project: Project.defaultThumbnail('Test Project'));
  });

  group('MediaPlayerTool - re-recording', () {
    testWidgets('second recording replaces the first recording in the same block', (tester) async {
      final recordingPath = '${context.inMemoryFileSystem.tmpFolderPath}/recording.wav';
      final pingBytes = File('assets/test/ping.wav').readAsBytesSync();

      context.audioSystemMock.mockMediaPlayerGetRecordingFilePath(recordingPath);

      await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
      await tester.createMediaPlayerToolInProject();
      await tester.tapAndSettle(find.bySemanticsLabel('Media Player 1'));

      await context.inMemoryFileSystem.saveFileAsBytes(recordingPath, pingBytes);
      await tester.ensureVisible(find.byTooltip('Start recording'));
      await tester.tapAndSettle(find.byTooltip('Start recording'));
      await tester.ensureVisible(find.byTooltip('Stop recording'));
      await tester.tapAndSettle(find.byTooltip('Stop recording'));

      context.audioSystemMock.verifyMediaPlayerInvalidateWavCacheNeverCalled();

      await context.inMemoryFileSystem.saveFileAsBytes(recordingPath, pingBytes);
      await tester.ensureVisible(find.byTooltip('Start recording'));
      await tester.tapAndSettle(find.byTooltip('Start recording'));
      await tester.tapAndSettle(find.bySemanticsLabel('Proceed'));
      await tester.ensureVisible(find.byTooltip('Stop recording'));
      await tester.tapAndSettle(find.byTooltip('Stop recording'));

      context.audioSystemMock.verifyMediaPlayerInvalidateWavCacheCalledWith(
        RegExp(r'Test Project-Media Player 1\.wav$'),
      );
    });
  });
}
