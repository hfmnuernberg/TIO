import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/src/rust/api/modules/media_player.dart';

mixin MediaPlayerMock on Mock implements AudioSystem {
  void mockMediaPlayerLoadWav([bool result = true]) => when(
    () => mediaPlayerLoadWav(
      id: any(named: 'id'),
      wavFilePath: any(named: 'wavFilePath'),
    ),
  ).thenAnswer((_) async => result);
  void verifyMediaPlayerLoadWavCalledWith(Pattern wavFilePath) => verify(
    () => mediaPlayerLoadWav(
      id: any(named: 'id'),
      wavFilePath: any(named: 'wavFilePath', that: matches(wavFilePath)),
    ),
  ).called(1);

  void mockMediaPlayerRenderMidiToWav([bool result = true]) => when(
    () => mediaPlayerRenderMidiToWav(
      midiPath: any(named: 'midiPath'),
      soundFontPath: any(named: 'soundFontPath'),
      wavOutPath: any(named: 'wavOutPath'),
      sampleRate: any(named: 'sampleRate'),
      gain: any(named: 'gain'),
    ),
  ).thenAnswer((_) async => result);
  void verifyMediaPlayerRenderMidiToWavCalled() => verify(
    () => mediaPlayerRenderMidiToWav(
      midiPath: any(named: 'midiPath'),
      soundFontPath: any(named: 'soundFontPath'),
      wavOutPath: any(named: 'wavOutPath'),
      sampleRate: any(named: 'sampleRate'),
      gain: any(named: 'gain'),
    ),
  ).called(1);

  void mockMediaPlayerStart([bool result = true]) =>
      when(() => mediaPlayerStart(id: any(named: 'id'))).thenAnswer((_) async => result);
  void verifyMediaPlayerStartCalled() => verify(() => mediaPlayerStart(id: any(named: 'id'))).called(1);
  void verifyMediaPlayerStartCalledWithId(int id) => verify(() => mediaPlayerStart(id: id)).called(1);
  void verifyMediaPlayerStartNeverCalled() => verifyNever(() => mediaPlayerStart(id: any(named: 'id')));

  void mockMediaPlayerStop([bool result = true]) =>
      when(() => mediaPlayerStop(id: any(named: 'id'))).thenAnswer((_) async => result);
  void verifyMediaPlayerStopCalled() => verify(() => mediaPlayerStop(id: any(named: 'id'))).called(1);

  void mockMediaPlayerStartRecording([bool result = true]) =>
      when(mediaPlayerStartRecording).thenAnswer((_) async => result);
  void verifyMediaPlayerStartRecordingCalled() => verify(mediaPlayerStartRecording).called(1);
  void verifyMediaPlayerStartRecordingNeverCalled() => verifyNever(mediaPlayerStartRecording);

  void mockMediaPlayerStopRecording([bool result = true]) =>
      when(mediaPlayerStopRecording).thenAnswer((_) async => result);
  void verifyMediaPlayerStopRecordingCalled() => verify(mediaPlayerStopRecording).called(1);
  void verifyMediaPlayerStopRecordingNeverCalled() => verifyNever(mediaPlayerStopRecording);

  void mockMediaPlayerGetRecordingSamples(Float64List samples) =>
      when(mediaPlayerGetRecordingSamples).thenAnswer((_) async => samples);
  void verifyMediaPlayerGetRecordingSamplesCalled() => verify(mediaPlayerGetRecordingSamples).called(1);
  void verifyMediaPlayerGetRecordingSamplesNeverCalled() => verifyNever(mediaPlayerGetRecordingSamples);

  void mockMediaPlayerSetPitchSemitones([bool result = true]) => when(
    () => mediaPlayerSetPitchSemitones(
      id: any(named: 'id'),
      pitchSemitones: any(named: 'pitchSemitones'),
    ),
  ).thenAnswer((_) async => result);
  void verifyMediaPlayerSetPitchCalledWith(double pitchSemitones) => verify(
    () => mediaPlayerSetPitchSemitones(
      id: any(named: 'id'),
      pitchSemitones: pitchSemitones,
    ),
  ).called(1);

  void mockMediaPlayerSetSpeedFactor([bool result = true]) => when(
    () => mediaPlayerSetSpeedFactor(
      id: any(named: 'id'),
      speedFactor: any(named: 'speedFactor'),
    ),
  ).thenAnswer((_) async => result);
  void verifyMediaPlayerSetSpeedCalledWith(double speedFactor) => verify(
    () => mediaPlayerSetSpeedFactor(
      id: any(named: 'id'),
      speedFactor: speedFactor,
    ),
  ).called(1);

  void mockMediaPlayerSetTrim([bool result = true]) => when(
    () => mediaPlayerSetTrim(
      id: any(named: 'id'),
      startFactor: any(named: 'startFactor'),
      endFactor: any(named: 'endFactor'),
    ),
  ).thenAnswer((_) async => result);
  void verifyMediaPlayerSetTrimCalledWith(double startFactor, double endFactor) => verify(
    () => mediaPlayerSetTrim(
      id: any(named: 'id'),
      startFactor: startFactor,
      endFactor: endFactor,
    ),
  ).called(1);
  void verifyMediaPlayerSetTrimNeverCalled() => verifyNever(
    () => mediaPlayerSetTrim(
      id: any(named: 'id'),
      startFactor: any(named: 'startFactor'),
      endFactor: any(named: 'endFactor'),
    ),
  );

  void mockMediaPlayerGetRms(Float32List rmsValues) => when(
    () => mediaPlayerGetRms(
      id: any(named: 'id'),
      nBins: any(named: 'nBins'),
    ),
  ).thenAnswer((_) async => rmsValues);
  void verifyMediaPlayerGetRmsCalledWith(int nBins) => verify(
    () => mediaPlayerGetRms(
      id: any(named: 'id'),
      nBins: nBins,
    ),
  ).called(1);

  void mockMediaPlayerSetRepeat([void result]) => when(
    () => mediaPlayerSetRepeat(
      id: any(named: 'id'),
      repeatOne: any(named: 'repeatOne'),
    ),
  ).thenAnswer((_) async => result);
  void verifyMediaPlayerSetRepeatCalledWith(bool repeat) => verify(
    () => mediaPlayerSetRepeat(
      id: any(named: 'id'),
      repeatOne: repeat,
    ),
  ).called(1);

  void mockMediaPlayerGetState([MediaPlayerState? state]) =>
      when(() => mediaPlayerGetState(id: any(named: 'id'))).thenAnswer((_) async => state);
  void verifyMediaPlayerGetStateCalled() => verify(() => mediaPlayerGetState(id: any(named: 'id'))).called(1);

  void mockMediaPlayerSetPlaybackPosFactor([bool result = true]) => when(
    () => mediaPlayerSetPlaybackPosFactor(
      id: any(named: 'id'),
      posFactor: any(named: 'posFactor'),
    ),
  ).thenAnswer((_) async => result);
  void verifyMediaPlayerSetPlaybackPositionCalled() => verify(
    () => mediaPlayerSetPlaybackPosFactor(
      id: any(named: 'id'),
      posFactor: any(named: 'posFactor'),
    ),
  ).called(1);
  void verifyMediaPlayerSetPlaybackPositionCalledWith(double posFactor) => verify(
    () => mediaPlayerSetPlaybackPosFactor(
      id: any(named: 'id'),
      posFactor: posFactor,
    ),
  ).called(1);
  void verifyMediaPlayerSetPlaybackPositionNeverCalled() => verifyNever(
    () => mediaPlayerSetPlaybackPosFactor(
      id: any(named: 'id'),
      posFactor: any(named: 'posFactor'),
    ),
  );

  void mockMediaPlayerSetVolume([bool result = true]) => when(
    () => mediaPlayerSetVolume(
      id: any(named: 'id'),
      volume: any(named: 'volume'),
    ),
  ).thenAnswer((_) async => result);
  void verifyMediaPlayerSetVolumeCalledWith(double volume) => verify(
    () => mediaPlayerSetVolume(
      id: any(named: 'id'),
      volume: volume,
    ),
  ).called(1);

  void mockMediaPlayerDestroyInstance() =>
      when(() => mediaPlayerDestroyInstance(id: any(named: 'id'))).thenAnswer((_) async {});
  void verifyMediaPlayerDestroyInstanceCalled() =>
      verify(() => mediaPlayerDestroyInstance(id: any(named: 'id'))).called(1);
}
