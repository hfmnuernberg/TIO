import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/services/audio_system.dart';

mixin TunerMock on Mock implements AudioSystem {
  void mockTunerGetFrequency([double? result]) => when(tunerGetFrequency).thenAnswer((_) async => result);

  void mockTunerStart([bool result = true]) => when(tunerStart).thenAnswer((_) async => result);
  void verifyTunerStartCalled() => verify(tunerStart).called(1);
  void verifyTunerStartNeverCalled() => verifyNever(tunerStart);

  void mockTunerStop([bool result = true]) => when(tunerStop).thenAnswer((_) async => result);
  void verifyTunerStopCalled() => verify(tunerStop).called(1);
}
