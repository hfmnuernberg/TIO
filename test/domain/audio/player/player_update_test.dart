import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/domain/audio/markers.dart';
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

  group('Player', () {
    testWidgets('updates playing state periodically when changed', (tester) async {
      mockPlayerState(context);
      await player.start();
      mockPlayerState(context, playing: false);
      expect(player.isPlaying, isTrue);

      await tester.pump(const Duration(milliseconds: playbackSamplingIntervalInMs + 1));
      expect(player.isPlaying, isFalse);

      await player.stop();
    });

    testWidgets('does not update playing state when not changed', (tester) async {
      mockPlayerState(context);
      await player.start();
      expect(player.isPlaying, isTrue);

      await tester.pump(const Duration(milliseconds: playbackSamplingIntervalInMs + 1));
      expect(player.isPlaying, isTrue);

      await player.stop();
    });

    testWidgets('updates position state periodically when changed', (tester) async {
      mockPlayerState(context);
      await player.start();
      mockPlayerState(context, playbackPositionFactor: 0.5);
      expect(player.playbackPosition, 0);

      await tester.pump(const Duration(milliseconds: playbackSamplingIntervalInMs + 1));
      expect(player.playbackPosition, 0.5);

      await player.stop();
    });

    testWidgets('does not update position state when not changed', (tester) async {
      mockPlayerState(context);
      await player.start();
      expect(player.playbackPosition, 0);

      await tester.pump(const Duration(milliseconds: playbackSamplingIntervalInMs + 1));
      expect(player.playbackPosition, 0);

      await player.stop();
    });

    testWidgets('notifies about playing updates when changed', (tester) async {
      player = Player(
        context.audioSystem,
        context.audioSession,
        context.inMemoryFileSystem,
        context.wakelock,
        onIsPlayingChange: playerHandlerMock.onIsPlayingChange,
      );
      mockPlayerState(context);
      await player.start();
      playerHandlerMock.verifyOnIsPlayingChangeCalledWith(true);
      mockPlayerState(context, playing: false);

      await tester.pump(const Duration(milliseconds: playbackSamplingIntervalInMs + 1));
      playerHandlerMock.verifyOnIsPlayingChangeCalledWith(false);

      mockPlayerState(context);
      await tester.pump(const Duration(milliseconds: playbackSamplingIntervalInMs + 1));
      playerHandlerMock.verifyOnIsPlayingChangeCalledWith(true);

      await player.stop();
    });

    testWidgets('notifies about position updates', (tester) async {
      player = Player(
        context.audioSystem,
        context.audioSession,
        context.inMemoryFileSystem,
        context.wakelock,
        onPlaybackPositionChange: playerHandlerMock.onPlaybackPositionChange,
      );
      mockPlayerState(context);
      await player.start();
      mockPlayerState(context, playbackPositionFactor: 0.1);

      await tester.pump(const Duration(milliseconds: playbackSamplingIntervalInMs + 1));
      playerHandlerMock.verifyOnPlaybackPositionChangeCalledWith(0.1);

      mockPlayerState(context, playbackPositionFactor: 0.2);
      await tester.pump(const Duration(milliseconds: playbackSamplingIntervalInMs + 1));
      playerHandlerMock.verifyOnPlaybackPositionChangeCalledWith(0.2);

      await player.stop();
    });

    testWidgets('plays a note when marker exists and playback reaches the marker', (tester) async {
      player = Player(
        context.audioSystem,
        context.audioSession,
        context.inMemoryFileSystem,
        context.wakelock,
        onPlaybackPositionChange: playerHandlerMock.onPlaybackPositionChange,
      );
      player.markers.positions = [0.5];
      mockPlayerState(context, looping: true, playbackPositionFactor: 0.4);
      await player.start();

      mockPlayerState(context, playbackPositionFactor: 0.6);
      await tester.pump(const Duration(milliseconds: playbackSamplingIntervalInMs + 1));
      await tester.pump(const Duration(milliseconds: markerSoundDurationInMilliseconds + 1));
      context.audioSystemMock.verifyGeneratorNoteOnCalled();
      context.audioSystemMock.verifyGeneratorNoteOffCalled();

      await player.stop();
    });

    testWidgets('resets markers to play them again when track repeats', (tester) async {
      player = Player(
        context.audioSystem,
        context.audioSession,
        context.inMemoryFileSystem,
        context.wakelock,
        onPlaybackPositionChange: playerHandlerMock.onPlaybackPositionChange,
      );
      player.markers.positions = [0.5];
      mockPlayerState(context, looping: true, playbackPositionFactor: 0.4);
      await player.start();

      mockPlayerState(context, playbackPositionFactor: 0.6);
      await tester.pump(const Duration(milliseconds: playbackSamplingIntervalInMs + 1));
      await tester.pump(const Duration(milliseconds: markerSoundDurationInMilliseconds + 1));
      context.audioSystemMock.verifyGeneratorNoteOnCalled();

      mockPlayerState(context, playbackPositionFactor: 0.4);
      await tester.pump(const Duration(milliseconds: playbackSamplingIntervalInMs + 1));

      mockPlayerState(context, playbackPositionFactor: 0.6);
      await tester.pump(const Duration(milliseconds: playbackSamplingIntervalInMs + 1));
      await tester.pump(const Duration(milliseconds: markerSoundDurationInMilliseconds + 1));
      context.audioSystemMock.verifyGeneratorNoteOnCalled();

      await player.stop();
    });
  });
}
