import 'package:mocktail/mocktail.dart';

class TunerHandlerMock extends Mock {
  void onRunningChange(bool isRunning);
  void onFrequencyChange(double? frequency);

  void verifyOnRunningChangeCalledWith(bool isRunning) => verify(() => onRunningChange(isRunning)).called(1);
  void verifyOnRunningChangeNeverCalled() => verifyNever(() => onRunningChange(any()));

  void verifyOnFrequencyChangeCalledWith(double? frequency) => verify(() => onFrequencyChange(frequency)).called(1);
  void verifyOnFrequencyChangeNeverCalled() => verifyNever(() => onFrequencyChange(any()));
}
