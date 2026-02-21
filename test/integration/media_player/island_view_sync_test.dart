import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/pages/project_page/project_page.dart';

import '../../utils/action_utils.dart';
import '../../utils/media_player_utils.dart';
import '../../utils/project_utils.dart';
import '../../utils/render_utils.dart';
import '../../utils/test_context.dart';

Future<void> prepareMediaPlayerWithIsland(WidgetTester tester, TestContext context) async {
  final filePath = '${context.inMemoryFileSystem.tmpFolderPath}/audio_file.wav';
  context.inMemoryFileSystem.saveFileAsBytes(filePath, File('assets/test/ping.wav').readAsBytesSync());
  context.filePickerMock.mockPickAudioFromMediaLibrary([filePath]);

  await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
  await tester.tapAndSettle(find.byTooltip('Add new tool'));
  await tester.createMediaPlayerToolInProject();
  await tester.tapAndSettle(find.bySemanticsLabel('Media Player 1'));
  await tester.scrollToAndTapAndSettle('Open files');

  await tester.ensureVisible(find.byTooltip('Connect another tool'));
  await tester.tapAndSettle(find.byTooltip('Connect another tool'));
  await tester.tapAndSettle(find.bySemanticsLabel('Media Player 2'));
  await tester.pumpAndSettle(const Duration(milliseconds: 1100));
}

void main() {
  late TestContext context;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  group('MediaPlayer - island view sync', () {
    group('with loaded audio on island', () {
      setUp(() async {
        context = TestContext();
        final project = Project.defaultThumbnail('Test Project');
        final mp2 = MediaPlayerBlock.withTitle('Media Player 2');
        mp2.relativePath = 'audio_file.wav';
        project.addBlock(mp2);
        await context.init(project: project);
        context.inMemoryFileSystem.saveFileAsBytes(
          '${context.inMemoryFileSystem.appFolderPath}/audio_file.wav',
          File('assets/test/ping.wav').readAsBytesSync(),
        );
      });

      testWidgets('renders island view with connected media player', (tester) async {
        await prepareMediaPlayerWithIsland(tester, context);

        expect(find.byTooltip('Media Player 2: Play / Pause'), findsOneWidget);
      });

      testWidgets('island starts when primary player starts', (tester) async {
        await prepareMediaPlayerWithIsland(tester, context);
        mockPlayerState(context);

        await tester.ensureVisible(find.byTooltip('Play'));
        await tester.tap(find.byTooltip('Play'));
        await tester.pump(const Duration(milliseconds: 150));
        await tester.pump(const Duration(milliseconds: 150));

        expect(
          find.descendant(of: find.byTooltip('Media Player 2: Play / Pause'), matching: find.byIcon(Icons.pause)),
          findsOneWidget,
        );
      });

      testWidgets('island stops when primary player stops', (tester) async {
        await prepareMediaPlayerWithIsland(tester, context);
        mockPlayerState(context);

        await tester.ensureVisible(find.byTooltip('Play'));
        await tester.tap(find.byTooltip('Play'));
        await tester.pump(const Duration(milliseconds: 150));
        await tester.pump(const Duration(milliseconds: 150));

        expect(
          find.descendant(of: find.byTooltip('Media Player 2: Play / Pause'), matching: find.byIcon(Icons.pause)),
          findsOneWidget,
        );

        mockPlayerState(context, playing: false, playbackPositionFactor: 0.1);
        await tester.ensureVisible(find.byTooltip('Pause'));
        await tester.tap(find.byTooltip('Pause'));
        await tester.pump(const Duration(milliseconds: 150));
        await tester.pump(const Duration(milliseconds: 150));

        expect(
          find.descendant(of: find.byTooltip('Media Player 2: Play / Pause'), matching: find.byIcon(Icons.play_arrow)),
          findsOneWidget,
        );
      });

      testWidgets('island play/pause toggles independently', (tester) async {
        await prepareMediaPlayerWithIsland(tester, context);
        mockPlayerState(context);

        await tester.tap(find.byTooltip('Media Player 2: Play / Pause'));
        await tester.pump(const Duration(milliseconds: 150));
        await tester.pump(const Duration(milliseconds: 150));

        expect(
          find.descendant(of: find.byTooltip('Media Player 2: Play / Pause'), matching: find.byIcon(Icons.pause)),
          findsOneWidget,
        );
      });

      testWidgets('cleans up on navigation back', (tester) async {
        await prepareMediaPlayerWithIsland(tester, context);

        await tester.tapAndSettle(find.bySemanticsLabel('Back'));

        // Both primary and island players call destroyInstance, so we expect at least 2 calls
        // (primary player + island player; potentially more due to multiple player instances during setup)
        verify(() => context.audioSystemMock.mediaPlayerDestroyInstance(id: any(named: 'id')));
      });
    });

    group('without loaded audio on island', () {
      setUp(() async {
        context = TestContext();
        final project = Project.defaultThumbnail('Test Project');
        final mp2 = MediaPlayerBlock.withTitle('Media Player 2');
        project.addBlock(mp2);
        await context.init(project: project);
      });

      testWidgets('island does not start when no audio loaded', (tester) async {
        final filePath = '${context.inMemoryFileSystem.tmpFolderPath}/audio_file.wav';
        context.inMemoryFileSystem.saveFileAsBytes(filePath, File('assets/test/ping.wav').readAsBytesSync());
        context.filePickerMock.mockPickAudioFromMediaLibrary([filePath]);

        await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
        await tester.tapAndSettle(find.byTooltip('Add new tool'));
        await tester.createMediaPlayerToolInProject();
        await tester.tapAndSettle(find.bySemanticsLabel('Media Player 1'));
        await tester.scrollToAndTapAndSettle('Open files');

        await tester.ensureVisible(find.byTooltip('Connect another tool'));
        await tester.tapAndSettle(find.byTooltip('Connect another tool'));
        await tester.tapAndSettle(find.bySemanticsLabel('Media Player 2'));
        await tester.pumpAndSettle(const Duration(milliseconds: 1100));

        mockPlayerState(context);
        await tester.ensureVisible(find.byTooltip('Play'));
        await tester.tap(find.byTooltip('Play'));
        await tester.pump(const Duration(milliseconds: 150));
        await tester.pump(const Duration(milliseconds: 150));

        expect(
          find.descendant(of: find.byTooltip('Media Player 2: Play / Pause'), matching: find.byIcon(Icons.pause)),
          findsNothing,
        );
      });
    });
  });
}
