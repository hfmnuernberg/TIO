import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/domain/audio/player.dart';

import '../../../utils/media_player_utils.dart';
import '../../../utils/test_context.dart';

void main() {
  late TestContext context;
  late Player player1;
  late Player player2;

  setUp(() async {
    resetMocktailState();
    context = TestContext();
    player1 = Player(context.audioSystem, context.audioSession, context.inMemoryFileSystem, context.wakelock);
    player2 = Player(context.audioSystem, context.audioSession, context.inMemoryFileSystem, context.wakelock);
  });

  Future<void> loadPlayer(Player p, {required double totalLengthSeconds}) async {
    mockPlayerState(context, totalLengthSeconds: totalLengthSeconds);
    context.audioSystemMock.mockMediaPlayerLoadWav();
    await p.loadAudioFile('/abs/test.wav');
  }

  group('Player - Sync Range', () {
    testWidgets('reports in range when position is within trim end', (tester) async {
      await loadPlayer(player1, totalLengthSeconds: 10);
      await loadPlayer(player2, totalLengthSeconds: 10);

      await player1.setPlaybackPosition(0.5);
      final inRange = await player2.syncPositionWith(player1);

      expect(inRange, isTrue);
    });

    testWidgets('reports out of range when position exceeds trim end and not looping', (tester) async {
      await loadPlayer(player1, totalLengthSeconds: 10);
      await loadPlayer(player2, totalLengthSeconds: 5);
      await player2.setRepeat(false);

      await player1.setPlaybackPosition(0.6);
      final inRange = await player2.syncPositionWith(player1);

      expect(inRange, isFalse);
    });

    testWidgets('reports in range when position exceeds trim end and looping', (tester) async {
      await loadPlayer(player1, totalLengthSeconds: 20);
      await loadPlayer(player2, totalLengthSeconds: 5);
      await player2.setRepeat(true);

      await player1.setPlaybackPosition(0.5);
      final inRange = await player2.syncPositionWith(player1);

      expect(inRange, isTrue);
    });

    testWidgets('reports in range when not loaded', (tester) async {
      await loadPlayer(player1, totalLengthSeconds: 10);

      await player1.setPlaybackPosition(0.5);
      final inRange = await player2.syncPositionWith(player1);

      expect(inRange, isTrue);
    });

    testWidgets('reports in range when durations are zero', (tester) async {
      await loadPlayer(player1, totalLengthSeconds: 0);
      await loadPlayer(player2, totalLengthSeconds: 0);

      final inRange = await player2.syncPositionWith(player1);

      expect(inRange, isTrue);
    });
  });
}
