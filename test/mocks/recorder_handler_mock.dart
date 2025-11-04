import 'package:mocktail/mocktail.dart';

class RecorderHandlerMock extends Mock {
  void onIsRecordingChange(bool isRecording);
  void onRecordingLengthChange(Duration recordingLength);

  void verifyOnIsRecordingChangeWith(bool isRecording) => verify(() => onIsRecordingChange(isRecording)).called(1);
  void verifyOnIsRecordingChangeNeverCalled() => verifyNever(() => onIsRecordingChange(any()));

  void verifyOnRecordingLengthChangeCalledWith(Duration recordingLength) =>
      verify(() => onRecordingLengthChange(recordingLength)).called(1);
  void verifyOnRecordingLengthChangeNeverCalled() => verifyNever(() => onRecordingLengthChange(any()));
}
