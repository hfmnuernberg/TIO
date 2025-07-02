import 'dart:typed_data';

import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/src/rust/api/modules/media_player.dart';
import 'package:tiomusic/src/rust/api/modules/metronome.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';

class InMemoryAudioSystemMock implements AudioSystem {
  double? fakeTunerFrequency;
  bool isTunerRunning = false;

  bool isGeneratorRunning = false;
  double? generatorFrequency;

  double concertPitch = 440.0;

  String? loadedWavFilePath;
  bool isMediaPlayerRunning = false;
  bool isRecording = false;
  Float64List recordedSamples = Float64List(0);
  double mediaPlayerPitch = 0.0;
  double mediaPlayerSpeed = 1.0;
  double mediaPlayerStartTrim = 0.0;
  double mediaPlayerEndTrim = 1.0;
  bool mediaPlayerLooping = false;
  MediaPlayerState mediaPlayerState = MediaPlayerState(
    playing: false,
    playbackPositionFactor: 0.0,
    totalLengthSeconds: 0.0,
    looping: false,
    trimStartFactor: 0.0,
    trimEndFactor: 1.0,
  );
  double mediaPlayerPosFactor = 0.0;
  double mediaPlayerVolume = 1.0;

  bool isMetronomeRunning = false;
  double metronomeBpm = 120.0;
  BeatSound? metronomeLoadedBeat;
  Map<BeatSound, String> metronomeBeatFiles = {};
  List<MetroBar> rhythmBars = [];
  List<MetroBar> rhythmBars2 = [];
  bool metronomeMuted = false;
  double metronomeMuteChance = 0.0;
  double metronomeVolume = 1.0;

  bool isPianoRunning = false;
  String? pianoSoundFontPath;
  Set<int> activeNotes = {};
  double pianoVolume = 1.0;

  int sampleRate = 44100;

  bool debugResult = true;

  @override
  Future<void> initAudio() async {}

  @override
  Future<double?> tunerGetFrequency() async {
    return fakeTunerFrequency;
  }

  @override
  Future<bool> tunerStart() async {
    isTunerRunning = true;
    return true;
  }

  @override
  Future<bool> tunerStop() async {
    isTunerRunning = false;
    return true;
  }

  @override
  Future<bool> generatorStart() async {
    isGeneratorRunning = true;
    return true;
  }

  @override
  Future<bool> generatorStop() async {
    isGeneratorRunning = false;
    return true;
  }

  @override
  Future<bool> generatorNoteOn({required double newFreq}) async {
    generatorFrequency = newFreq;
    return true;
  }

  @override
  Future<bool> generatorNoteOff() async {
    generatorFrequency = null;
    return true;
  }

  @override
  Future<bool> pianoSetConcertPitch({required double newConcertPitch}) async {
    concertPitch = newConcertPitch;
    return true;
  }

  @override
  Future<bool> mediaPlayerLoadWav({required String wavFilePath}) async {
    loadedWavFilePath = wavFilePath;
    return true;
  }

  @override
  Future<bool> mediaPlayerStart() async {
    isMediaPlayerRunning = true;
    mediaPlayerState = MediaPlayerState(
      playing: true,
      playbackPositionFactor: 0.0,
      totalLengthSeconds: 0.0,
      looping: false,
      trimStartFactor: 0.0,
      trimEndFactor: 1.0,
    );
    return true;
  }

  @override
  Future<bool> mediaPlayerStop() async {
    isMediaPlayerRunning = false;
    mediaPlayerState = MediaPlayerState(
      playing: false,
      playbackPositionFactor: 0.0,
      totalLengthSeconds: 0.0,
      looping: false,
      trimStartFactor: 0.0,
      trimEndFactor: 1.0,
    );
    return true;
  }

  @override
  Future<bool> mediaPlayerStartRecording() async {
    isRecording = true;
    return true;
  }

  @override
  Future<bool> mediaPlayerStopRecording() async {
    isRecording = false;
    return true;
  }

  @override
  Future<Float64List> mediaPlayerGetRecordingSamples() async {
    return recordedSamples;
  }

  @override
  Future<bool> mediaPlayerSetPitchSemitones({required double pitchSemitones}) async {
    mediaPlayerPitch = pitchSemitones;
    return true;
  }

  @override
  Future<bool> mediaPlayerSetSpeedFactor({required double speedFactor}) async {
    mediaPlayerSpeed = speedFactor;
    return true;
  }

  @override
  Future<void> mediaPlayerSetTrim({required double startFactor, required double endFactor}) async {
    mediaPlayerStartTrim = startFactor;
    mediaPlayerEndTrim = endFactor;
  }

  @override
  Future<Float32List> mediaPlayerGetRms({required int nBins}) async {
    return Float32List(nBins);
  }

  @override
  Future<void> mediaPlayerSetLoop({required bool looping}) async {
    mediaPlayerLooping = looping;
  }

  @override
  Future<MediaPlayerState?> mediaPlayerGetState() async {
    return mediaPlayerState;
  }

  @override
  Future<bool> mediaPlayerSetPlaybackPosFactor({required double posFactor}) async {
    mediaPlayerPosFactor = posFactor;
    return true;
  }

  @override
  Future<bool> mediaPlayerSetVolume({required double volume}) async {
    mediaPlayerVolume = volume;
    return true;
  }

  @override
  Future<bool> metronomeStart() async {
    isMetronomeRunning = true;
    return true;
  }

  @override
  Future<bool> metronomeStop() async {
    isMetronomeRunning = false;
    return true;
  }

  @override
  Future<bool> metronomeSetBpm({required double bpm}) async {
    metronomeBpm = bpm;
    return true;
  }

  @override
  Future<bool> metronomeLoadFile({required BeatSound beatType, required String wavFilePath}) async {
    metronomeBeatFiles[beatType] = wavFilePath;
    return true;
  }

  @override
  Future<bool> metronomeSetRhythm({required List<MetroBar> bars, required List<MetroBar> bars2}) async {
    rhythmBars = bars;
    rhythmBars2 = bars2;
    return true;
  }

  @override
  Future<BeatHappenedEvent?> metronomePollBeatEventHappened() async {
    return null;
  }

  @override
  Future<bool> metronomeSetMuted({required bool muted}) async {
    metronomeMuted = muted;
    return true;
  }

  @override
  Future<bool> metronomeSetBeatMuteChance({required double muteChance}) async {
    metronomeMuteChance = muteChance;
    return true;
  }

  @override
  Future<bool> metronomeSetVolume({required double volume}) async {
    metronomeVolume = volume;
    return true;
  }

  @override
  Future<bool> pianoSetup({required String soundFontPath}) async {
    pianoSoundFontPath = soundFontPath;
    return true;
  }

  @override
  Future<bool> pianoStart() async {
    isPianoRunning = true;
    return true;
  }

  @override
  Future<bool> pianoStop() async {
    isPianoRunning = false;
    return true;
  }

  @override
  Future<bool> pianoNoteOn({required int note}) async {
    activeNotes.add(note);
    return true;
  }

  @override
  Future<bool> pianoNoteOff({required int note}) async {
    activeNotes.remove(note);
    return true;
  }

  @override
  Future<bool> pianoSetVolume({required double volume}) async {
    pianoVolume = volume;
    return true;
  }

  @override
  Future<int> getSampleRate() async {
    return sampleRate;
  }

  @override
  Future<bool> debugTestFunction() async {
    return debugResult;
  }
}
