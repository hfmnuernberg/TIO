import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/domain/metronome/metronome.dart';
import 'package:tiomusic/models/note_handler.dart';

import '../../utils/test_context.dart';

void main() {
  late TestContext context;
  late Metronome metronome;

  setUp(() async {
    resetMocktailState();
    await NoteHandler.createNoteBeatLengthMap();
    context = TestContext();
    metronome = Metronome(context.audioSystem, context.audioSession, context.inMemoryFileSystem, context.wakelock);
  });

  group('Metronome', () {
    testWidgets('starts and stops', (tester) async {
      expect(metronome.isOn, isFalse);

      await metronome.start();
      expect(metronome.isOn, isTrue);

      await metronome.stop();
      expect(metronome.isOn, isFalse);
    });

    testWidgets('starts metronome in audio system when started', (tester) async {
      await metronome.start();

      context.audioSystemMock.verifyMetronomeStartCalled();

      await metronome.stop();
    });

    testWidgets('starts only once', (tester) async {
      await metronome.start();
      await metronome.start();
      context.audioSystemMock.verifyMetronomeStartCalled();

      await metronome.stop();
    });

    testWidgets('prepares playback in audio session when started', (tester) async {
      await metronome.start();

      context.audioSessionMock.verifyPreparePlaybackCalled();

      await metronome.stop();
    });

    testWidgets('forces screen to stay on when started', (tester) async {
      await metronome.start();

      context.wakelockMock.verifyEnableCalled();

      await metronome.stop();
    });

    testWidgets('stops metronome in audio system when stopped', (tester) async {
      await metronome.start();

      await metronome.stop();

      context.audioSystemMock.verifyMetronomeStopCalled();
    });

    testWidgets('stops only once', (tester) async {
      await metronome.start();

      await metronome.stop();
      await metronome.stop();

      context.audioSystemMock.verifyMetronomeStartCalled();
    });

    testWidgets('allows screen to turn off when stopped', (tester) async {
      await metronome.start();

      await metronome.stop();

      context.wakelockMock.verifyDisableCalled();
    });

    testWidgets('restarts', (tester) async {
      await metronome.start();
      context.audioSystemMock.verifyMetronomeStartCalled();

      await metronome.restart();

      expect(metronome.isOn, isTrue);
      context.audioSystemMock.verifyMetronomeStopCalled();
      context.audioSystemMock.verifyMetronomeStartCalled();

      await metronome.stop();
    });

    testWidgets('fails to start metronome when audio system signals failure', (tester) async {
      context.audioSystemMock.mockMetronomeStart(false);

      await metronome.start();

      expect(metronome.isOn, isFalse);
    });

    testWidgets('fails to stop metronome when audio system signals failure', (tester) async {
      context.audioSystemMock.mockMetronomeStop(false);
      await metronome.start();

      await metronome.stop();

      expect(metronome.isOn, isTrue);
    });
  });
}
