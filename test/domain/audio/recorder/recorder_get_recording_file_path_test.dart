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
    recorder = Recorder(context.audioSystem, context.audioSession, context.inMemoryFileSystem, context.wakelock);
  });

  group('Recorder', () {
    testWidgets('returns recording file path from audio system', (tester) async {
      const expectedPath = '/tmp/recording_123.wav';
      context.audioSystemMock.mockMediaPlayerGetRecordingFilePath(expectedPath);

      final result = await recorder.getRecordingFilePath();

      expect(result, expectedPath);
      context.audioSystemMock.verifyMediaPlayerGetRecordingFilePathCalled();
    });
  });
}
