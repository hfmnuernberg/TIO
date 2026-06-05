import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/pages/project_page/project_page.dart';
import 'package:tiomusic/pages/projects_page/projects_page.dart';

import '../../mocks/permission_handler_mock.dart';
import '../../utils/action_utils.dart';
import '../../utils/media_player_utils.dart';
import '../../utils/render_utils.dart';
import '../../utils/test_context.dart';
import '../tutorials/tutorials_utils.dart';

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

      await context.inMemoryFileSystem.saveFileAsBytes(recordingPath, pingBytes);
      await tester.ensureVisible(find.byTooltip('Start recording'));
      await tester.tapAndSettle(find.byTooltip('Start recording'));
      await tester.tapAndSettle(find.bySemanticsLabel('Proceed'));
      await tester.ensureVisible(find.byTooltip('Stop recording'));
      await tester.tapAndSettle(find.byTooltip('Stop recording'));

      context.audioSystemMock.verifyMediaPlayerInvalidateWavCacheCalledTimesWith(
        RegExp(r'/Test Project-Media Player 1\.wav$'),
        1,
      );
      context.audioSystemMock.verifyMediaPlayerInvalidateWavCacheCalledTimesWith(
        RegExp(r'/Test Project-Media Player 1_1\.wav$'),
        1,
      );
    });

    testWidgets('quick tool recording does not overwrite an existing media file at the same target path', (
      tester,
    ) async {
      final recordingPath = '${context.inMemoryFileSystem.tmpFolderPath}/recording.wav';
      final existingBytes = File('assets/test/ping.wav').readAsBytesSync();
      final recordingBytes = [...existingBytes, 0xAB, 0xCD];

      context.audioSystemMock.mockMediaPlayerGetRecordingFilePath(recordingPath);

      final preexistingFile = '${context.inMemoryFileSystem.appFolderPath}/media/Quick tool-Media Player.wav';
      await context.inMemoryFileSystem.saveFileAsBytes(preexistingFile, existingBytes);

      await tester.renderScaffold(const ProjectsPage(), context.providers);
      await tester.createAndOpenQuickTool('Media Player');

      await context.inMemoryFileSystem.saveFileAsBytes(recordingPath, recordingBytes);
      await tester.ensureVisible(find.byTooltip('Start recording'));
      await tester.tapAndSettle(find.byTooltip('Start recording'));
      await tester.ensureVisible(find.byTooltip('Stop recording'));
      await tester.tapAndSettle(find.byTooltip('Stop recording'));

      expect(await context.inMemoryFileSystem.loadFileAsBytes(preexistingFile), equals(existingBytes));
    });

    testWidgets('quick tool recording invalidates cache for the recording path', (tester) async {
      final recordingPath = '${context.inMemoryFileSystem.tmpFolderPath}/recording.wav';
      final pingBytes = File('assets/test/ping.wav').readAsBytesSync();

      context.audioSystemMock.mockMediaPlayerGetRecordingFilePath(recordingPath);

      await tester.renderScaffold(const ProjectsPage(), context.providers);

      await tester.createAndOpenQuickTool('Media Player');

      await context.inMemoryFileSystem.saveFileAsBytes(recordingPath, pingBytes);
      await tester.ensureVisible(find.byTooltip('Start recording'));
      await tester.tapAndSettle(find.byTooltip('Start recording'));
      await tester.ensureVisible(find.byTooltip('Stop recording'));
      await tester.tapAndSettle(find.byTooltip('Stop recording'));

      context.audioSystemMock.verifyMediaPlayerInvalidateWavCacheCalledWith(RegExp(r'Quick tool-Media Player\.wav$'));
    });

    testWidgets('share audio menu shows only one entry after re-recording', (tester) async {
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

      await tester.tapAndSettle(find.byTooltip('More options'));
      expect(find.bySemanticsLabel('Share audio file'), findsOneWidget);
      await tester.tapAndSettle(find.byTooltip('More options'));

      await tester.simulatePlatformDidChangeDependencies();

      await context.inMemoryFileSystem.saveFileAsBytes(recordingPath, pingBytes);
      await tester.ensureVisible(find.byTooltip('Start recording'));
      await tester.tapAndSettle(find.byTooltip('Start recording'));
      await tester.tapAndSettle(find.bySemanticsLabel('Proceed'));
      await tester.ensureVisible(find.byTooltip('Stop recording'));
      await tester.tapAndSettle(find.byTooltip('Stop recording'));

      await tester.tapAndSettle(find.byTooltip('More options'));
      expect(find.bySemanticsLabel('Share audio file'), findsOneWidget);
    });
  });
}

extension on WidgetTester {
  Future<void> simulatePlatformDidChangeDependencies() async {
    platformDispatcher.localesTestValue = const [Locale('de', 'DE')];
    binding.handleLocaleChanged();
    await pumpAndSettle();
    platformDispatcher.localesTestValue = const [Locale('en', 'US')];
    binding.handleLocaleChanged();
    await pumpAndSettle();
  }
}
