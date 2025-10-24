import 'dart:typed_data';

import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/domain/audio/recorder.dart';

import '../../../mocks/permission_handler_mock.dart';
import '../../../mocks/recorder_handler_mock.dart';
import '../../../utils/test_context.dart';

void main() {
  late TestContext context;
  late PermissionHandlerMock permissionHandlerMock;
  late RecorderHandlerMock recorderHandlerMock;
  late Recorder recorder;

  setUp(() async {
    resetMocktailState();
    context = TestContext();

    permissionHandlerMock = PermissionHandlerMock()..grant();
    PermissionHandlerPlatform.instance = permissionHandlerMock;
    recorderHandlerMock = RecorderHandlerMock();

    recorder = Recorder(context.audioSystem, context.audioSession, context.wakelock);
  });

  group('Recorder', () {
    testWidgets('stops recorder in audio system when stopped', (tester) async {
      await recorder.start();

      await recorder.stop();

      context.audioSystemMock.verifyMediaPlayerStopRecordingCalled();
    });

    testWidgets('stops only once', (tester) async {
      await recorder.start();

      await recorder.stop();
      await recorder.stop();

      context.audioSystemMock.verifyMediaPlayerStopRecordingCalled();
    });

    testWidgets('notifies about recording change when stopped', (tester) async {
      recorder = Recorder(
        context.audioSystem,
        context.audioSession,
        context.wakelock,
        onIsRecordingChange: recorderHandlerMock.onIsRecordingChange,
      );
      await recorder.start();
      recorderHandlerMock.verifyOnIsRecordingChangeWith(true);

      await recorder.stop();
      recorderHandlerMock.verifyOnIsRecordingChangeWith(false);
    });

    testWidgets('unregisters interruption listener on stop', (tester) async {
      await recorder.start();
      await recorder.stop();

      context.audioSessionMock.verifyUnregisterInterruptionListenerCalled();
    });

    testWidgets('allows screen to turn off when stopped', (tester) async {
      await recorder.start();

      await recorder.stop();

      context.wakelockMock.verifyDisableCalled();
    });

    testWidgets('stops recorder anyways when audio system signals failure', (tester) async {
      await recorder.start();

      expect(recorder.isRecording, isTrue);
      context.audioSystemMock.mockMediaPlayerStopRecording(false);
      await recorder.stop();

      expect(recorder.isRecording, isFalse);
    });

    testWidgets('returns recording samples from audio system', (tester) async {
      final expectedSamples = Float64List.fromList([0.1, 0.2, 0.3]);
      context.audioSystemMock.mockMediaPlayerGetRecordingSamples(expectedSamples);

      final result = await recorder.getRecordingSamples();

      expect(result, expectedSamples);
      context.audioSystemMock.verifyMediaPlayerGetRecordingSamplesCalled();
    });
  });
}
