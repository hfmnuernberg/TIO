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

  group('Player - Reload File', () {
    testWidgets('invalidates the decoded audio for the given file before loading', (tester) async {
      context.audioSystemMock.mockMediaPlayerLoadWav();

      await player.reloadAudioFile('/abs/test.wav');

      verifyInOrder([
        () => context.audioSystemMock.mediaPlayerInvalidateWavCache(
          wavFilePath: '/abs/test.wav',
          cacheDir: context.inMemoryFileSystem.tmpFolderPath,
        ),
        () => context.audioSystemMock.mediaPlayerLoadWav(
          id: any(named: 'id'),
          wavFilePath: '/abs/test.wav',
          cacheDir: context.inMemoryFileSystem.tmpFolderPath,
        ),
      ]);
    });

    testWidgets('sets successful loaded state on successful reload', (tester) async {
      context.audioSystemMock.mockMediaPlayerLoadWav();
      expect(player.loaded, isFalse);

      await player.reloadAudioFile('/abs/test.wav');

      expect(player.loaded, isTrue);
    });

    testWidgets('returns true on successful reload', (tester) async {
      context.audioSystemMock.mockMediaPlayerLoadWav();

      final result = await player.reloadAudioFile('/abs/test.wav');

      expect(result, isTrue);
    });

    testWidgets('returns false on failed reload', (tester) async {
      context.audioSystemMock.mockMediaPlayerLoadWav(false);

      final result = await player.reloadAudioFile('/abs/test.wav');

      expect(result, isFalse);
    });

    testWidgets('still invalidates when the subsequent load fails', (tester) async {
      context.audioSystemMock.mockMediaPlayerLoadWav(false);

      await player.reloadAudioFile('/abs/test.wav');

      context.audioSystemMock.verifyMediaPlayerInvalidateWavCacheCalledWith(RegExp(r'^/abs/test\.wav$'));
    });

    testWidgets('updates file duration on successful reload', (tester) async {
      context.audioSystemMock.mockMediaPlayerLoadWav();
      mockPlayerState(context);

      await player.reloadAudioFile('/abs/test.wav');

      expect(player.fileDuration.inSeconds, 10);
    });
  });
}
