import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/services/audio_system.dart';

mixin PianoMock on Mock implements AudioSystem {
  void mockPianoSetConcertPitch([bool result = true]) =>
      when(() => pianoSetConcertPitch(newConcertPitch: any(named: 'newConcertPitch'))).thenAnswer((_) async => result);
  void verifyPianoSetConcertPitchCalledWith(double concertPitch) =>
      verify(() => pianoSetConcertPitch(newConcertPitch: concertPitch)).called(1);

  void mockPianoSetup([bool result = true]) =>
      when(() => pianoSetup(soundFontPath: any(named: 'soundFontPath'))).thenAnswer((_) async => result);

  void mockPianoStart([bool result = true]) => when(pianoStart).thenAnswer((_) async => result);
  void verifyPianoStartCalled() => verify(pianoStart).called(1);
  void verifyPianoStartNeverCalled() => verifyNever(pianoStart);

  void mockPianoStop([bool result = true]) => when(pianoStop).thenAnswer((_) async => result);
  void verifyPianoStopCalled() => verify(pianoStop).called(1);
  void verifyPianoStopNeverCalled() => verifyNever(pianoStop);

  void mockPianoNoteOn([bool result = true]) =>
      when(() => pianoNoteOn(note: any(named: 'note'))).thenAnswer((_) async => result);
  void verifyPianoNoteOnCalledWith(int note) => verify(() => pianoNoteOn(note: note)).called(1);

  void mockPianoNoteOff([bool result = true]) =>
      when(() => pianoNoteOff(note: any(named: 'note'))).thenAnswer((_) async => result);
  void verifyPianoNoteOffCalledWith(int note) => verify(() => pianoNoteOff(note: note)).called(1);

  void mockPianoSetVolume([bool result = true]) =>
      when(() => pianoSetVolume(volume: any(named: 'volume'))).thenAnswer((_) async => result);
  void verifyPianoSetVolumeCalledWith(double volume) => verify(() => pianoSetVolume(volume: volume)).called(1);
}
