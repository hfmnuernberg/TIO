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

  group('Player - Dispose', () {
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
  });
}
