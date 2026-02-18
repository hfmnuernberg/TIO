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

  group('Player - Lifecycle', () {
    testWidgets('stops playback and destroys audio system instance', (tester) async {
      mockPlayerState(context);
      await player.start();

      await player.dispose();

      context.audioSystemMock.verifyMediaPlayerStopCalled();
      context.audioSystemMock.verifyMediaPlayerDestroyInstanceCalled();
    });

    testWidgets('destroys audio system instance when not playing', (tester) async {
      await player.dispose();

      context.audioSystemMock.verifyMediaPlayerDestroyInstanceCalled();
    });

    testWidgets('resets loaded state after dispose', (tester) async {
      mockPlayerState(context);
      context.audioSystemMock.mockMediaPlayerLoadWav();
      await player.loadAudioFile('/abs/test.wav');
      expect(player.loaded, isTrue);

      await player.dispose();

      expect(player.loaded, isFalse);
    });

    testWidgets('routes audio system calls to its own instance', (tester) async {
      mockPlayerState(context);
      final player2 = Player(context.audioSystem, context.audioSession, context.inMemoryFileSystem, context.wakelock);

      await player.start();
      await player2.start();

      context.audioSystemMock.verifyMediaPlayerStartCalledWithId(player.id);
      context.audioSystemMock.verifyMediaPlayerStartCalledWithId(player2.id);
      context.audioSystemMock.verifyMediaPlayerStartNeverCalled();

      await player.stop();
      await player2.stop();
    });
  });
}
