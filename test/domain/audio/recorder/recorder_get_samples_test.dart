import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/domain/audio/recorder.dart';

import '../../../utils/test_context.dart';

void main() {
  late TestContext context;
  late Recorder recorder;

  setUp(() async {
    resetMocktailState();
    context = TestContext();
    recorder = Recorder(context.audioSystem, context.audioSession, context.wakelock);
  });

  group('Recorder', () {
    testWidgets('returns recording samples from audio system', (tester) async {
      final expectedSamples = Float64List.fromList([0.1, 0.2, 0.3]);
      context.audioSystemMock.mockMediaPlayerGetRecordingSamples(expectedSamples);

      final result = await recorder.getRecordingSamples();

      expect(result, expectedSamples);
      context.audioSystemMock.verifyMediaPlayerGetRecordingSamplesCalled();
    });
  });
}
