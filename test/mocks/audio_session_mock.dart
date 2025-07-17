import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/services/audio_session.dart';

class AudioSessionInterruptionListenerHandleMock extends Mock implements AudioSessionInterruptionListenerHandle {
  AudioSessionInterruptionListenerHandleMock() {
    mockCancel();
  }

  void mockCancel() => when(cancel).thenAnswer((_) async {});
}

class AudioSessionMock extends Mock implements AudioSession {
  AudioSessionMock() {
    registerFallbackValue(AudioSessionInterruptionListenerHandleMock());
    mockStart(true);
    mockStop(true);
    mockPreparePlayback();
    mockPrepareRecording();
    mockRegisterInterruptionListener(AudioSessionInterruptionListenerHandleMock());
    mockUnregisterInterruptionListener();
  }

  void mockStart(bool success) => when(start).thenAnswer((_) async => success);

  void mockStop(bool success) => when(stop).thenAnswer((_) async => success);

  void mockPreparePlayback() => when(preparePlayback).thenAnswer((_) async {});

  void mockPrepareRecording() => when(prepareRecording).thenAnswer((_) async {});

  void mockRegisterInterruptionListener(AudioSessionInterruptionListenerHandle handle) =>
      when(() => registerInterruptionListener(any())).thenAnswer((_) async => handle);

  void mockUnregisterInterruptionListener() =>
      when(() => unregisterInterruptionListener(any())).thenAnswer((_) async {});

  void verifyPreparePlaybackCalled() => verify(preparePlayback).called(1);
}
