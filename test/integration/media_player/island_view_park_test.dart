import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/models/project.dart';

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

  group('MediaPlayer - island view parking', () {
    testWidgets('island parks at trim end when its track finishes naturally', (tester) async {
      await tester.prepareMediaPlayerWithLoadedIsland(context, primaryDurationSeconds: 10, islandDurationSeconds: 10);
      mockPlayerState(context, playbackPositionFactor: 0.99);

      await tester.ensureVisible(find.byTooltip('Play'));
      await tester.tap(find.byTooltip('Play'));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 150));

      clearInteractions(context.audioSystemMock);

      mockPlayerState(context, playing: false);
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 150));

      verify(
        () => context.audioSystemMock.mediaPlayerSetPlaybackPosFactor(id: any(named: 'id'), posFactor: 1),
      ).called(greaterThanOrEqualTo(1));
    });

    testWidgets('island parks at trim end when primary plays past island range', (tester) async {
      await tester.prepareMediaPlayerWithLoadedIsland(context, primaryDurationSeconds: 10, islandDurationSeconds: 5);
      mockPlayerState(context, playbackPositionFactor: 0.7);
      clearInteractions(context.audioSystemMock);

      await tester.ensureVisible(find.byTooltip('Play'));
      await tester.tap(find.byTooltip('Play'));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 150));

      verify(
        () => context.audioSystemMock.mediaPlayerSetPlaybackPosFactor(id: any(named: 'id'), posFactor: 1),
      ).called(1);
    });

    testWidgets('island parks at trim end when project opens with primary already past island range', (tester) async {
      await tester.prepareMediaPlayerWithLoadedIsland(
        context,
        primaryDurationSeconds: 10,
        islandDurationSeconds: 5,
        primaryInitialPlaybackPositionFactor: 0.9,
      );

      verify(
        () => context.audioSystemMock.mediaPlayerSetPlaybackPosFactor(id: any(named: 'id'), posFactor: 1),
      ).called(1);
    });

    testWidgets('island restarts when primary position changes back into range after looping', (tester) async {
      await tester.prepareMediaPlayerWithLoadedIsland(context, primaryDurationSeconds: 10, islandDurationSeconds: 5);
      mockPlayerState(context, playbackPositionFactor: 0.7);

      await tester.ensureVisible(find.byTooltip('Play'));
      await tester.tap(find.byTooltip('Play'));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.byTooltip('Media Player 2: Play'), findsOneWidget);

      mockPlayerState(context, playbackPositionFactor: 0.1);
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.byTooltip('Media Player 2: Pause'), findsOneWidget);
    });
  });
}
