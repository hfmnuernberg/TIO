import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/domain/audio/player.dart';

import '../../../mocks/player_handler_mock.dart';
import '../../../utils/media_player_utils.dart';
import '../../../utils/test_context.dart';

void main() {
  late TestContext context;
  late PlayerHandlerMock playerHandlerMock;
  late Player player;

  setUp(() async {
    resetMocktailState();
    context = TestContext();
    playerHandlerMock = PlayerHandlerMock();
    player = Player(context.audioSystem, context.audioSession, context.inMemoryFileSystem, context.wakelock);
  });

  group('Player - track completion', () {
    testWidgets('notifies when track finishes and position was near end', (tester) async {
      player.addOnTrackCompletedListener(playerHandlerMock.onTrackCompleted);
      mockPlayerState(context, playbackPositionFactor: 0.99);
      await player.start();

      mockPlayerState(context, playing: false, playbackPositionFactor: 0.99);
      await tester.pump(const Duration(milliseconds: playbackSamplingIntervalInMs + 1));

      playerHandlerMock.verifyOnTrackCompletedCalled();

      await player.stop();
    });

    testWidgets('notifies when track finishes and position resets to start', (tester) async {
      player.addOnTrackCompletedListener(playerHandlerMock.onTrackCompleted);
      mockPlayerState(context, playbackPositionFactor: 0.99);
      await player.start();

      mockPlayerState(context, playing: false);
      await tester.pump(const Duration(milliseconds: playbackSamplingIntervalInMs + 1));

      playerHandlerMock.verifyOnTrackCompletedCalled();

      await player.stop();
    });

    testWidgets('does not notify when manually stopped mid-track', (tester) async {
      player.addOnTrackCompletedListener(playerHandlerMock.onTrackCompleted);
      mockPlayerState(context, playbackPositionFactor: 0.5);
      await player.start();

      mockPlayerState(context, playing: false, playbackPositionFactor: 0.5);
      await tester.pump(const Duration(milliseconds: playbackSamplingIntervalInMs + 1));

      playerHandlerMock.verifyOnTrackCompletedNeverCalled();

      await player.stop();
    });

    testWidgets('does not notify when track loops', (tester) async {
      player.addOnTrackCompletedListener(playerHandlerMock.onTrackCompleted);
      mockPlayerState(context, playbackPositionFactor: 0.99);
      await player.start();

      mockPlayerState(context);
      await tester.pump(const Duration(milliseconds: playbackSamplingIntervalInMs + 1));

      playerHandlerMock.verifyOnTrackCompletedNeverCalled();

      await player.stop();
    });

    testWidgets('does not notify when already stopped', (tester) async {
      player.addOnTrackCompletedListener(playerHandlerMock.onTrackCompleted);
      mockPlayerState(context, playing: false);

      await tester.pump(const Duration(milliseconds: playbackSamplingIntervalInMs + 1));

      playerHandlerMock.verifyOnTrackCompletedNeverCalled();
    });

    testWidgets('does not notify removed listener', (tester) async {
      player.addOnTrackCompletedListener(playerHandlerMock.onTrackCompleted);
      player.removeOnTrackCompletedListener(playerHandlerMock.onTrackCompleted);
      mockPlayerState(context, playbackPositionFactor: 0.99);
      await player.start();

      mockPlayerState(context, playing: false);
      await tester.pump(const Duration(milliseconds: playbackSamplingIntervalInMs + 1));

      playerHandlerMock.verifyOnTrackCompletedNeverCalled();

      await player.stop();
    });

    testWidgets('notifies with custom trim range', (tester) async {
      player.addOnTrackCompletedListener(playerHandlerMock.onTrackCompleted);
      await player.setTrim(0.2, 0.8);
      mockPlayerState(context, playbackPositionFactor: 0.75);
      await player.start();

      mockPlayerState(context, playing: false, playbackPositionFactor: 0.2);
      await tester.pump(const Duration(milliseconds: playbackSamplingIntervalInMs + 1));

      playerHandlerMock.verifyOnTrackCompletedCalled();

      await player.stop();
    });

    testWidgets('does not notify when stopped at trim start without playing near trim end', (tester) async {
      player.addOnTrackCompletedListener(playerHandlerMock.onTrackCompleted);
      await player.setTrim(0.2, 0.8);
      mockPlayerState(context, playbackPositionFactor: 0.3);
      await player.start();

      mockPlayerState(context, playing: false, playbackPositionFactor: 0.2);
      await tester.pump(const Duration(milliseconds: playbackSamplingIntervalInMs + 1));

      playerHandlerMock.verifyOnTrackCompletedNeverCalled();

      await player.stop();
    });
  });
}
