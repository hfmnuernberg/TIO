import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/pages/project_page/project_page.dart';

import '../../utils/action_utils.dart';
import '../../utils/media_player_utils.dart';
import '../../utils/project_utils.dart';
import '../../utils/render_utils.dart';
import '../../utils/test_context.dart';

Future<void> prepareMediaPlayerWithLoadedIsland(WidgetTester tester, TestContext context) async {
  final audioBytes = File('assets/test/ping.wav').readAsBytesSync();
  final filePath1 = '${context.inMemoryFileSystem.tmpFolderPath}/audio_file_1.wav';
  final filePath2 = '${context.inMemoryFileSystem.tmpFolderPath}/audio_file_2.wav';
  context.inMemoryFileSystem.saveFileAsBytes(filePath1, audioBytes);
  context.inMemoryFileSystem.saveFileAsBytes(filePath2, audioBytes);

  await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);

  // Create Media Player 1
  await tester.createMediaPlayerToolInProject();

  // Create Media Player 2 and load audio on it
  await tester.tapAndSettle(find.byTooltip('Add new tool'));
  await tester.tapAndSettle(find.bySemanticsLabel('Media Player'));
  await tester.enterTextAndSettle(find.bySemanticsLabel('Tool title'), 'Media Player 2');
  await tester.tapAndSettle(find.bySemanticsLabel('Submit'));
  context.filePickerMock.mockPickAudioFromMediaLibrary([filePath2]);
  await tester.scrollToAndTapAndSettle('Open files');
  await tester.tapAndSettle(find.bySemanticsLabel('Back'));

  // Open Media Player 1 and load audio
  await tester.tapAndSettle(find.bySemanticsLabel('Media Player 1'));
  context.filePickerMock.mockPickAudioFromMediaLibrary([filePath1]);
  await tester.scrollToAndTapAndSettle('Open files');

  // Connect Media Player 2 as island
  await tester.ensureVisible(find.byTooltip('Connect another tool'));
  await tester.tapAndSettle(find.byTooltip('Connect another tool'));
  await tester.tapAndSettle(find.bySemanticsLabel('Media Player 2'));
  await tester.pumpAndSettle(const Duration(milliseconds: 1100));
}

Future<void> prepareMediaPlayerWithUnloadedIsland(WidgetTester tester, TestContext context) async {
  final filePath = '${context.inMemoryFileSystem.tmpFolderPath}/audio_file.wav';
  context.inMemoryFileSystem.saveFileAsBytes(filePath, File('assets/test/ping.wav').readAsBytesSync());
  context.filePickerMock.mockPickAudioFromMediaLibrary([filePath]);

  await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);

  // Create Media Player 1 and load audio
  await tester.createMediaPlayerToolInProject();
  await tester.tapAndSettle(find.bySemanticsLabel('Media Player 1'));
  await tester.scrollToAndTapAndSettle('Open files');

  // Connect and create new Media Player 2 (without audio)
  await tester.ensureVisible(find.byTooltip('Connect another tool'));
  await tester.tapAndSettle(find.byTooltip('Connect another tool'));
  await tester.tapAndSettle(find.bySemanticsLabel('Media Player'));
  await tester.enterTextAndSettle(find.bySemanticsLabel('Tool title'), 'Media Player 2');
  await tester.tapAndSettle(find.bySemanticsLabel('Submit'));
  await tester.pumpAndSettle(const Duration(milliseconds: 1100));
}

void main() {
  late TestContext context;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    context = TestContext();
    await context.init(project: Project.defaultThumbnail('Test Project'));
  });

  group('MediaPlayer - island view sync', () {
    group('with loaded audio on island', () {
      testWidgets('renders island view with connected media player', (tester) async {
        await prepareMediaPlayerWithLoadedIsland(tester, context);

        expect(find.byTooltip('Media Player 2: Play / Pause'), findsOneWidget);
      });

      testWidgets('island starts when primary player starts', (tester) async {
        await prepareMediaPlayerWithLoadedIsland(tester, context);
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
        await prepareMediaPlayerWithLoadedIsland(tester, context);
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
        await prepareMediaPlayerWithLoadedIsland(tester, context);
        mockPlayerState(context);

        await tester.tap(find.byTooltip('Media Player 2: Play / Pause'));
        await tester.pump(const Duration(milliseconds: 150));
        await tester.pump(const Duration(milliseconds: 150));

        expect(
          find.descendant(of: find.byTooltip('Media Player 2: Play / Pause'), matching: find.byIcon(Icons.pause)),
          findsOneWidget,
        );
      });

      testWidgets('destroys both player instances on navigation back', (tester) async {
        await prepareMediaPlayerWithLoadedIsland(tester, context);
        clearInteractions(context.audioSystemMock);

        await tester.tapAndSettle(find.bySemanticsLabel('Back'));

        verify(() => context.audioSystemMock.mediaPlayerDestroyInstance(id: any(named: 'id'))).called(2);
      });
    });

    group('without loaded audio on island', () {
      testWidgets('island does not start when no audio loaded', (tester) async {
        await prepareMediaPlayerWithUnloadedIsland(tester, context);

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
