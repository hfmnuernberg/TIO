import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/domain/audio/player.dart';

import '../../utils/test_context.dart';

void main() {
  late TestContext context;
  late Player player;

  setUp(() async {
    resetMocktailState();
    context = TestContext();
    player = Player(context.audioSystem, context.audioSession, context.inMemoryFileSystem, context.wakelock);
  });

  group('Player - RMS Values', () {
    testWidgets('calls audio system with requested nBins', (tester) async {
      context.audioSystemMock.mockMediaPlayerGetRms(Float32List.fromList([1, 2, 3, 4, 5]));

      await player.getRmsValues(5);

      context.audioSystemMock.verifyMediaPlayerGetRmsCalledWith(5);
    });

    testWidgets('returns zeros when all values are identical to avoid divide-by-zero', (tester) async {
      context.audioSystemMock.mockMediaPlayerGetRms(Float32List.fromList([0.5, 0.5, 0.5]));

      final result = await player.getRmsValues(3);

      expect(result.length, 3);
      expect(result, everyElement(0));
    });

    testWidgets('normalizes values linearly to 0 and 1', (tester) async {
      context.audioSystemMock.mockMediaPlayerGetRms(Float32List.fromList([1, 2, 3]));

      final result = await player.getRmsValues(3);

      expect(result.length, 3);
      expect(result, [0.0, 0.5, 1.0]);
    });

    testWidgets('handles negative inputs correctly', (tester) async {
      context.audioSystemMock.mockMediaPlayerGetRms(Float32List.fromList([-3, -2, -1]));

      final result = await player.getRmsValues(3);

      expect(result.length, 3);
      expect(result, [0.0, 0.5, 1.0]);
    });

    testWidgets('returns same number of values as provided by audio system', (tester) async {
      context.audioSystemMock.mockMediaPlayerGetRms(Float32List.fromList([1, 2]));

      final result = await player.getRmsValues(3);

      expect(result.length, 2);
    });
  });
}
