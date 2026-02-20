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

  Future<void> loadPlayer(Player p, {required double totalLengthSeconds, bool playing = false}) async {
    mockPlayerState(context, totalLengthSeconds: totalLengthSeconds, playing: playing);
    context.audioSystemMock.mockMediaPlayerLoadWav();
    await p.loadAudioFile('/abs/test.wav');
  }

  group('Player - Sync', () {
    testWidgets('syncs position with same duration and no trim', (tester) async {
      await loadPlayer(player1, totalLengthSeconds: 10);
      await loadPlayer(player2, totalLengthSeconds: 10);

      await player2.syncPositionWith(player1, 0.5);

      expect(player2.playbackPosition, 0.5);
    });

    testWidgets('maps position considering different file durations', (tester) async {
      await loadPlayer(player1, totalLengthSeconds: 20);
      await loadPlayer(player2, totalLengthSeconds: 10);

      await player2.syncPositionWith(player1, 0.25);

      expect(player2.playbackPosition, 0.5);
    });

    testWidgets('maps position considering trim start of other player', (tester) async {
      await loadPlayer(player1, totalLengthSeconds: 10);
      await player1.setTrim(0.2, 1);
      await loadPlayer(player2, totalLengthSeconds: 10);

      await player2.syncPositionWith(player1, 0.5);

      expect(player2.playbackPosition, 0.3);
    });

    testWidgets('maps position considering trim start of this player', (tester) async {
      await loadPlayer(player1, totalLengthSeconds: 10);
      await loadPlayer(player2, totalLengthSeconds: 10);
      await player2.setTrim(0.1, 1);

      await player2.syncPositionWith(player1, 0.5);

      expect(player2.playbackPosition, 0.6);
    });

    testWidgets('maps position considering trim start of both players', (tester) async {
      await loadPlayer(player1, totalLengthSeconds: 10);
      await player1.setTrim(0.2, 1);
      await loadPlayer(player2, totalLengthSeconds: 10);
      await player2.setTrim(0.1, 1);

      await player2.syncPositionWith(player1, 0.5);

      expect(player2.playbackPosition, 0.4);
    });

    testWidgets('stops playback when not looping and position exceeds trim end', (tester) async {
      await loadPlayer(player1, totalLengthSeconds: 10);
      await loadPlayer(player2, totalLengthSeconds: 5);
      await player2.setTrim(0, 0.8);
      await player2.setRepeat(false);
      mockPlayerState(context, playbackPositionFactor: 0.3);
      await player2.start();
      expect(player2.playbackPosition, 0.3);

      await player2.syncPositionWith(player1, 0.5);

      context.audioSystemMock.verifyMediaPlayerStopCalled();
      expect(player2.playbackPosition, 0.3);
    });

    testWidgets('does not stop when not looping, not playing, and position exceeds trim end', (tester) async {
      await loadPlayer(player1, totalLengthSeconds: 10);
      await loadPlayer(player2, totalLengthSeconds: 5);
      await player2.setTrim(0, 0.8);
      await player2.setRepeat(false);
      mockPlayerState(context, playbackPositionFactor: 0.3);
      await player2.start();
      mockPlayerState(context, playing: false, playbackPositionFactor: 0.3);
      await player2.stop();
      context.audioSystemMock.verifyMediaPlayerStopCalled();
      expect(player2.playbackPosition, 0.3);

      await player2.syncPositionWith(player1, 0.5);

      context.audioSystemMock.verifyMediaPlayerStopNeverCalled();
      expect(player2.playbackPosition, 0.3);
    });

    testWidgets('wraps position when looping and position exceeds trim end', (tester) async {
      await loadPlayer(player1, totalLengthSeconds: 20);
      await loadPlayer(player2, totalLengthSeconds: 5);
      await player2.setRepeat(true);

      await player2.syncPositionWith(player1, 0.5);

      expect(player2.playbackPosition, 0);
    });

    testWidgets('wraps position with remainder when looping', (tester) async {
      await loadPlayer(player1, totalLengthSeconds: 20);
      await loadPlayer(player2, totalLengthSeconds: 6);
      await player2.setRepeat(true);

      await player2.syncPositionWith(player1, 0.5);

      expect(player2.playbackPosition, closeTo(4 / 6, 0.001));
    });

    testWidgets('wraps position when looping with trim', (tester) async {
      await loadPlayer(player1, totalLengthSeconds: 10);
      await loadPlayer(player2, totalLengthSeconds: 10);
      await player2.setTrim(0.2, 0.6);
      await player2.setRepeat(true);

      await player2.syncPositionWith(player1, 0.8);

      expect(player2.playbackPosition, closeTo(0.2, 0.001));
    });

    testWidgets('does nothing when not loaded', (tester) async {
      await loadPlayer(player1, totalLengthSeconds: 10);

      await player2.syncPositionWith(player1, 0.5);

      expect(player2.playbackPosition, 0);
    });

    testWidgets('does nothing when other player has zero duration', (tester) async {
      await loadPlayer(player1, totalLengthSeconds: 0);
      await loadPlayer(player2, totalLengthSeconds: 10);

      await player2.syncPositionWith(player1, 0.5);

      expect(player2.playbackPosition, 0);
    });

    testWidgets('does nothing when this player has zero duration', (tester) async {
      await loadPlayer(player1, totalLengthSeconds: 10);
      await loadPlayer(player2, totalLengthSeconds: 0);

      await player2.syncPositionWith(player1, 0.5);

      expect(player2.playbackPosition, 0);
    });

    testWidgets('clamps negative mapped position to zero', (tester) async {
      await loadPlayer(player1, totalLengthSeconds: 10);
      await player1.setTrim(0.5, 1);
      await loadPlayer(player2, totalLengthSeconds: 10);

      await player2.syncPositionWith(player1, 0.2);

      expect(player2.playbackPosition, 0);
    });
  });
}
