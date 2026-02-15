import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/domain/audio/player.dart';

import '../../../utils/media_player_utils.dart';
import '../../../utils/test_context.dart';

void main() {
  late TestContext context;
  late Player player;

  setUp(() async {
    resetMocktailState();
    context = TestContext();
    player = Player(0, context.audioSystem, context.audioSession, context.inMemoryFileSystem, context.wakelock);
  });

  group('Player', () {
    testWidgets('starts and stops', (tester) async {
      expect(player.isPlaying, isFalse);

      mockPlayerState(context);
      await player.start();
      expect(player.isPlaying, isTrue);

      mockPlayerState(context, playing: false);
      await player.stop();
      expect(player.isPlaying, isFalse);
    });

    testWidgets('starts player in audio system when started', (tester) async {
      mockPlayerState(context);
      await player.start();

      context.audioSystemMock.verifyMediaPlayerStartCalled();

      await player.stop();
    });

    testWidgets('starts only once', (tester) async {
      mockPlayerState(context);
      await player.start();
      await player.start();
      context.audioSystemMock.verifyMediaPlayerStartCalled();

      await player.stop();
    });

    testWidgets('turns off repeat in audio system when started', (tester) async {
      mockPlayerState(context);
      await player.start();

      context.audioSystemMock.verifyMediaPlayerSetRepeatCalledWith(false);

      await player.stop();
    });

    testWidgets('turns on repeat in audio system when started and turned on', (tester) async {
      mockPlayerState(context);
      await player.setRepeat(true);
      context.audioSystemMock.verifyMediaPlayerSetRepeatCalledWith(true);

      await player.start();
      context.audioSystemMock.verifyMediaPlayerSetRepeatCalledWith(true);

      await player.stop();
    });

    testWidgets('prepares playback in audio session when started', (tester) async {
      mockPlayerState(context);
      await player.start();

      context.audioSessionMock.verifyPreparePlaybackCalled();

      await player.stop();
    });

    testWidgets('restarts generator in audio system when started with marker', (tester) async {
      mockPlayerState(context);
      player.markers.positions = [0];
      await player.start();

      context.audioSystemMock.verifyGeneratorStartCalled();
      context.audioSystemMock.verifyGeneratorStopCalled();

      await player.stop();
    });

    testWidgets('does not start generator in audio system when started without markers', (tester) async {
      mockPlayerState(context);
      player.markers.positions = [];
      await player.start();

      context.audioSystemMock.verifyGeneratorStartNeverCalled();

      await player.stop();
    });

    testWidgets('forces screen to stay on when started', (tester) async {
      mockPlayerState(context);
      await player.start();

      context.wakelockMock.verifyEnableCalled();

      await player.stop();
    });

    testWidgets('stops player in audio system when stopped', (tester) async {
      mockPlayerState(context);
      await player.start();

      await player.stop();

      context.audioSystemMock.verifyMediaPlayerStopCalled();
    });

    testWidgets('stops only once', (tester) async {
      mockPlayerState(context);
      await player.start();

      mockPlayerState(context, playing: false);
      await player.stop();
      await player.stop();

      context.audioSystemMock.verifyMediaPlayerStopCalled();
    });

    testWidgets('unregisters interruption listener on stop', (tester) async {
      mockPlayerState(context);
      await player.start();
      await player.stop();

      context.audioSessionMock.verifyUnregisterInterruptionListenerCalled();
    });

    testWidgets('allows screen to turn off when stopped', (tester) async {
      mockPlayerState(context);
      await player.start();

      await player.stop();

      context.wakelockMock.verifyDisableCalled();
    });

    testWidgets('stops generator in audio system when stopped', (tester) async {
      mockPlayerState(context);
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
      mockPlayerState(context);
      context.audioSystemMock.mockMediaPlayerStop(false);
      await player.start();

      await player.stop();

      expect(player.isPlaying, isTrue);
    });
  });
}
