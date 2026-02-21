import 'dart:typed_data';

import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/src/rust/api/modules/media_player.dart';
import 'package:tiomusic/src/rust/api/modules/metronome.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';
import 'package:tiomusic/util/log.dart';

class AudioSystemLogDecorator implements AudioSystem {
  static final _logger = createPrefixLogger('AudioSystem');

  final AudioSystem _as;

  AudioSystemLogDecorator(this._as);

  @override
  Future<void> initAudio() async {
    await _as.initAudio();
    _logger.t('initAudio()');
  }

  @override
  Future<double?> tunerGetFrequency() async {
    final result = await _as.tunerGetFrequency();
    _logger.t('tunerGetFrequency(): $result');
    return result;
  }

  @override
  Future<bool> tunerStart() async {
    final result = await _as.tunerStart();
    _logger.t('tunerStart(): $result');
    return result;
  }

  @override
  Future<bool> tunerStop() async {
    final result = await _as.tunerStop();
    _logger.t('tunerStop(): $result');
    return result;
  }

  @override
  Future<bool> generatorStart() async {
    final result = await _as.generatorStart();
    _logger.t('generatorStart(): $result');
    return result;
  }

  @override
  Future<bool> generatorStop() async {
    final result = await _as.generatorStop();
    _logger.t('generatorStop(): $result');
    return result;
  }

  @override
  Future<bool> generatorNoteOn({required double newFreq}) async {
    final result = await _as.generatorNoteOn(newFreq: newFreq);
    _logger.t('generatorNoteOn(newFreq: $newFreq): $result');
    return result;
  }

  @override
  Future<bool> generatorNoteOff() async {
    final result = await _as.generatorNoteOff();
    _logger.t('generatorNoteOff(): $result');
    return result;
  }

  @override
  Future<bool> pianoSetConcertPitch({required double newConcertPitch}) async {
    final result = await _as.pianoSetConcertPitch(newConcertPitch: newConcertPitch);
    _logger.t('pianoSetConcertPitch(newConcertPitch: $newConcertPitch): $result');
    return result;
  }

  @override
  Future<bool> mediaPlayerLoadWav({required int id, required String wavFilePath}) async {
    final result = await _as.mediaPlayerLoadWav(id: id, wavFilePath: wavFilePath);
    _logger.t('mediaPlayerLoadWav(id: $id, wavFilePath: $wavFilePath): $result');
    return result;
  }

  @override
  Future<bool> mediaPlayerStart({required int id}) async {
    final result = await _as.mediaPlayerStart(id: id);
    _logger.t('mediaPlayerStart(id: $id): $result');
    return result;
  }

  @override
  Future<bool> mediaPlayerStop({required int id}) async {
    final result = await _as.mediaPlayerStop(id: id);
    _logger.t('mediaPlayerStop(id: $id): $result');
    return result;
  }

  @override
  Future<bool> mediaPlayerStartRecording() async {
    final result = await _as.mediaPlayerStartRecording();
    _logger.t('mediaPlayerStartRecording(): $result');
    return result;
  }

  @override
  Future<bool> mediaPlayerStopRecording() async {
    final result = await _as.mediaPlayerStopRecording();
    _logger.t('mediaPlayerStopRecording(): $result');
    return result;
  }

  @override
  Future<Float64List> mediaPlayerGetRecordingSamples() async {
    final result = await _as.mediaPlayerGetRecordingSamples();
    _logger.t('mediaPlayerGetRecordingSamples(): Float64List(length=${result.length})');
    return result;
  }

  @override
  Future<bool> mediaPlayerSetPitchSemitones({required int id, required double pitchSemitones}) async {
    final result = await _as.mediaPlayerSetPitchSemitones(id: id, pitchSemitones: pitchSemitones);
    _logger.t('mediaPlayerSetPitchSemitones(id: $id, pitchSemitones: $pitchSemitones): $result');
    return result;
  }

  @override
  Future<bool> mediaPlayerSetSpeedFactor({required int id, required double speedFactor}) async {
    final result = await _as.mediaPlayerSetSpeedFactor(id: id, speedFactor: speedFactor);
    _logger.t('mediaPlayerSetSpeedFactor(id: $id, speedFactor: $speedFactor): $result');
    return result;
  }

  @override
  Future<void> mediaPlayerSetTrim({required int id, required double startFactor, required double endFactor}) async {
    await _as.mediaPlayerSetTrim(id: id, startFactor: startFactor, endFactor: endFactor);
    _logger.t('mediaPlayerSetTrim(id: $id, startFactor: $startFactor, endFactor: $endFactor)');
  }

  @override
  Future<Float32List> mediaPlayerGetRms({required int id, required int nBins}) async {
    final result = await _as.mediaPlayerGetRms(id: id, nBins: nBins);
    _logger.t('mediaPlayerGetRms(id: $id, nBins: $nBins): Float32List(length=${result.length})');
    return result;
  }

  @override
  Future<void> mediaPlayerSetRepeat({required int id, required bool repeatOne}) async {
    await _as.mediaPlayerSetRepeat(id: id, repeatOne: repeatOne);
    _logger.t('mediaPlayerSetRepeat(id: $id, repeatOne: $repeatOne)');
  }

  @override
  Future<MediaPlayerState?> mediaPlayerGetState({required int id}) async {
    final result = await _as.mediaPlayerGetState(id: id);
    _logger.t('mediaPlayerGetState(id: $id): $result');
    return result;
  }

  @override
  Future<bool> mediaPlayerSetPlaybackPosFactor({required int id, required double posFactor}) async {
    final result = await _as.mediaPlayerSetPlaybackPosFactor(id: id, posFactor: posFactor);
    _logger.t('mediaPlayerSetPlaybackPosFactor(id: $id, posFactor: $posFactor): $result');
    return result;
  }

  @override
  Future<bool> mediaPlayerSetVolume({required int id, required double volume}) async {
    final result = await _as.mediaPlayerSetVolume(id: id, volume: volume);
    _logger.t('mediaPlayerSetVolume(id: $id, volume: $volume): $result');
    return result;
  }

  @override
  Future<void> mediaPlayerDestroyInstance({required int id}) async {
    await _as.mediaPlayerDestroyInstance(id: id);
    _logger.t('mediaPlayerDestroyInstance(id: $id)');
  }

  @override
  Future<bool> mediaPlayerRenderMidiToWav({
    required String midiPath,
    required String soundFontPath,
    required String wavOutPath,
    required int sampleRate,
    required double gain,
  }) async {
    final result = await _as.mediaPlayerRenderMidiToWav(
      midiPath: midiPath,
      soundFontPath: soundFontPath,
      wavOutPath: wavOutPath,
      sampleRate: sampleRate,
      gain: gain,
    );
    _logger.t(
      'mediaPlayerRenderMidiToWav(midiPath: $midiPath, soundFontPath: $soundFontPath, wavOutPath: $wavOutPath, sampleRate: $sampleRate, gain: $gain): $result',
    );
    return result;
  }

  @override
  Future<bool> metronomeStart() async {
    final result = await _as.metronomeStart();
    _logger.t('metronomeStart(): $result');
    return result;
  }

  @override
  Future<bool> metronomeStop() async {
    final result = await _as.metronomeStop();
    _logger.t('metronomeStop(): $result');
    return result;
  }

  @override
  Future<bool> metronomeSetBpm({required double bpm}) async {
    final result = await _as.metronomeSetBpm(bpm: bpm);
    _logger.t('metronomeSetBpm(bpm: $bpm): $result');
    return result;
  }

  @override
  Future<bool> metronomeLoadFile({required BeatSound beatType, required String wavFilePath}) async {
    final result = await _as.metronomeLoadFile(beatType: beatType, wavFilePath: wavFilePath);
    _logger.t('metronomeLoadFile(beatType: $beatType, wavFilePath: $wavFilePath): $result');
    return result;
  }

  @override
  Future<bool> metronomeSetRhythm({required List<MetroBar> bars, required List<MetroBar> bars2}) async {
    final result = await _as.metronomeSetRhythm(bars: bars, bars2: bars2);
    _logger.t('metronomeSetRhythm(bars.length: ${bars.length}, bars2.length: ${bars2.length}): $result');
    return result;
  }

  @override
  Future<BeatHappenedEvent?> metronomePollBeatEventHappened() async {
    final result = await _as.metronomePollBeatEventHappened();
    _logger.t('metronomePollBeatEventHappened(): $result');
    return result;
  }

  @override
  Future<bool> metronomeSetMuted({required bool muted}) async {
    final result = await _as.metronomeSetMuted(muted: muted);
    _logger.t('metronomeSetMuted(muted: $muted): $result');
    return result;
  }

  @override
  Future<bool> metronomeSetBeatMuteChance({required double muteChance}) async {
    final result = await _as.metronomeSetBeatMuteChance(muteChance: muteChance);
    _logger.t('metronomeSetBeatMuteChance(muteChance: $muteChance): $result');
    return result;
  }

  @override
  Future<bool> metronomeSetVolume({required double volume}) async {
    final result = await _as.metronomeSetVolume(volume: volume);
    _logger.t('metronomeSetVolume(volume: $volume): $result');
    return result;
  }

  @override
  Future<bool> pianoSetup({required String soundFontPath}) async {
    final result = await _as.pianoSetup(soundFontPath: soundFontPath);
    _logger.t('pianoSetup(soundFontPath: $soundFontPath): $result');
    return result;
  }

  @override
  Future<bool> pianoStart() async {
    final result = await _as.pianoStart();
    _logger.t('pianoStart(): $result');
    return result;
  }

  @override
  Future<bool> pianoStop() async {
    final result = await _as.pianoStop();
    _logger.t('pianoStop(): $result');
    return result;
  }

  @override
  Future<bool> pianoNoteOn({required int note}) async {
    final result = await _as.pianoNoteOn(note: note);
    _logger.t('pianoNoteOn(note: $note): $result');
    return result;
  }

  @override
  Future<bool> pianoNoteOff({required int note}) async {
    final result = await _as.pianoNoteOff(note: note);
    _logger.t('pianoNoteOff(note: $note): $result');
    return result;
  }

  @override
  Future<bool> pianoSetVolume({required double volume}) async {
    final result = await _as.pianoSetVolume(volume: volume);
    _logger.t('pianoSetVolume(volume: $volume): $result');
    return result;
  }

  @override
  Future<int> getSampleRate() async {
    final result = await _as.getSampleRate();
    _logger.t('getSampleRate(): $result');
    return result;
  }

  @override
  Future<bool> debugTestFunction() async {
    final result = await _as.debugTestFunction();
    _logger.t('debugTestFunction(): $result');
    return result;
  }
}
