import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/domain/audio/recorder.dart';

import '../../../utils/test_context.dart';

void main() {
  late TestContext context;
  late Recorder recorder;

  // Minimal mock for permission_handler to return "granted" in tests.
  const MethodChannel permChannel = MethodChannel('flutter.baseflow.com/permissions/methods');

  Future<void> mockMicrophonePermissionGranted() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(permChannel, (
      call,
    ) async {
      switch (call.method) {
        case 'checkPermissionStatus':
          // 1 == granted in permission_handler
          return 1;
        case 'requestPermissions':
          // permission_handler passes a List<int> of permission codes
          final List<dynamic> permissions = (call.arguments as List?) ?? const [];
          return {for (final p in permissions) p: 1};
        case 'shouldShowRequestPermissionRationale':
          return false;
        case 'openAppSettings':
          return true;
        default:
          return null;
      }
    });
  }

  setUp(() async {
    resetMocktailState();
    await mockMicrophonePermissionGranted();

    context = TestContext();
    recorder = Recorder(context.audioSystem, context.audioSession, context.wakelock);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(permChannel, null);
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

    testWidgets('forces screen to stay on when started', (tester) async {
      await recorder.start();

      context.wakelockMock.verifyEnableCalled();

      await recorder.stop();
    });

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

    testWidgets('fails to start recorder when audio system signals failure', (tester) async {
      context.audioSystemMock.mockMediaPlayerStartRecording(false);

      await recorder.start();

      expect(recorder.isRecording, isFalse);
    });
  });
}
