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

  group('Player - Skip', () {
    testWidgets('does nothing when state is null', (tester) async {
      await player.skip(seconds: 1);

      context.audioSystemMock.verifyMediaPlayerSetTrimNeverCalled();
    });

    testWidgets('skips forward', (tester) async {
      mockPlayerState(totalLengthSeconds: 10);
      context.audioSystemMock.mockMediaPlayerLoadWav();
      await player.loadAudioFile('/abs/test.wav');

      await player.skip(seconds: 1);

      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(0.1);
    });

    testWidgets('skips backward', (tester) async {
      mockPlayerState(playbackPositionFactor: 1, totalLengthSeconds: 10);
      context.audioSystemMock.mockMediaPlayerLoadWav();
      await player.loadAudioFile('/abs/test.wav');

      await player.skip(seconds: -1);

      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(0.9);
    });

    testWidgets('uses fallback when file duration is zero', (tester) async {
      mockPlayerState(playbackPositionFactor: 0.1, totalLengthSeconds: 0);
      context.audioSystemMock.mockMediaPlayerLoadWav();
      await player.loadAudioFile('/abs/zero.wav');

      await player.skip(seconds: 2);

      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(1);
    });

    testWidgets('clamps when overshooting end', (tester) async {
      mockPlayerState(playbackPositionFactor: 0.9, totalLengthSeconds: 10);
      context.audioSystemMock.mockMediaPlayerLoadWav();
      await player.loadAudioFile('/abs/test.wav');

      await player.skip(seconds: 2);

      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(1);
    });

    testWidgets('clamps when overshooting start', (tester) async {
      mockPlayerState(playbackPositionFactor: 0.1, totalLengthSeconds: 10);
      context.audioSystemMock.mockMediaPlayerLoadWav();
      await player.loadAudioFile('/abs/test.wav');

      await player.skip(seconds: -2);

      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(0);
    });
  });
}
