import 'dart:typed_data';

import 'package:tiomusic/src/rust/api/modules/media_player.dart';
import 'package:tiomusic/src/rust/api/modules/metronome.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';

typedef PlayerId = String;
const String kDefaultPlayerId = 'default';

mixin AudioSystem {
  Future<void> initAudio();

  Future<double?> tunerGetFrequency();
  Future<bool> tunerStart();
  Future<bool> tunerStop();

  Future<bool> generatorStart();
  Future<bool> generatorStop();
  Future<bool> generatorNoteOn({required double newFreq});
  Future<bool> generatorNoteOff();

  Future<bool> pianoSetConcertPitch({required double newConcertPitch});

  Future<bool> mediaPlayerLoadWav({required String wavFilePath, PlayerId playerId = kDefaultPlayerId});
  Future<bool> mediaPlayerStart({PlayerId playerId = kDefaultPlayerId});
  Future<bool> mediaPlayerStop({PlayerId playerId = kDefaultPlayerId});
  Future<bool> mediaPlayerStartRecording(); // (leave recording global)
  Future<bool> mediaPlayerStopRecording();
  Future<Float64List> mediaPlayerGetRecordingSamples();
  Future<bool> mediaPlayerSetPitchSemitones({required double pitchSemitones, PlayerId playerId = kDefaultPlayerId});
  Future<bool> mediaPlayerSetSpeedFactor({required double speedFactor, PlayerId playerId = kDefaultPlayerId});
  Future<void> mediaPlayerSetTrim({
    required double startFactor,
    required double endFactor,
    PlayerId playerId = kDefaultPlayerId,
  });
  Future<Float32List> mediaPlayerGetRms({required int nBins, PlayerId playerId = kDefaultPlayerId});
  Future<void> mediaPlayerSetRepeat({required bool repeatOne, PlayerId playerId = kDefaultPlayerId});
  Future<MediaPlayerState?> mediaPlayerGetState({PlayerId playerId = kDefaultPlayerId});
  Future<bool> mediaPlayerSetPlaybackPosFactor({required double posFactor, PlayerId playerId = kDefaultPlayerId});
  Future<bool> mediaPlayerSetVolume({required double volume, PlayerId playerId = kDefaultPlayerId});

  Future<bool> metronomeStart();
  Future<bool> metronomeStop();
  Future<bool> metronomeSetBpm({required double bpm});
  Future<bool> metronomeLoadFile({required BeatSound beatType, required String wavFilePath});
  Future<bool> metronomeSetRhythm({required List<MetroBar> bars, required List<MetroBar> bars2});
  Future<BeatHappenedEvent?> metronomePollBeatEventHappened();
  Future<bool> metronomeSetMuted({required bool muted});
  Future<bool> metronomeSetBeatMuteChance({required double muteChance});
  Future<bool> metronomeSetVolume({required double volume});

  Future<bool> pianoSetup({required String soundFontPath});
  Future<bool> pianoStart();
  Future<bool> pianoStop();
  Future<bool> pianoNoteOn({required int note});
  Future<bool> pianoNoteOff({required int note});
  Future<bool> pianoSetVolume({required double volume});

  Future<int> getSampleRate();
  Future<bool> debugTestFunction();
}
