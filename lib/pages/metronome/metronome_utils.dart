import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/metronome_sound.dart';
import 'package:tiomusic/pages/metronome/setting_metronome_sound.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/src/rust/api/modules/metronome.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/metronome/current_beat.dart';

abstract class MetronomeUtils {
  static CurrentBeat getCurrentPrimaryBeatFromEvent({
    required bool isOn,
    required BeatHappenedEvent event,
    CurrentBeat currentBeat = const CurrentBeat(),
  }) {
    if (!isOn) return CurrentBeat();
    if (event.isSecondary) return currentBeat;
    return CurrentBeat(
      segmentIndex: event.barIndex,
      mainBeatIndex: event.isPoly ? currentBeat.mainBeatIndex : event.beatIndex,
      polyBeatIndex: event.isPoly ? event.beatIndex : currentBeat.polyBeatIndex,
    );
  }

  static CurrentBeat getCurrentSecondaryBeatFromEvent({
    required bool isOn,
    required BeatHappenedEvent event,
    CurrentBeat currentBeat = const CurrentBeat(),
  }) {
    if (!isOn) return CurrentBeat();
    if (!event.isSecondary) return currentBeat;
    return CurrentBeat(
      segmentIndex: event.barIndex,
      mainBeatIndex: event.isPoly ? currentBeat.mainBeatIndex : event.beatIndex,
      polyBeatIndex: event.isPoly ? event.beatIndex : currentBeat.polyBeatIndex,
    );
  }

  static void loadSounds(AudioSystem as, FileSystem fs, MetronomeBlock block) async {
    String tempPathAcc = await copyAssetToTemp(fs, '${MetronomeSound.fromFilename(block.accSound).file}_a.wav');
    String tempPathUnacc = await copyAssetToTemp(fs, '${MetronomeSound.fromFilename(block.unaccSound).file}.wav');
    String tempPathPolyAcc = await copyAssetToTemp(fs, '${MetronomeSound.fromFilename(block.polyAccSound).file}_a.wav');
    String tempPathPolyUnacc = await copyAssetToTemp(
      fs,
      '${MetronomeSound.fromFilename(block.polyUnaccSound).file}.wav',
    );
    String tempPathAcc2 = await copyAssetToTemp(fs, '${MetronomeSound.fromFilename(block.accSound2).file}_a.wav');
    String tempPathUnacc2 = await copyAssetToTemp(fs, '${MetronomeSound.fromFilename(block.unaccSound2).file}.wav');
    String tempPathPolyAcc2 = await copyAssetToTemp(
      fs,
      '${MetronomeSound.fromFilename(block.polyAccSound2).file}_a.wav',
    );
    String tempPathPolyUnacc2 = await copyAssetToTemp(
      fs,
      '${MetronomeSound.fromFilename(block.polyUnaccSound2).file}.wav',
    );

    as.metronomeLoadFile(beatType: BeatSound.Accented, wavFilePath: tempPathAcc);
    as.metronomeLoadFile(beatType: BeatSound.Unaccented, wavFilePath: tempPathUnacc);
    as.metronomeLoadFile(beatType: BeatSound.PolyAccented, wavFilePath: tempPathPolyAcc);
    as.metronomeLoadFile(beatType: BeatSound.PolyUnaccented, wavFilePath: tempPathPolyUnacc);
    as.metronomeLoadFile(beatType: BeatSound.Accented2, wavFilePath: tempPathAcc2);
    as.metronomeLoadFile(beatType: BeatSound.Unaccented2, wavFilePath: tempPathUnacc2);
    as.metronomeLoadFile(beatType: BeatSound.PolyAccented2, wavFilePath: tempPathPolyAcc2);
    as.metronomeLoadFile(beatType: BeatSound.PolyUnaccented2, wavFilePath: tempPathPolyUnacc2);
  }

  static void loadMetro2SoundsIntoMetro1(AudioSystem as, FileSystem fs, MetronomeBlock block) async {
    String tempPathAcc2 = await copyAssetToTemp(fs, '${MetronomeSound.fromFilename(block.accSound2).file}_a.wav');
    String tempPathUnacc2 = await copyAssetToTemp(fs, '${MetronomeSound.fromFilename(block.unaccSound2).file}.wav');
    String tempPathPolyAcc2 = await copyAssetToTemp(
      fs,
      '${MetronomeSound.fromFilename(block.polyAccSound2).file}_a.wav',
    );
    String tempPathPolyUnacc2 = await copyAssetToTemp(
      fs,
      '${MetronomeSound.fromFilename(block.polyUnaccSound2).file}.wav',
    );

    as.metronomeLoadFile(beatType: BeatSound.Accented, wavFilePath: tempPathAcc2);
    as.metronomeLoadFile(beatType: BeatSound.Unaccented, wavFilePath: tempPathUnacc2);
    as.metronomeLoadFile(beatType: BeatSound.PolyAccented, wavFilePath: tempPathPolyAcc2);
    as.metronomeLoadFile(beatType: BeatSound.PolyUnaccented, wavFilePath: tempPathPolyUnacc2);
  }

  // load a specific sound
  static void loadSound(AudioSystem as, FileSystem fs, bool isSecondMetronome, SoundType soundType, String file) async {
    BeatSound beatType;
    if (isSecondMetronome) {
      switch (soundType) {
        case SoundType.accented:
          beatType = BeatSound.Accented2;
        case SoundType.unaccented:
          beatType = BeatSound.Unaccented2;
        case SoundType.polyAccented:
          beatType = BeatSound.PolyAccented2;
        case SoundType.polyUnaccented:
          beatType = BeatSound.PolyUnaccented2;
      }
    } else {
      switch (soundType) {
        case SoundType.accented:
          beatType = BeatSound.Accented;
        case SoundType.unaccented:
          beatType = BeatSound.Unaccented;
        case SoundType.polyAccented:
          beatType = BeatSound.PolyAccented;
        case SoundType.polyUnaccented:
          beatType = BeatSound.PolyUnaccented;
      }
    }

    final suffix = soundType == SoundType.accented || soundType == SoundType.polyAccented ? '_a' : '';

    String wavFilePath = await copyAssetToTemp(fs, '${MetronomeSound.fromFilename(file + suffix).file}.wav');
    as.metronomeLoadFile(beatType: beatType, wavFilePath: wavFilePath);
  }
}
