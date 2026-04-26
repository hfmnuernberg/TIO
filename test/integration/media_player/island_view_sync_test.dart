import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/models/project.dart';

import '../../utils/action_utils.dart';
import '../../utils/island_view_test_utils.dart';
import '../../utils/media_player_utils.dart';
import '../../utils/test_context.dart';

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
        await tester.prepareMediaPlayerWithLoadedIsland(context);

        expect(find.byTooltip('Media Player 2: Play'), findsOneWidget);
      });

      testWidgets('island starts when primary player starts', (tester) async {
        await tester.prepareMediaPlayerWithLoadedIsland(context);
        mockPlayerState(context);

        await tester.ensureVisible(find.byTooltip('Play'));
        await tester.tap(find.byTooltip('Play'));
        await tester.pump(const Duration(milliseconds: 150));
        await tester.pump(const Duration(milliseconds: 150));

        expect(find.byTooltip('Media Player 2: Pause'), findsOneWidget);
      });

      testWidgets('island stops when primary player stops', (tester) async {
        await tester.prepareMediaPlayerWithLoadedIsland(context);
        mockPlayerState(context);

        await tester.ensureVisible(find.byTooltip('Play'));
        await tester.tap(find.byTooltip('Play'));
        await tester.pump(const Duration(milliseconds: 150));
        await tester.pump(const Duration(milliseconds: 150));

        expect(find.byTooltip('Media Player 2: Pause'), findsOneWidget);

        mockPlayerState(context, playing: false, playbackPositionFactor: 0.1);
        await tester.ensureVisible(find.byTooltip('Pause'));
        await tester.tap(find.byTooltip('Pause'));
        await tester.pump(const Duration(milliseconds: 150));
        await tester.pump(const Duration(milliseconds: 150));

        expect(find.byTooltip('Media Player 2: Play'), findsOneWidget);
      });

      testWidgets('island position is not overwritten when primary pauses and resumes', (tester) async {
        await tester.prepareMediaPlayerWithLoadedIsland(context, primaryDurationSeconds: 10, islandDurationSeconds: 10);
        mockPlayerState(context);

        await tester.ensureVisible(find.byTooltip('Play'));
        await tester.tap(find.byTooltip('Play'));
        await tester.pump(const Duration(milliseconds: 150));
        await tester.pump(const Duration(milliseconds: 150));

        mockPlayerState(context, playbackPositionFactor: 0.4);
        await tester.pump(const Duration(milliseconds: 150));
        await tester.pump(const Duration(milliseconds: 150));

        mockPlayerState(context, playing: false, playbackPositionFactor: 0.4);
        await tester.ensureVisible(find.byTooltip('Pause'));
        await tester.tap(find.byTooltip('Pause'));
        await tester.pump(const Duration(milliseconds: 150));
        await tester.pump(const Duration(milliseconds: 150));

        clearInteractions(context.audioSystemMock);

        mockPlayerState(context, playbackPositionFactor: 0.4);
        await tester.ensureVisible(find.byTooltip('Play'));
        await tester.tap(find.byTooltip('Play'));
        await tester.pump(const Duration(milliseconds: 150));
        await tester.pump(const Duration(milliseconds: 150));

        verifyNever(
          () => context.audioSystemMock.mediaPlayerSetPlaybackPosFactor(
            id: any(named: 'id'),
            posFactor: any(named: 'posFactor'),
          ),
        );
        expect(find.byTooltip('Media Player 2: Pause'), findsOneWidget);
      });

      testWidgets('island play/pause toggles independently', (tester) async {
        await tester.prepareMediaPlayerWithLoadedIsland(context);
        mockPlayerState(context);

        await tester.tap(find.byTooltip('Media Player 2: Play'));
        await tester.pump(const Duration(milliseconds: 150));
        await tester.pump(const Duration(milliseconds: 150));

        expect(find.byTooltip('Media Player 2: Pause'), findsOneWidget);
      });

      testWidgets('destroys both player instances on navigation back', (tester) async {
        await tester.prepareMediaPlayerWithLoadedIsland(context);
        clearInteractions(context.audioSystemMock);

        await tester.tapAndSettle(find.bySemanticsLabel('Back'));

        verify(() => context.audioSystemMock.mediaPlayerDestroyInstance(id: any(named: 'id'))).called(2);
      });

      testWidgets('island does not start when primary position is beyond island range', (tester) async {
        await tester.prepareMediaPlayerWithLoadedIsland(context, primaryDurationSeconds: 10, islandDurationSeconds: 5);
        mockPlayerState(context, playbackPositionFactor: 0.7);

        await tester.ensureVisible(find.byTooltip('Play'));
        await tester.tap(find.byTooltip('Play'));
        await tester.pump(const Duration(milliseconds: 150));
        await tester.pump(const Duration(milliseconds: 150));

        expect(find.byTooltip('Media Player 2: Play'), findsOneWidget);
      });
    });

    group('without loaded audio on island', () {
      testWidgets('island does not start when no audio loaded', (tester) async {
        await tester.prepareMediaPlayerWithUnloadedIsland(context);

        mockPlayerState(context);
        await tester.ensureVisible(find.byTooltip('Play'));
        await tester.tap(find.byTooltip('Play'));
        await tester.pump(const Duration(milliseconds: 150));
        await tester.pump(const Duration(milliseconds: 150));

        expect(find.byTooltip('Media Player 2: Pause'), findsNothing);
      });
    });
  });
}
