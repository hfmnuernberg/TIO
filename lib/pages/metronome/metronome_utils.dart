import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/metronome_sound.dart';
import 'package:tiomusic/pages/metronome/setting_metronome_sound.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';
import 'package:tiomusic/util/util_functions.dart';

abstract class MetronomeUtils {
  // This function takes the currently selected sounds of the metronome block and loads them in rust
  static void loadSounds(MetronomeBlock block) async {
    String tempPathAcc = await copyAssetToTemp('${MetronomeSound.fromFilename(block.accSound).file}_a.wav');
    String tempPathUnacc = await copyAssetToTemp('${MetronomeSound.fromFilename(block.unaccSound).file}.wav');
    String tempPathPolyAcc = await copyAssetToTemp('${MetronomeSound.fromFilename(block.polyAccSound).file}_a.wav');
    String tempPathPolyUnacc = await copyAssetToTemp('${MetronomeSound.fromFilename(block.polyUnaccSound).file}.wav');
    String tempPathAcc2 = await copyAssetToTemp('${MetronomeSound.fromFilename(block.accSound2).file}_a.wav');
    String tempPathUnacc2 = await copyAssetToTemp('${MetronomeSound.fromFilename(block.unaccSound2).file}.wav');
    String tempPathPolyAcc2 = await copyAssetToTemp('${MetronomeSound.fromFilename(block.polyAccSound2).file}_a.wav');
    String tempPathPolyUnacc2 = await copyAssetToTemp('${MetronomeSound.fromFilename(block.polyUnaccSound2).file}.wav');

    metronomeLoadFile(beatType: BeatSound.Accented, wavFilePath: tempPathAcc);
    metronomeLoadFile(beatType: BeatSound.Unaccented, wavFilePath: tempPathUnacc);
    metronomeLoadFile(beatType: BeatSound.PolyAccented, wavFilePath: tempPathPolyAcc);
    metronomeLoadFile(beatType: BeatSound.PolyUnaccented, wavFilePath: tempPathPolyUnacc);
    metronomeLoadFile(beatType: BeatSound.Accented2, wavFilePath: tempPathAcc2);
    metronomeLoadFile(beatType: BeatSound.Unaccented2, wavFilePath: tempPathUnacc2);
    metronomeLoadFile(beatType: BeatSound.PolyAccented2, wavFilePath: tempPathPolyAcc2);
    metronomeLoadFile(beatType: BeatSound.PolyUnaccented2, wavFilePath: tempPathPolyUnacc2);
  }

  static void loadMetro2SoundsIntoMetro1(MetronomeBlock block) async {
    String tempPathAcc2 = await copyAssetToTemp('${MetronomeSound.fromFilename(block.accSound2).file}_a.wav');
    String tempPathUnacc2 = await copyAssetToTemp('${MetronomeSound.fromFilename(block.unaccSound2).file}.wav');
    String tempPathPolyAcc2 = await copyAssetToTemp('${MetronomeSound.fromFilename(block.polyAccSound2).file}_a.wav');
    String tempPathPolyUnacc2 = await copyAssetToTemp('${MetronomeSound.fromFilename(block.polyUnaccSound2).file}.wav');

    metronomeLoadFile(beatType: BeatSound.Accented, wavFilePath: tempPathAcc2);
    metronomeLoadFile(beatType: BeatSound.Unaccented, wavFilePath: tempPathUnacc2);
    metronomeLoadFile(beatType: BeatSound.PolyAccented, wavFilePath: tempPathPolyAcc2);
    metronomeLoadFile(beatType: BeatSound.PolyUnaccented, wavFilePath: tempPathPolyUnacc2);
  }

  // load a specific sound
  static void loadSound(bool isSecondMetronome, SoundType soundType, String file) async {
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

    if (soundType == SoundType.accented || soundType == SoundType.polyAccented) {
      file = '${file}_a';
    }

    String wavFilePath = await copyAssetToTemp('${MetronomeSound.fromFilename(file).file}.wav');
    metronomeLoadFile(beatType: beatType, wavFilePath: wavFilePath);
  }
}
