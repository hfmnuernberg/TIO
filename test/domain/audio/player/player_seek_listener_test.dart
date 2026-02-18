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

  group('Player - Seek Listener', () {
    testWidgets('notifies seek listener when playback position is set explicitly', (tester) async {
      player.addOnSeekListener(playerHandlerMock.onSeek);

      await player.setPlaybackPosition(0.5);

      playerHandlerMock.verifyOnSeekCalledWith(0.5);
    });

    testWidgets('does not notify seek listener during periodic updates', (tester) async {
      player = Player(
        context.audioSystem,
        context.audioSession,
        context.inMemoryFileSystem,
        context.wakelock,
        onPlaybackPositionChange: playerHandlerMock.onPlaybackPositionChange,
      );
      player.addOnSeekListener(playerHandlerMock.onSeek);
      mockPlayerState(context);
      await player.start();
      mockPlayerState(context, playbackPositionFactor: 0.5);

      await tester.pump(const Duration(milliseconds: playbackSamplingIntervalInMs + 1));

      playerHandlerMock.verifyOnPlaybackPositionChangeCalledWith(0.5);
      playerHandlerMock.verifyOnSeekNeverCalled();

      await player.stop();
    });

    testWidgets('notifies both position change and seek listeners on explicit seek', (tester) async {
      player.addOnPlaybackPositionChangeListener(playerHandlerMock.onPlaybackPositionChange);
      player.addOnSeekListener(playerHandlerMock.onSeek);

      await player.setPlaybackPosition(0.3);

      playerHandlerMock.verifyOnPlaybackPositionChangeCalledWith(0.3);
      playerHandlerMock.verifyOnSeekCalledWith(0.3);
    });

    testWidgets('does not notify seek listener when position is unchanged', (tester) async {
      await player.setPlaybackPosition(0.5);

      player.addOnSeekListener(playerHandlerMock.onSeek);
      await player.setPlaybackPosition(0.5);

      playerHandlerMock.verifyOnSeekNeverCalled();
    });

    testWidgets('removed seek listener is not notified', (tester) async {
      player.addOnSeekListener(playerHandlerMock.onSeek);
      player.removeOnSeekListener(playerHandlerMock.onSeek);

      await player.setPlaybackPosition(0.5);

      playerHandlerMock.verifyOnSeekNeverCalled();
    });

    testWidgets('skip fires seek listener', (tester) async {
      mockPlayerState(context);
      context.audioSystemMock.mockMediaPlayerLoadWav();
      await player.loadAudioFile('/abs/test.wav');
      player.addOnSeekListener(playerHandlerMock.onSeek);

      await player.skip(seconds: 1);

      playerHandlerMock.verifyOnSeekCalledWith(0.1);
    });
  });
}
