import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/domain/audio/player.dart';
import 'package:tiomusic/src/rust/api/modules/media_player.dart';

import '../../mocks/audio_player_handler_mock.dart';
import '../../utils/test_context.dart';

void main() {
  late TestContext context;
  late AudioPlayerHandlerMock audioPlayerHandlerMock;
  late Player player;

  setUp(() async {
    resetMocktailState();
    context = TestContext();
    audioPlayerHandlerMock = AudioPlayerHandlerMock();
    player = Player(
      context.audioSystem,
      context.audioSession,
      context.inMemoryFileSystem,
      context.wakelock,
      onIsPlayingChange: audioPlayerHandlerMock.onIsPlayingChange,
      onPlaybackPositionChange: audioPlayerHandlerMock.onPlaybackPositionChange,
    );
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
    testWidgets('notifies about playing updates', (tester) async {
      mockPlayerState();
      await player.start();

      audioPlayerHandlerMock.verifyOnPlayingChangeCalled(true);

      await player.stop();
    });

    testWidgets('does not notify about playing updates when no callback is provided', (tester) async {
      player = Player(context.audioSystem, context.audioSession, context.inMemoryFileSystem, context.wakelock);
      mockPlayerState();
      await player.start();

      audioPlayerHandlerMock.verifyOnPlayingChangeNeverCalled();

      await player.stop();
    });

    testWidgets('notifies about position updates', (tester) async {
      mockPlayerState();
      await player.start();
      await tester.pump();

      mockPlayerState(playbackPositionFactor: 0.5);

      await player.setPlaybackPosition(0.5);
      audioPlayerHandlerMock.verifyOnPlaybackPositionChangeCalled(0.5);

      await player.stop();
    });

    testWidgets('does not notify about position updates when no callback is provided', (tester) async {
      player = Player(context.audioSystem, context.audioSession, context.inMemoryFileSystem, context.wakelock);
      mockPlayerState();
      await player.start();
      await tester.pump();

      mockPlayerState(playbackPositionFactor: 0.5);

      await player.setPlaybackPosition(0.5);
      audioPlayerHandlerMock.verifyOnPlaybackPositionChangeNeverCalled();

      await player.stop();
    });
  });
}
