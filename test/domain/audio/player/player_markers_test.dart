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

  group('Player - Markers', () {
    testWidgets('starts generator when playback begins with markers', (tester) async {
      mockPlayerState(context);
      player.markers.positions = [0];
      await player.start();

      context.audioSystemMock.verifyGeneratorStartCalled();
      context.audioSystemMock.verifyGeneratorStopCalled();

      await player.stop();
    });

    testWidgets('does not start generator when playback begins without markers', (tester) async {
      mockPlayerState(context);
      player.markers.positions = [];
      await player.start();

      context.audioSystemMock.verifyGeneratorStartNeverCalled();

      await player.stop();
    });

    testWidgets('stops generator when playback stops', (tester) async {
      mockPlayerState(context);
      player.markers.positions = [0];
      await player.start();
      context.audioSystemMock.verifyGeneratorStopCalled();

      await player.stop();

      context.audioSystemMock.verifyGeneratorStopCalled();
    });

    testWidgets('plays sound when playback crosses a marker', (tester) async {
      player.addOnPlaybackPositionChangeListener(playerHandlerMock.onPlaybackPositionChange);
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

    testWidgets('replays markers after track loops back', (tester) async {
      player.addOnPlaybackPositionChangeListener(playerHandlerMock.onPlaybackPositionChange);
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

    testWidgets('does nothing when skipping to marker with empty list', (tester) async {
      mockPlayerState(context);
      context.audioSystemMock.mockMediaPlayerLoadWav();
      await player.loadAudioFile('/abs/test.wav');

      await player.skipToMarker(forward: true);

      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionNeverCalled();
    });

    testWidgets('skips forward to next marker', (tester) async {
      mockPlayerState(context);
      context.audioSystemMock.mockMediaPlayerLoadWav();
      await player.loadAudioFile('/abs/test.wav');
      player.markers.positions = [0.3, 0.7];

      await player.skipToMarker(forward: true);
      await tester.pump(const Duration(milliseconds: markerSoundDurationInMilliseconds + 1));

      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(0.3);
    });

    testWidgets('skips forward to end when past all markers', (tester) async {
      mockPlayerState(context, playbackPositionFactor: 0.8);
      context.audioSystemMock.mockMediaPlayerLoadWav();
      await player.loadAudioFile('/abs/test.wav');
      player.markers.positions = [0.3, 0.7];

      await player.skipToMarker(forward: true);
      await tester.pump(const Duration(milliseconds: markerSoundDurationInMilliseconds + 1));

      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(1);
    });

    testWidgets('skips backward to previous marker', (tester) async {
      mockPlayerState(context, playbackPositionFactor: 0.5);
      context.audioSystemMock.mockMediaPlayerLoadWav();
      await player.loadAudioFile('/abs/test.wav');
      player.markers.positions = [0.3, 0.7];

      await player.skipToMarker(forward: false);

      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(0.3);
    });

    testWidgets('skips backward to start when before first marker', (tester) async {
      mockPlayerState(context, playbackPositionFactor: 0.1);
      context.audioSystemMock.mockMediaPlayerLoadWav();
      await player.loadAudioFile('/abs/test.wav');
      player.markers.positions = [0.3, 0.7];

      await player.skipToMarker(forward: false);

      context.audioSystemMock.verifyMediaPlayerSetPlaybackPositionCalledWith(0);
    });
  });
}
