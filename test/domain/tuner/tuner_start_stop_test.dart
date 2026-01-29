import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:tiomusic/domain/tuner/tuner.dart';

import '../../mocks/permission_handler_mock.dart';
import '../../mocks/tuner_handler_mock.dart';
import '../../utils/test_context.dart';

void main() {
  late TestContext context;
  late PermissionHandlerMock permissionHandlerMock;
  late TunerHandlerMock tunerHandlerMock;
  late Tuner tuner;

  setUp(() async {
    resetMocktailState();
    context = TestContext();

    permissionHandlerMock = PermissionHandlerMock()..grant();
    PermissionHandlerPlatform.instance = permissionHandlerMock;
    tunerHandlerMock = TunerHandlerMock();

    tuner = Tuner(context.audioSystem, context.audioSession, context.wakelock);
  });

  tearDown(() async {
    await tuner.dispose();
  });

  group('Tuner', () {
    testWidgets('starts and stops', (tester) async {
      expect(tuner.isRunning, isFalse);

      await tuner.start();
      expect(tuner.isRunning, isTrue);

      await tuner.stop();
      expect(tuner.isRunning, isFalse);
    });

    testWidgets('starts only once', (tester) async {
      await tuner.start();
      await tuner.start();

      context.audioSystemMock.verifyTunerStartCalled();

      await tuner.stop();
    });

    testWidgets('prepares recording in audio session when started', (tester) async {
      await tuner.start();

      context.audioSessionMock.verifyPrepareRecordingCalled();

      await tuner.stop();
    });

    testWidgets('notifies about running change when started and stopped', (tester) async {
      tuner = Tuner(
        context.audioSystem,
        context.audioSession,
        context.wakelock,
        onRunningChange: tunerHandlerMock.onRunningChange,
      );
      await tuner.start();

      tunerHandlerMock.verifyOnRunningChangeCalledWith(true);

      await tuner.stop();
    });

    testWidgets('emits a frequency after start and emits null on stop', (tester) async {
      tuner = Tuner(
        context.audioSystem,
        context.audioSession,
        context.wakelock,
        onFrequencyChange: tunerHandlerMock.onFrequencyChange,
      );
      context.audioSystemMock.mockTunerGetFrequency(440);

      await tuner.start();
      tunerHandlerMock.verifyOnFrequencyChangeCalledWith(440);

      await tuner.stop();
    });

    testWidgets('registers and unregisters interruption listener', (tester) async {
      await tuner.start();
      context.audioSessionMock.verifyRegisterInterruptionListenerCalled();

      await tuner.stop();
      context.audioSessionMock.verifyUnregisterInterruptionListenerCalled();
    });

    testWidgets('stops only once', (tester) async {
      await tuner.start();

      await tuner.stop();
      await tuner.stop();

      context.audioSystemMock.verifyTunerStopCalled();
    });

    testWidgets('starts tuner in audio system when started', (tester) async {
      await tuner.start();

      context.audioSystemMock.verifyTunerStartCalled();

      await tuner.stop();
    });

    testWidgets('forces screen to stay on when started', (tester) async {
      await tuner.start();

      context.wakelockMock.verifyEnableCalled();

      await tuner.stop();
    });

    testWidgets('stops tuner in audio system when stopped', (tester) async {
      await tuner.start();

      await tuner.stop();

      context.audioSystemMock.verifyTunerStopCalled();
    });

    testWidgets('disables wakelock when stopped', (tester) async {
      await tuner.start();

      await tuner.stop();

      context.wakelockMock.verifyDisableCalled();
    });

    testWidgets('fails to start when microphone permission not granted', (tester) async {
      permissionHandlerMock.deny();

      await tuner.start();

      expect(tuner.isRunning, isFalse);

      context.audioSystemMock.verifyTunerStartNeverCalled();
    });

    testWidgets('fails to start when audio system signals failure', (tester) async {
      context.audioSystemMock.mockTunerStart(false);

      await tuner.start();

      expect(tuner.isRunning, isFalse);
    });

    testWidgets('prepares playback and starts generator', (tester) async {
      await tuner.startGenerator();

      context.audioSessionMock.verifyPreparePlaybackCalled();
      context.audioSystemMock.verifyGeneratorStartCalled();
    });

    testWidgets('stops generator by sending noteOff before stop', (tester) async {
      final stopFuture = tuner.stopGenerator();
      context.audioSystemMock.verifyGeneratorNoteOffCalled();

      await tester.pump(const Duration(milliseconds: 80));
      await stopFuture;

      context.audioSystemMock.verifyGeneratorStopCalled();
    });

    testWidgets('calls generatorNoteOn with correct frequency', (tester) async {
      await tuner.generatorNoteOn(frequency: 440);

      context.audioSystemMock.verifyGeneratorNoteOnCalledWith(440);
    });

    testWidgets('calls generatorNoteOff', (tester) async {
      await tuner.generatorNoteOff();

      context.audioSystemMock.verifyGeneratorNoteOffCalled();
    });
  });
}
