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
    player = Player(context.audioSystem, context.audioSession, context.inMemoryFileSystem, context.wakelock);
  });

  group('Player - Skip', () {
    testWidgets('does nothing when state is null', (tester) async {
      await player.skip(seconds: 1);

      context.audioSystemMock.verifyMediaPlayerSetTrimNeverCalled();
    });

    testWidgets('skips forward', (tester) async {
      mockPlayerState(context);
      context.audioSystemMock.mockMediaPlayerLoadWav();
      await player.loadAudioFile('/abs/test.wav');

      await player.skip(seconds: 1);

      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(0.1);
    });

    testWidgets('skips backward', (tester) async {
      mockPlayerState(context, playbackPositionFactor: 1);
      context.audioSystemMock.mockMediaPlayerLoadWav();
      await player.loadAudioFile('/abs/test.wav');

      await player.skip(seconds: -1);

      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(0.9);
    });

    testWidgets('uses fallback when file duration is zero', (tester) async {
      mockPlayerState(context, playbackPositionFactor: 0.1, totalLengthSeconds: 0);
      context.audioSystemMock.mockMediaPlayerLoadWav();
      await player.loadAudioFile('/abs/zero.wav');

      await player.skip(seconds: 2);

      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(1);
    });

    testWidgets('clamps when overshooting end', (tester) async {
      mockPlayerState(context, playbackPositionFactor: 0.9);
      context.audioSystemMock.mockMediaPlayerLoadWav();
      await player.loadAudioFile('/abs/test.wav');

      await player.skip(seconds: 2);

      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(1);
    });

    testWidgets('clamps when overshooting start', (tester) async {
      mockPlayerState(context, playbackPositionFactor: 0.1);
      context.audioSystemMock.mockMediaPlayerLoadWav();
      await player.loadAudioFile('/abs/test.wav');

      await player.skip(seconds: -2);

      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(0);
    });
  });
}
