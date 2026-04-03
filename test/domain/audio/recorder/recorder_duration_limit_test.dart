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

    recorder = Recorder(
      context.audioSystem,
      context.audioSession,
      context.wakelock,
      onIsRecordingChange: recorderHandlerMock.onIsRecordingChange,
      onRecordingLengthChange: recorderHandlerMock.onRecordingLengthChange,
      onRecordingLimitReached: recorderHandlerMock.onRecordingLimitReached,
    );
  });

  group('Recorder buffer limit', () {
    testWidgets('auto-stops when buffer reaches max size', (tester) async {
      context.audioSystemMock.mockMediaPlayerGetRecordingBufferSize(Recorder.maxBufferSamples);
      await recorder.start();
      expect(recorder.isRecording, isTrue);

      await tester.pump(const Duration(seconds: 2));

      expect(recorder.isRecording, isFalse);
      context.audioSystemMock.verifyMediaPlayerStopRecordingCalled();
    });

    testWidgets('notifies about limit reached when auto-stopped', (tester) async {
      context.audioSystemMock.mockMediaPlayerGetRecordingBufferSize(Recorder.maxBufferSamples);
      await recorder.start();

      await tester.pump(const Duration(seconds: 2));

      recorderHandlerMock.verifyOnRecordingLimitReachedCalled();
    });

    testWidgets('does not trigger limit callback when buffer is below max', (tester) async {
      context.audioSystemMock.mockMediaPlayerGetRecordingBufferSize(1000);
      await recorder.start();

      await tester.pump(const Duration(seconds: 2));

      expect(recorder.isRecording, isTrue);
      recorderHandlerMock.verifyOnRecordingLimitReachedNeverCalled();

      await recorder.stop();
    });

    testWidgets('can be stopped manually before limit is reached', (tester) async {
      context.audioSystemMock.mockMediaPlayerGetRecordingBufferSize(1000);
      await recorder.start();

      await tester.pump(const Duration(seconds: 2));
      await recorder.stop();

      expect(recorder.isRecording, isFalse);
      recorderHandlerMock.verifyOnRecordingLimitReachedNeverCalled();
    });
  });
}
