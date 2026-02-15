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

  group('Player - Load File', () {
    testWidgets('sets successful loaded state on successful file load', (tester) async {
      context.audioSystemMock.mockMediaPlayerLoadWav();
      expect(player.loaded, isFalse);

      await player.loadAudioFile('/abs/test.wav');

      expect(player.loaded, isTrue);
    });

    testWidgets('sets failed loaded state on failed file load', (tester) async {
      context.audioSystemMock.mockMediaPlayerLoadWav();
      await player.loadAudioFile('/abs/test.wav');
      expect(player.loaded, isTrue);

      context.audioSystemMock.mockMediaPlayerLoadWav(false);
      player.loadAudioFile('/abs/fail.wav');
      expect(player.loaded, isFalse);
    });

    testWidgets('sets trim in audio system on successful file load', (tester) async {
      await player.setTrim(0.1, 0.9);
      context.audioSystemMock.mockMediaPlayerLoadWav();

      await player.loadAudioFile('/abs/test.wav');

      context.audioSystemMock.verifyMediaPlayerSetTrimCalledWith(0.1, 0.9);
    });

    testWidgets('sets file duration on successful file load', (tester) async {
      context.audioSystemMock.mockMediaPlayerLoadWav();
      expect(player.fileDuration.inSeconds, 0);

      mockPlayerState(context);
      await player.loadAudioFile('/abs/test.wav');

      expect(player.fileDuration.inSeconds, 10);
    });

    testWidgets('updates playback position on successful file load', (tester) async {
      context.audioSystemMock.mockMediaPlayerLoadWav();
      expect(player.playbackPosition, 0);

      mockPlayerState(context, playbackPositionFactor: 0.1);
      await player.loadAudioFile('/abs/test.wav');

      expect(player.playbackPosition, 0.1);
    });

    testWidgets('does not update playback position on failure', (tester) async {
      mockPlayerState(context, playbackPositionFactor: 0.1);
      await player.setPlaybackPosition(0.1);
      expect(player.playbackPosition, 0.1);
      context.audioSystemMock.mockMediaPlayerLoadWav(false);

      mockPlayerState(context, playbackPositionFactor: 0.2);
      await player.loadAudioFile('/abs/fail.wav');

      expect(player.playbackPosition, 0.1);
    });

    testWidgets('handles midi files correctly', (tester) async {
      final tmpDir = context.inMemoryFileSystem.tmpFolderPath;
      await context.inMemoryFileSystem.createFolder(tmpDir);
      await context.inMemoryFileSystem.saveFileAsBytes('$tmpDir/piano_01.sf2', [0, 1, 2, 3]);

      final result = await player.loadAudioFile('/abs/SomeSong.MID');

      expect(result, isTrue);
      context.audioSystemMock.verifyGetSampleRateCalled();
      context.audioSystemMock.verifyMediaPlayerRenderMidiToWavCalled();
      context.audioSystemMock.verifyMediaPlayerLoadWavCalledWith('rendered.wav');
    });

    testWidgets('returns false when MIDI conversion failed', (tester) async {
      final tmpDir = context.inMemoryFileSystem.tmpFolderPath;
      await context.inMemoryFileSystem.createFolder(tmpDir);
      await context.inMemoryFileSystem.saveFileAsBytes('$tmpDir/piano_01.sf2', [0, 1, 2, 3]);
      context.audioSystemMock.mockMediaPlayerRenderMidiToWav(false);

      final result = await player.loadAudioFile('/abs/file.mid');

      expect(result, isFalse);
    });

    testWidgets('returns false when audio system loadWav fails', (tester) async {
      context.audioSystemMock.mockMediaPlayerLoadWav(false);

      final result = await player.loadAudioFile('/abs/test.wav');

      expect(result, isFalse);
    });
  });
}
