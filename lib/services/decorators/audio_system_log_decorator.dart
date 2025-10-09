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
  Future<bool> mediaPlayerLoadWav({required String wavFilePath, PlayerId playerId = kDefaultPlayerId}) async {
    final result = await _as.mediaPlayerLoadWav(wavFilePath: wavFilePath, playerId: playerId);
    _logger.t('mediaPlayerLoadWav(wavFilePath: $wavFilePath, playerId: $playerId): $result');
    return result;
  }

  @override
  Future<bool> mediaPlayerStart({PlayerId playerId = kDefaultPlayerId}) async {
    final result = await _as.mediaPlayerStart(playerId: playerId);
    _logger.t('mediaPlayerStart(playerId: $playerId): $result');
    return result;
  }

  @override
  Future<bool> mediaPlayerStop({PlayerId playerId = kDefaultPlayerId}) async {
    final result = await _as.mediaPlayerStop(playerId: playerId);
    _logger.t('mediaPlayerStop(playerId: $playerId): $result');
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
  Future<bool> mediaPlayerSetPitchSemitones({
    required double pitchSemitones,
    PlayerId playerId = kDefaultPlayerId,
  }) async {
    final result = await _as.mediaPlayerSetPitchSemitones(pitchSemitones: pitchSemitones, playerId: playerId);
    _logger.t('mediaPlayerSetPitchSemitones(pitchSemitones: $pitchSemitones, playerId: $playerId): $result');
    return result;
  }

  @override
  Future<bool> mediaPlayerSetSpeedFactor({required double speedFactor, PlayerId playerId = kDefaultPlayerId}) async {
    final result = await _as.mediaPlayerSetSpeedFactor(speedFactor: speedFactor, playerId: playerId);
    _logger.t('mediaPlayerSetSpeedFactor(speedFactor: $speedFactor, playerId: $playerId): $result');
    return result;
  }

  @override
  Future<void> mediaPlayerSetTrim({
    required double startFactor,
    required double endFactor,
    PlayerId playerId = kDefaultPlayerId,
  }) async {
    await _as.mediaPlayerSetTrim(startFactor: startFactor, endFactor: endFactor, playerId: playerId);
    _logger.t('mediaPlayerSetTrim(startFactor: $startFactor, endFactor: $endFactor, playerId: $playerId)');
  }

  @override
  Future<Float32List> mediaPlayerGetRms({required int nBins, PlayerId playerId = kDefaultPlayerId}) async {
    final result = await _as.mediaPlayerGetRms(nBins: nBins, playerId: playerId);
    _logger.t('mediaPlayerGetRms(nBins: $nBins, playerId: $playerId): Float32List(length=${result.length})');
    return result;
  }

  @override
  Future<void> mediaPlayerSetRepeat({required bool repeatOne, PlayerId playerId = kDefaultPlayerId}) async {
    await _as.mediaPlayerSetRepeat(repeatOne: repeatOne, playerId: playerId);
    _logger.t('mediaPlayerSetRepeat(repeatOne: $repeatOne, playerId: $playerId)');
  }

  @override
  Future<MediaPlayerState?> mediaPlayerGetState({PlayerId playerId = kDefaultPlayerId}) async {
    final result = await _as.mediaPlayerGetState(playerId: playerId);
    _logger.t('mediaPlayerGetState(playerId: $playerId): $result');
    return result;
  }

  @override
  Future<bool> mediaPlayerSetPlaybackPosFactor({
    required double posFactor,
    PlayerId playerId = kDefaultPlayerId,
  }) async {
    final result = await _as.mediaPlayerSetPlaybackPosFactor(posFactor: posFactor, playerId: playerId);
    _logger.t('mediaPlayerSetPlaybackPosFactor(posFactor: $posFactor, playerId: $playerId): $result');
    return result;
  }

  @override
  Future<bool> mediaPlayerSetVolume({required double volume, PlayerId playerId = kDefaultPlayerId}) async {
    final result = await _as.mediaPlayerSetVolume(volume: volume, playerId: playerId);
    _logger.t('mediaPlayerSetVolume(volume: $volume, playerId: $playerId): $result');
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
