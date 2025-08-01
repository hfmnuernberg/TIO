import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/src/rust/api/modules/media_player.dart';
import 'package:tiomusic/src/rust/api/modules/metronome.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';

import '../utils/entities/metro_bar_matcher.dart';

class AudioSystemMock extends Mock implements AudioSystem {
  AudioSystemMock() {
    registerFallbackValue(BeatSound.Accented);

    mockInitAudio();
    mockTunerGetFrequency();
    mockTunerStart();
    mockTunerStop();
    mockGeneratorStart();
    mockGeneratorStop();
    mockGeneratorNoteOn();
    mockGeneratorNoteOff();
    mockPianoSetConcertPitch();

    mockMediaPlayerLoadWav();
    mockMediaPlayerStart();
    mockMediaPlayerStop();
    mockMediaPlayerStartRecording();
    mockMediaPlayerStopRecording();
    mockMediaPlayerGetRecordingSamples(Float64List(1));
    mockMediaPlayerSetPitchSemitones();
    mockMediaPlayerSetSpeedFactor();
    mockMediaPlayerSetTrim();
    mockMediaPlayerGetRms(Float32List(1));
    mockMediaPlayerSetLoop();
    mockMediaPlayerGetState();
    mockMediaPlayerSetPlaybackPosFactor();
    mockMediaPlayerSetVolume();

    mockMetronomeStart();
    mockMetronomeStop();
    mockMetronomeSetBpm();
    mockMetronomeLoadFile();
    mockMetronomeSetRhythm();
    mockMetronomePollBeatEventHappened();
    mockMetronomeSetMuted();
    mockMetronomeSetBeatMuteChance();
    mockMetronomeSetVolume();

    mockPianoSetup();
    mockPianoStart();
    mockPianoStop();
    mockPianoNoteOn();
    mockPianoNoteOff();
    mockPianoSetVolume();

    mockGetSampleRate();
    mockDebugTestFunction();
  }

  void mockInitAudio() => when(initAudio).thenAnswer((_) async {});

  void mockTunerGetFrequency([double? result]) => when(tunerGetFrequency).thenAnswer((_) async => result);

  void mockTunerStart([bool result = true]) => when(tunerStart).thenAnswer((_) async => result);

  void mockTunerStop([bool result = true]) => when(tunerStop).thenAnswer((_) async => result);

  void mockGeneratorStart([bool result = true]) => when(generatorStart).thenAnswer((_) async => result);

  void mockGeneratorStop([bool result = true]) => when(generatorStop).thenAnswer((_) async => result);

  void mockGeneratorNoteOn([bool result = true]) =>
      when(() => generatorNoteOn(newFreq: any(named: 'newFreq'))).thenAnswer((_) async => result);

  void mockGeneratorNoteOff([bool result = true]) => when(generatorNoteOff).thenAnswer((_) async => result);

  void mockPianoSetConcertPitch([bool result = true]) =>
      when(() => pianoSetConcertPitch(newConcertPitch: any(named: 'newConcertPitch'))).thenAnswer((_) async => result);

  void mockMediaPlayerLoadWav([bool result = true]) =>
      when(() => mediaPlayerLoadWav(wavFilePath: any(named: 'wavFilePath'))).thenAnswer((_) async => result);

  void mockMediaPlayerStart([bool result = true]) => when(mediaPlayerStart).thenAnswer((_) async => result);

  void mockMediaPlayerStop([bool result = true]) => when(mediaPlayerStop).thenAnswer((_) async => result);

  void mockMediaPlayerStartRecording([bool result = true]) =>
      when(mediaPlayerStartRecording).thenAnswer((_) async => result);

  void mockMediaPlayerStopRecording([bool result = true]) =>
      when(mediaPlayerStopRecording).thenAnswer((_) async => result);

  void mockMediaPlayerGetRecordingSamples(Float64List samples) =>
      when(mediaPlayerGetRecordingSamples).thenAnswer((_) async => samples);

  void mockMediaPlayerSetPitchSemitones([bool result = true]) => when(
    () => mediaPlayerSetPitchSemitones(pitchSemitones: any(named: 'pitchSemitones')),
  ).thenAnswer((_) async => result);

  void mockMediaPlayerSetSpeedFactor([bool result = true]) =>
      when(() => mediaPlayerSetSpeedFactor(speedFactor: any(named: 'speedFactor'))).thenAnswer((_) async => result);

  void mockMediaPlayerSetTrim([bool result = true]) => when(
    () => mediaPlayerSetTrim(startFactor: any(named: 'startFactor'), endFactor: any(named: 'endFactor')),
  ).thenAnswer((_) async => result);

  void mockMediaPlayerGetRms(Float32List rmsValues) =>
      when(() => mediaPlayerGetRms(nBins: any(named: 'nBins'))).thenAnswer((_) async => rmsValues);

  void mockMediaPlayerSetLoop([void result]) =>
      when(() => mediaPlayerSetRepeat(repeatOne: any(named: 'looping'))).thenAnswer((_) async => result);

  void mockMediaPlayerGetState([MediaPlayerState? state]) => when(mediaPlayerGetState).thenAnswer((_) async => state);

  void mockMediaPlayerSetPlaybackPosFactor([bool result = true]) =>
      when(() => mediaPlayerSetPlaybackPosFactor(posFactor: any(named: 'posFactor'))).thenAnswer((_) async => result);

  void mockMediaPlayerSetVolume([bool result = true]) =>
      when(() => mediaPlayerSetVolume(volume: any(named: 'volume'))).thenAnswer((_) async => result);

  void mockMetronomeStart([bool result = true]) => when(metronomeStart).thenAnswer((_) async => result);

  void mockMetronomeStop([bool result = true]) => when(metronomeStop).thenAnswer((_) async => result);

  void mockMetronomeSetBpm([bool result = true]) =>
      when(() => metronomeSetBpm(bpm: any(named: 'bpm'))).thenAnswer((_) async => result);

  void mockMetronomeLoadFile([bool result = true]) => when(
    () => metronomeLoadFile(beatType: any(named: 'beatType'), wavFilePath: any(named: 'wavFilePath')),
  ).thenAnswer((_) async => result);

  void mockMetronomeSetRhythm([bool result = true]) => when(
    () => metronomeSetRhythm(bars: any(named: 'bars'), bars2: any(named: 'bars2')),
  ).thenAnswer((_) async => result);

  void mockMetronomePollBeatEventHappened([BeatHappenedEvent? event]) =>
      when(metronomePollBeatEventHappened).thenAnswer((_) async => event);

  void mockMetronomePollBeatEventHappenedOnce([BeatHappenedEvent? event]) {
    bool called = false;
    when(metronomePollBeatEventHappened).thenAnswer((_) async {
      if (called) {
        called = true;
        return event;
      }
      return null;
    });
  }

  void mockMetronomeSetMuted([bool result = true]) =>
      when(() => metronomeSetMuted(muted: any(named: 'muted'))).thenAnswer((_) async => result);

  void mockMetronomeSetBeatMuteChance([bool result = true]) =>
      when(() => metronomeSetBeatMuteChance(muteChance: any(named: 'muteChance'))).thenAnswer((_) async => result);

  void mockMetronomeSetVolume([bool result = true]) =>
      when(() => metronomeSetVolume(volume: any(named: 'volume'))).thenAnswer((_) async => result);

  void mockPianoSetup([bool result = true]) =>
      when(() => pianoSetup(soundFontPath: any(named: 'soundFontPath'))).thenAnswer((_) async => result);

  void mockPianoStart([bool result = true]) => when(pianoStart).thenAnswer((_) async => result);

  void mockPianoStop([bool result = true]) => when(pianoStop).thenAnswer((_) async => result);

  void mockPianoNoteOn([bool result = true]) =>
      when(() => pianoNoteOn(note: any(named: 'note'))).thenAnswer((_) async => result);

  void mockPianoNoteOff([bool result = true]) =>
      when(() => pianoNoteOff(note: any(named: 'note'))).thenAnswer((_) async => result);

  void mockPianoSetVolume([bool result = true]) =>
      when(() => pianoSetVolume(volume: any(named: 'volume'))).thenAnswer((_) async => result);

  void mockGetSampleRate([int result = 44100]) => when(getSampleRate).thenAnswer((_) async => result);

  void mockDebugTestFunction([bool result = true]) => when(debugTestFunction).thenAnswer((_) async => result);

  void verifyMetronomeStartCalled() => verify(metronomeStart).called(1);

  void verifyMetronomeStartNeverCalled() => verifyNever(metronomeStart);

  void verifyMetronomeStopCalled() => verify(metronomeStop).called(1);

  void verifyMetronomeStopNeverCalled() => verifyNever(metronomeStop);

  void verifyMetronomeSetVolumeCalledWith(double volume) => verify(() => metronomeSetVolume(volume: volume)).called(1);

  void verifyMetronomeSetBpmCalledWith(double bpm) => verify(() => metronomeSetBpm(bpm: bpm)).called(1);

  void verifyMetronomeSetBeatMuteChanceCalledWith(double muteChance) =>
      verify(() => metronomeSetBeatMuteChance(muteChance: muteChance)).called(1);

  void verifyMetronomeSetRhythmCalledWith(List<MetroBar> bars, [List<MetroBar> bars2 = const []]) => verify(
    () => metronomeSetRhythm(
      bars: any(named: 'bars', that: metroBarListEquals(bars)),
      bars2: any(named: 'bars2', that: metroBarListEquals(bars2)),
    ),
  ).called(1);
}
