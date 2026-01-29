import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/services/audio_system.dart';

mixin GeneratorMock on Mock implements AudioSystem {
  void mockGeneratorStart([bool result = true]) => when(generatorStart).thenAnswer((_) async => result);
  void verifyGeneratorStartCalled() => verify(generatorStart).called(1);
  void verifyGeneratorStartNeverCalled() => verifyNever(generatorStart);

  void mockGeneratorStop([bool result = true]) => when(generatorStop).thenAnswer((_) async => result);
  void verifyGeneratorStopCalled() => verify(generatorStop).called(1);

  void mockGeneratorNoteOn([bool result = true]) =>
      when(() => generatorNoteOn(newFreq: any(named: 'newFreq'))).thenAnswer((_) async => result);
  void verifyGeneratorNoteOnCalled() => verify(() => generatorNoteOn(newFreq: any(named: 'newFreq'))).called(1);
  void verifyGeneratorNoteOnCalledWith(double newFreq) => verify(() => generatorNoteOn(newFreq: newFreq)).called(1);

  void mockGeneratorNoteOff([bool result = true]) => when(generatorNoteOff).thenAnswer((_) async => result);
  void verifyGeneratorNoteOffCalled() => verify(generatorNoteOff).called(1);
}
