import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/src/rust/api/modules/media_player.dart';

mixin MediaPlayerMock on Mock implements AudioSystem {
  void mockMediaPlayerLoadWav([bool result = true]) =>
      when(() => mediaPlayerLoadWav(wavFilePath: any(named: 'wavFilePath'))).thenAnswer((_) async => result);
  void verifyMediaPlayerLoadWavCalledWith(Pattern wavFilePath) => verify(
    () => mediaPlayerLoadWav(
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

  void mockMediaPlayerStart([bool result = true]) => when(mediaPlayerStart).thenAnswer((_) async => result);
  void verifyMediaPlayerStartCalled() => verify(mediaPlayerStart).called(1);

  void mockMediaPlayerStop([bool result = true]) => when(mediaPlayerStop).thenAnswer((_) async => result);
  void verifyMediaPlayerStopCalled() => verify(mediaPlayerStop).called(1);

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
    () => mediaPlayerSetPitchSemitones(pitchSemitones: any(named: 'pitchSemitones')),
  ).thenAnswer((_) async => result);
  void verifyMediaPlayerSetPitchCalledWith(double pitchSemitones) =>
      verify(() => mediaPlayerSetPitchSemitones(pitchSemitones: pitchSemitones)).called(1);

  void mockMediaPlayerSetSpeedFactor([bool result = true]) =>
      when(() => mediaPlayerSetSpeedFactor(speedFactor: any(named: 'speedFactor'))).thenAnswer((_) async => result);
  void verifyMediaPlayerSetSpeedCalledWith(double speedFactor) =>
      verify(() => mediaPlayerSetSpeedFactor(speedFactor: speedFactor)).called(1);

  void mockMediaPlayerSetTrim([bool result = true]) => when(
    () => mediaPlayerSetTrim(
      startFactor: any(named: 'startFactor'),
      endFactor: any(named: 'endFactor'),
    ),
  ).thenAnswer((_) async => result);
  void verifyMediaPlayerSetTrimCalledWith(double startFactor, double endFactor) =>
      verify(() => mediaPlayerSetTrim(startFactor: startFactor, endFactor: endFactor)).called(1);
  void verifyMediaPlayerSetTrimNeverCalled() => verifyNever(
    () => mediaPlayerSetTrim(
      startFactor: any(named: 'startFactor'),
      endFactor: any(named: 'endFactor'),
    ),
  );

  void mockMediaPlayerGetRms(Float32List rmsValues) =>
      when(() => mediaPlayerGetRms(nBins: any(named: 'nBins'))).thenAnswer((_) async => rmsValues);
  void verifyMediaPlayerGetRmsCalledWith(int nBins) => verify(() => mediaPlayerGetRms(nBins: nBins)).called(1);

  void mockMediaPlayerSetRepeat([void result]) =>
      when(() => mediaPlayerSetRepeat(repeatOne: any(named: 'repeatOne'))).thenAnswer((_) async => result);
  void verifyMediaPlayerSetRepeatCalledWith(bool repeat) =>
      verify(() => mediaPlayerSetRepeat(repeatOne: repeat)).called(1);

  void mockMediaPlayerGetState([MediaPlayerState? state]) => when(mediaPlayerGetState).thenAnswer((_) async => state);
  void verifyMediaPlayerGetStateCalled() => verify(mediaPlayerGetState).called(1);

  void mockMediaPlayerSetPlaybackPosFactor([bool result = true]) =>
      when(() => mediaPlayerSetPlaybackPosFactor(posFactor: any(named: 'posFactor'))).thenAnswer((_) async => result);
  void verifyMediaPlayerSetPlaybackPositionCalled() =>
      verify(() => mediaPlayerSetPlaybackPosFactor(posFactor: any(named: 'posFactor'))).called(1);
  void verifyMediaPlayerSetPlaybackPositionCalledWith(double posFactor) =>
      verify(() => mediaPlayerSetPlaybackPosFactor(posFactor: posFactor)).called(1);
  void verifyMediaPlayerSetPlaybackPositionNeverCalled() =>
      verifyNever(() => mediaPlayerSetPlaybackPosFactor(posFactor: any(named: 'posFactor')));

  void mockMediaPlayerSetVolume([bool result = true]) =>
      when(() => mediaPlayerSetVolume(volume: any(named: 'volume'))).thenAnswer((_) async => result);
  void verifyMediaPlayerSetVolumeCalledWith(double volume) =>
      verify(() => mediaPlayerSetVolume(volume: volume)).called(1);

  void mockMediaPlayerLoadSecondaryProcessed([bool result = true]) => when(
    () => mediaPlayerLoadSecondaryProcessed(
      wavFilePath: any(named: 'wavFilePath'),
      pitchSemitones: any(named: 'pitchSemitones'),
      speedFactor: any(named: 'speedFactor'),
      trimStartFactor: any(named: 'trimStartFactor'),
      trimEndFactor: any(named: 'trimEndFactor'),
      volume: any(named: 'volume'),
    ),
  ).thenAnswer((_) async => result);

  void mockMediaPlayerUnloadSecondaryAudio([bool result = true]) =>
      when(mediaPlayerUnloadSecondaryAudio).thenAnswer((_) async => result);

  void mockMediaPlayerSetSecondaryAudioVolume([bool result = true]) =>
      when(() => mediaPlayerSetSecondaryAudioVolume(volume: any(named: 'volume'))).thenAnswer((_) async => result);
}
