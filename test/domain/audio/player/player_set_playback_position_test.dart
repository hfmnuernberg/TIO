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

  group('Player - Set Playback Position', () {
    testWidgets('clamps playback position between 0 and 1 in audio system', (tester) async {
      await player.setPlaybackPosition(-0.2);
      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(0);

      await player.setPlaybackPosition(0.2);
      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(0.2);

      await player.setPlaybackPosition(1.2);
      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(1);
    });

    testWidgets('notifies seek listeners when setting playback position', (tester) async {
      player.addOnSeekListener(playerHandlerMock.onSeek);

      await player.setPlaybackPosition(0.5);

      playerHandlerMock.verifyOnSeekCalledWith(0.5);
    });

    testWidgets('does not notify seek listeners during periodic playback updates', (tester) async {
      player.addOnPlaybackPositionChangeListener(playerHandlerMock.onPlaybackPositionChange);
      player.addOnSeekListener(playerHandlerMock.onSeek);
      mockPlayerState(context);
      await player.start();
      mockPlayerState(context, playbackPositionFactor: 0.5);

      await tester.pump(const Duration(milliseconds: playbackSamplingIntervalInMs + 1));

      playerHandlerMock.verifyOnPlaybackPositionChangeCalledWith(0.5);
      playerHandlerMock.verifyOnSeekNeverCalled();

      await player.stop();
    });

    testWidgets('notifies both position change and seek listeners when setting playback position', (tester) async {
      player.addOnPlaybackPositionChangeListener(playerHandlerMock.onPlaybackPositionChange);
      player.addOnSeekListener(playerHandlerMock.onSeek);

      await player.setPlaybackPosition(0.3);

      playerHandlerMock.verifyOnPlaybackPositionChangeCalledWith(0.3);
      playerHandlerMock.verifyOnSeekCalledWith(0.3);
    });

    testWidgets('does not notify seek listeners when position is set to same value', (tester) async {
      await player.setPlaybackPosition(0.5);

      player.addOnSeekListener(playerHandlerMock.onSeek);
      await player.setPlaybackPosition(0.5);

      playerHandlerMock.verifyOnSeekNeverCalled();
    });

    testWidgets('does not notify removed seek listener', (tester) async {
      player.addOnSeekListener(playerHandlerMock.onSeek);
      player.removeOnSeekListener(playerHandlerMock.onSeek);

      await player.setPlaybackPosition(0.5);

      playerHandlerMock.verifyOnSeekNeverCalled();
    });

    testWidgets('notifies seek listeners when skipping', (tester) async {
      mockPlayerState(context);
      context.audioSystemMock.mockMediaPlayerLoadWav();
      await player.loadAudioFile('/abs/test.wav');
      player.addOnSeekListener(playerHandlerMock.onSeek);

      await player.skip(seconds: 1);

      playerHandlerMock.verifyOnSeekCalledWith(0.1);
    });
  });
}
