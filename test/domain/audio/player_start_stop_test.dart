import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/domain/audio/player.dart';
import 'package:tiomusic/src/rust/api/modules/media_player.dart';

import '../../utils/test_context.dart';

void main() {
  late TestContext context;
  late Player player;

  setUp(() async {
    resetMocktailState();
    context = TestContext();
    player = Player(context.audioSystem, context.audioSession, context.inMemoryFileSystem, context.wakelock);
  });

  void mockPlayerState({
    bool playing = true,
    double playbackPositionFactor = 0,
    double totalLengthSeconds = 1,
    bool looping = false,
    double trimStartFactor = 0,
    double trimEndFactor = 1,
  }) {
    context.audioSystemMock.mockMediaPlayerGetState(
      MediaPlayerState(
        playing: playing,
        playbackPositionFactor: playbackPositionFactor,
        totalLengthSeconds: totalLengthSeconds,
        looping: looping,
        trimStartFactor: trimStartFactor,
        trimEndFactor: trimEndFactor,
      ),
    );
  }

  group('Player', () {
    testWidgets('starts and stops', (tester) async {
      expect(player.isPlaying, isFalse);

      mockPlayerState();
      await player.start();
      expect(player.isPlaying, isTrue);

      mockPlayerState(playing: false);
      await player.stop();
      expect(player.isPlaying, isFalse);
    });

    testWidgets('starts player in audio system when started', (tester) async {
      mockPlayerState();
      await player.start();

      context.audioSystemMock.verifyMediaPlayerStartCalled();

      await player.stop();
    });

    testWidgets('starts only once', (tester) async {
      mockPlayerState();
      await player.start();
      await player.start();
      context.audioSystemMock.verifyMediaPlayerStartCalled();

      await player.stop();
    });

    testWidgets('sets repeat in audio system when started', (tester) async {
      mockPlayerState();
      await player.start();

      context.audioSystemMock.verifyMediaPlayerSetRepeatCalledWith(false);

      await player.stop();
    });

    testWidgets('prepares playback in audio session when started', (tester) async {
      mockPlayerState();
      await player.start();

      context.audioSessionMock.verifyPreparePlaybackCalled();

      await player.stop();
    });

    testWidgets('restarts generator in audio system when started', (tester) async {
      mockPlayerState();
      player.markers.positions = [0];
      await player.start();

      context.audioSystemMock.verifyGeneratorStartCalled();
      context.audioSystemMock.verifyGeneratorStopCalled();

      await player.stop();
    });

    testWidgets('does not start generator in audio system when no positions', (tester) async {
      mockPlayerState();
      player.markers.positions = [];
      await player.start();

      context.audioSystemMock.verifyGeneratorStartNeverCalled();

      await player.stop();
    });

    testWidgets('forces screen to stay on when started', (tester) async {
      mockPlayerState();
      await player.start();

      context.wakelockMock.verifyEnableCalled();

      await player.stop();
    });

    testWidgets('fetches the media player state when started for state updates', (tester) async {
      mockPlayerState();
      await player.start();

      context.audioSystemMock.verifyMediaPlayerGetStateCalled();

      await player.stop();
    });

    testWidgets('fires periodic update tick after start', (tester) async {
      mockPlayerState();
      await player.start();
      context.audioSystemMock.verifyMediaPlayerGetStateCalled();

      await tester.pump(const Duration(milliseconds: playbackSamplingIntervalInMs + 1));
      context.audioSystemMock.verifyMediaPlayerGetStateCalled();

      await player.stop();
    });

    testWidgets('stops player in audio system when stopped', (tester) async {
      mockPlayerState();
      await player.start();

      await player.stop();

      context.audioSystemMock.verifyMediaPlayerStopCalled();
    });

    testWidgets('stops only once', (tester) async {
      mockPlayerState();
      await player.start();

      mockPlayerState(playing: false);
      await player.stop();
      await player.stop();

      context.audioSystemMock.verifyMediaPlayerStopCalled();
    });

    testWidgets('stops generator in audio system when stopped', (tester) async {
      mockPlayerState();
      player.markers.positions = [0];
      await player.start();
      context.audioSystemMock.verifyGeneratorStopCalled();

      await player.stop();

      context.audioSystemMock.verifyGeneratorStopCalled();
    });

    testWidgets('fails to start player when audio system signals failure', (tester) async {
      context.audioSystemMock.mockMediaPlayerStart(false);

      await player.start();

      expect(player.isPlaying, isFalse);
    });

    testWidgets('fails to stop player when audio system signals failure', (tester) async {
      mockPlayerState();
      context.audioSystemMock.mockMediaPlayerStop(false);
      await player.start();

      await player.stop();

      expect(player.isPlaying, isTrue);
    });
  });
}
