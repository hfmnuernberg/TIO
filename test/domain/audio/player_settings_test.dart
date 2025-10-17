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

  group('Player - Settings', () {
    testWidgets('sets volume in audio system', (tester) async {
      await player.setVolume(1.2);

      context.audioSystemMock.verifyMediaPlayerSetVolumeCalledWith(1.2);
    });

    testWidgets('can be muted and unmuted', (tester) async {
      expect(player.repeat, isFalse);

      await player.setRepeat(true);
      expect(player.repeat, isTrue);

      await player.setRepeat(false);
      expect(player.repeat, isFalse);
    });

    testWidgets('sets repeat in audio system', (tester) async {
      await player.setRepeat(true);

      context.audioSystemMock.verifyMediaPlayerSetRepeatCalledWith(true);
    });

    testWidgets('sets pitch in audio system', (tester) async {
      await player.setPitch(1.2);

      context.audioSystemMock.verifyMediaPlayerSetPitchCalledWith(1.2);
    });

    testWidgets('sets speed in audio system', (tester) async {
      await player.setSpeed(1.2);

      context.audioSystemMock.verifyMediaPlayerSetSpeedCalledWith(1.2);
    });

    testWidgets('sets playback position in audio system clamped between 0 and 1', (tester) async {
      await player.setPlaybackPosition(-0.2);
      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(0);

      await player.setPlaybackPosition(0.2);
      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(0.2);

      await player.setPlaybackPosition(1.2);
      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(1);
    });

    testWidgets('does not set trim in audio system when no file loaded', (tester) async {
      await player.setTrim(0.1, 0.9);

      context.audioSystemMock.verifyMediaPlayerSetTrimNeverCalled();
    });

    testWidgets('sets trim in audio system when file loaded', (tester) async {
      mockPlayerState();
      context.audioSystemMock.mockMediaPlayerLoadWav();
      await player.loadAudioFile('/abs/test.wav');

      await player.setTrim(0.1, 0.9);

      context.audioSystemMock.verifyMediaPlayerSetTrimCalledWith(0.1, 0.9);
    });
  });
}
