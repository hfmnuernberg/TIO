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
  final audio1 = saveTestAudioFile(context, name: 'audio_file_1');
  final audio2 = saveTestAudioFile(context, name: 'audio_file_2');
  await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
  await tester.createMediaPlayerToolInProject();
  await tester.createMediaPlayerWithAudio('Media Player 2', context, audio2);
  await tester.openMediaPlayerAndLoadAudio('Media Player 1', context, audio1);
  await tester.connectExistingTool('Media Player 2');
}

Future<void> prepareMediaPlayerWithUnloadedIsland(WidgetTester tester, TestContext context) async {
  final audio = saveTestAudioFile(context);
  await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
  await tester.createMediaPlayerToolInProject();
  await tester.openMediaPlayerAndLoadAudio('Media Player 1', context, audio);
  await tester.connectNewTool('Media Player', 'Media Player 2');
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
