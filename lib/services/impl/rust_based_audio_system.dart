import 'dart:typed_data';

import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/src/rust/api/ffi.dart' as rust;
import 'package:tiomusic/src/rust/api/modules/media_player.dart';
import 'package:tiomusic/src/rust/api/modules/metronome.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';

class RustBasedAudioSystem implements AudioSystem {
  @override
  Future<void> initAudio() async => rust.initAudio();

  @override
  Future<double?> tunerGetFrequency() async => rust.tunerGetFrequency();

  @override
  Future<bool> tunerStart() async => rust.tunerStart();

  @override
  Future<bool> tunerStop() async => rust.tunerStop();

  @override
  Future<bool> generatorStart() async => rust.generatorStart();

  @override
  Future<bool> generatorStop() async => rust.generatorStop();

  @override
  Future<bool> generatorNoteOn({required double newFreq}) async => rust.generatorNoteOn(newFreq: newFreq);

  @override
  Future<bool> generatorNoteOff() async => rust.generatorNoteOff();

  @override
  Future<bool> pianoSetConcertPitch({required double newConcertPitch}) async =>
      rust.pianoSetConcertPitch(newConcertPitch: newConcertPitch);

  @override
  Future<bool> mediaPlayerLoadWav({required int id, required String wavFilePath}) async =>
      rust.mediaPlayerLoadWav(id: id, wavFilePath: wavFilePath);

  @override
  Future<bool> mediaPlayerStart({required int id}) async => rust.mediaPlayerStart(id: id);

  @override
  Future<bool> mediaPlayerStop({required int id}) async => rust.mediaPlayerStop(id: id);

  @override
  Future<bool> mediaPlayerStartRecording() async => rust.mediaPlayerStartRecording();

  @override
  Future<bool> mediaPlayerStopRecording() async => rust.mediaPlayerStopRecording();

  @override
  Future<Float64List> mediaPlayerGetRecordingSamples() async => rust.mediaPlayerGetRecordingSamples();

  @override
  Future<bool> mediaPlayerSetPitchSemitones({required int id, required double pitchSemitones}) async =>
      rust.mediaPlayerSetPitchSemitones(id: id, pitchSemitones: pitchSemitones);

  @override
  Future<bool> mediaPlayerSetSpeedFactor({required int id, required double speedFactor}) async =>
      rust.mediaPlayerSetSpeedFactor(id: id, speedFactor: speedFactor);

  @override
  Future<void> mediaPlayerSetTrim({required int id, required double startFactor, required double endFactor}) async =>
      rust.mediaPlayerSetTrim(id: id, startFactor: startFactor, endFactor: endFactor);

  @override
  Future<Float32List> mediaPlayerGetRms({required int id, required int nBins}) async =>
      rust.mediaPlayerGetRms(id: id, nBins: nBins);

  @override
  Future<void> mediaPlayerSetRepeat({required int id, required bool repeatOne}) async =>
      rust.mediaPlayerSetLoop(id: id, looping: repeatOne);

  @override
  Future<MediaPlayerState?> mediaPlayerGetState({required int id}) async => rust.mediaPlayerGetState(id: id);

  @override
  Future<bool> mediaPlayerSetPlaybackPosFactor({required int id, required double posFactor}) async =>
      rust.mediaPlayerSetPlaybackPosFactor(id: id, posFactor: posFactor);

  @override
  Future<bool> mediaPlayerSetVolume({required int id, required double volume}) async =>
      rust.mediaPlayerSetVolume(id: id, volume: volume);

  @override
  Future<void> mediaPlayerDestroyInstance({required int id}) async => rust.mediaPlayerDestroyInstance(id: id);

  @override
  Future<bool> mediaPlayerRenderMidiToWav({
    required String midiPath,
    required String soundFontPath,
    required String wavOutPath,
    required int sampleRate,
    required double gain,
  }) async => rust.mediaPlayerRenderMidiToWav(
    midiPath: midiPath,
    soundFontPath: soundFontPath,
    wavOutPath: wavOutPath,
    sampleRate: sampleRate,
    gain: gain,
  );

  @override
  Future<bool> metronomeStart() async => rust.metronomeStart();

  @override
  Future<bool> metronomeStop() async => rust.metronomeStop();

  @override
  Future<bool> metronomeSetBpm({required double bpm}) async => rust.metronomeSetBpm(bpm: bpm);

  @override
  Future<bool> metronomeLoadFile({required BeatSound beatType, required String wavFilePath}) async =>
      rust.metronomeLoadFile(beatType: beatType, wavFilePath: wavFilePath);

  @override
  Future<bool> metronomeSetRhythm({required List<MetroBar> bars, required List<MetroBar> bars2}) async =>
      rust.metronomeSetRhythm(bars: bars, bars2: bars2);

  @override
  Future<BeatHappenedEvent?> metronomePollBeatEventHappened() async => rust.metronomePollBeatEventHappened();

  @override
  Future<bool> metronomeSetMuted({required bool muted}) async => rust.metronomeSetMuted(muted: muted);

  @override
  Future<bool> metronomeSetBeatMuteChance({required double muteChance}) async =>
      rust.metronomeSetBeatMuteChance(muteChance: muteChance);

  @override
  Future<bool> metronomeSetVolume({required double volume}) async => rust.metronomeSetVolume(volume: volume);

  @override
  Future<bool> pianoSetup({required String soundFontPath}) async => rust.pianoSetup(soundFontPath: soundFontPath);

  @override
  Future<bool> pianoStart() async => rust.pianoStart();

  @override
  Future<bool> pianoStop() async => rust.pianoStop();

  @override
  Future<bool> pianoNoteOn({required int note}) async => rust.pianoNoteOn(note: note);

  @override
  Future<bool> pianoNoteOff({required int note}) async => rust.pianoNoteOff(note: note);

  @override
  Future<bool> pianoSetVolume({required double volume}) async => rust.pianoSetVolume(volume: volume);

  @override
  Future<int> getSampleRate() async => rust.getSampleRate();

  @override
  Future<bool> debugTestFunction() async => rust.debugTestFunction();
}
