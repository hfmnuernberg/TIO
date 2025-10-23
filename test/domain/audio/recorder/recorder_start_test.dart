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
    testWidgets('starts and stops', (tester) async {
      expect(recorder.isRecording, isFalse);

      await recorder.start();
      expect(recorder.isRecording, isTrue);

      await recorder.stop();
      expect(recorder.isRecording, isFalse);
    });

    testWidgets('starts recorder in audio system when started', (tester) async {
      await recorder.start();

      context.audioSystemMock.verifyMediaPlayerStartRecordingCalled();

      await recorder.stop();
    });

    testWidgets('starts only once', (tester) async {
      await recorder.start();
      await recorder.start();

      context.audioSystemMock.verifyMediaPlayerStartRecordingCalled();

      await recorder.stop();
    });

    testWidgets('prepares recording in audio session when started', (tester) async {
      await recorder.start();

      context.audioSessionMock.verifyPrepareRecordingCalled();

      await recorder.stop();
    });

    testWidgets('notifies about recording change when started', (tester) async {
      recorder = Recorder(
        context.audioSystem,
        context.audioSession,
        context.wakelock,
        onIsRecordingChange: recorderHandlerMock.onIsRecordingChange,
      );
      await recorder.start();

      recorderHandlerMock.verifyOnIsRecordingChangeWith(true);

      await recorder.stop();
    });

    testWidgets('updates recording length periodically when started', (tester) async {
      expect(recorder.recordingLength, Duration());
      await recorder.start();

      await tester.pump(const Duration(milliseconds: 1000 + 1));
      expect(recorder.recordingLength, Duration(seconds: 1));

      await recorder.stop();
    });

    testWidgets('notifies about recording length updates periodically when started', (tester) async {
      recorder = Recorder(
        context.audioSystem,
        context.audioSession,
        context.wakelock,
        onRecordingLengthChange: recorderHandlerMock.onRecordingLengthChange,
      );
      await recorder.start();
      recorderHandlerMock.verifyOnRecordingLengthChangeCalledWith(Duration());

      await tester.pump(const Duration(milliseconds: 1000 + 1));
      recorderHandlerMock.verifyOnRecordingLengthChangeCalledWith(Duration(seconds: 1));

      await recorder.stop();
    });

    testWidgets('forces screen to stay on when started', (tester) async {
      await recorder.start();

      context.wakelockMock.verifyEnableCalled();

      await recorder.stop();
    });

    testWidgets('fails to start recorder when audio system signals failure', (tester) async {
      context.audioSystemMock.mockMediaPlayerStartRecording(false);

      await recorder.start();

      expect(recorder.isRecording, isFalse);
    });

    testWidgets('fails to start recorder when microphone permission not granted', (tester) async {
      permissionHandlerMock.deny();

      await recorder.start();

      expect(recorder.isRecording, isFalse);
    });
  });
}
