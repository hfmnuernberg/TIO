import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:tiomusic/domain/tuner/tuner.dart';

import '../../mocks/permission_handler_mock.dart';
import '../../utils/test_context.dart';

void main() {
  late TestContext context;
  late PermissionHandlerMock permissionHandlerMock;
  late Tuner tuner;

  setUp(() async {
    resetMocktailState();
    context = TestContext();

    permissionHandlerMock = PermissionHandlerMock()..grant();
    PermissionHandlerPlatform.instance = permissionHandlerMock;

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
  });
}
