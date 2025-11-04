import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/domain/piano/piano.dart';

import '../../utils/test_context.dart';

void main() {
  late TestContext context;
  late Piano piano;

  setUp(() async {
    resetMocktailState();
    Piano.reset();
    context = TestContext();
    piano = Piano(context.audioSystem, context.audioSession, context.inMemoryFileSystem);
  });

  tearDown(() async {
    if (piano.isPlaying) await piano.stop();
    Piano.reset();
  });

  group('Piano', () {
    testWidgets('starts and stops', (tester) async {
      expect(piano.isPlaying, isFalse);

      await piano.start();
      expect(piano.isPlaying, isTrue);

      await piano.stop();
      expect(piano.isPlaying, isFalse);
    });

    testWidgets('starts piano in audio system when started', (tester) async {
      await piano.start();

      context.audioSystemMock.verifyPianoStartCalled();

      await piano.stop();
    });

    testWidgets('starts only once', (tester) async {
      await piano.start();
      await piano.start();
      context.audioSystemMock.verifyPianoStartCalled();

      await piano.stop();
    });

    testWidgets('prepares playback in audio session when started', (tester) async {
      await piano.start();

      context.audioSessionMock.verifyPreparePlaybackCalled();

      await piano.stop();
    });

    testWidgets('stops piano in audio system when stopped', (tester) async {
      await piano.start();

      await piano.stop();

      context.audioSystemMock.verifyPianoStopCalled();
    });

    testWidgets('stops only once', (tester) async {
      await piano.start();

      await piano.stop();
      await piano.stop();

      context.audioSystemMock.verifyPianoStartCalled();
    });

    testWidgets('restarts', (tester) async {
      await piano.start();
      context.audioSystemMock.verifyPianoStartCalled();

      await piano.restart();

      expect(piano.isPlaying, isTrue);
      context.audioSystemMock.verifyPianoStopCalled();
      context.audioSystemMock.verifyPianoStartCalled();

      await piano.stop();
    });

    testWidgets('fails to start piano when audio system signals failure', (tester) async {
      context.audioSystemMock.mockPianoStart(false);

      await piano.start();

      expect(piano.isPlaying, isFalse);
    });

    testWidgets('fails to stop piano when audio system signals failure', (tester) async {
      context.audioSystemMock.mockPianoStop(false);
      await piano.start();

      await piano.stop();

      expect(piano.isPlaying, isTrue);
    });
  });
}
