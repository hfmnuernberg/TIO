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

  void mockStartedState() {
    context.audioSystemMock.mockMediaPlayerGetState(
      MediaPlayerState(
        playing: true,
        playbackPositionFactor: 0,
        totalLengthSeconds: 1,
        looping: false,
        trimStartFactor: 0,
        trimEndFactor: 1,
      ),
    );
  }

  void mockStoppedState() {
    context.audioSystemMock.mockMediaPlayerGetState(
      MediaPlayerState(
        playing: false,
        playbackPositionFactor: 0,
        totalLengthSeconds: 1,
        looping: false,
        trimStartFactor: 0,
        trimEndFactor: 1,
      ),
    );
  }

  group('Player', () {
    testWidgets('starts and stops', (tester) async {
      expect(player.isPlaying, isFalse);

      mockStartedState();
      await player.start();
      expect(player.isPlaying, isTrue);

      mockStoppedState();
      await player.stop();
      expect(player.isPlaying, isFalse);
    });

    testWidgets('starts player in audio system when started', (tester) async {
      mockStartedState();
      await player.start();

      context.audioSystemMock.verifyMediaPlayerStartCalled();

      await player.stop();
    });

    testWidgets('starts only once', (tester) async {
      mockStartedState();
      await player.start();
      await player.start();
      context.audioSystemMock.verifyMediaPlayerStartCalled();

      await player.stop();
    });

    testWidgets('sets repeat in audio system when started', (tester) async {
      mockStartedState();
      await player.start();

      context.audioSystemMock.verifyMediaPlayerSetRepeatCalledWith(false);

      await player.stop();
    });

    testWidgets('prepares playback in audio session when started', (tester) async {
      mockStartedState();
      await player.start();

      context.audioSessionMock.verifyPreparePlaybackCalled();

      await player.stop();
    });

    testWidgets('forces screen to stay on when started', (tester) async {
      mockStartedState();
      await player.start();

      context.wakelockMock.verifyEnableCalled();

      await player.stop();
    });

    testWidgets('fetches the media player state when started for state updates', (tester) async {
      mockStartedState();
      await player.start();

      context.audioSystemMock.verifyMediaPlayerGetStateCalled();

      await player.stop();
    });

    testWidgets('stops player in audio system when stopped', (tester) async {
      mockStartedState();
      await player.start();

      await player.stop();

      context.audioSystemMock.verifyMediaPlayerStopCalled();
    });

    testWidgets('stops only once', (tester) async {
      mockStartedState();
      await player.start();

      mockStoppedState();
      await player.stop();
      await player.stop();

      context.audioSystemMock.verifyMediaPlayerStopCalled();
    });

    testWidgets('fails to start player when audio system signals failure', (tester) async {
      context.audioSystemMock.mockMediaPlayerStart(false);

      await player.start();

      expect(player.isPlaying, isFalse);
    });

    testWidgets('fails to stop player when audio system signals failure', (tester) async {
      mockStartedState();
      context.audioSystemMock.mockMediaPlayerStop(false);
      await player.start();

      await player.stop();

      expect(player.isPlaying, isTrue);
    });
  });
}
