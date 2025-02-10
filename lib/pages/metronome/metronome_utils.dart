import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/pages/metronome/setting_metronome_sound.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';

import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';

abstract class MetronomeUtils {
  // This function takes the currently selected sounds of the metronome block and loads them in rust
  static void loadSounds(MetronomeBlock block) async {
    String tempPathAcc =
        await copyAssetToTemp("${MetronomeParams.metronomeSoundsPath}/${block.accSound.toLowerCase()}_a.wav");
    String tempPathUnacc =
        await copyAssetToTemp("${MetronomeParams.metronomeSoundsPath}/${block.unaccSound.toLowerCase()}.wav");
    String tempPathPolyAcc =
        await copyAssetToTemp("${MetronomeParams.metronomeSoundsPath}/${block.polyAccSound.toLowerCase()}_a.wav");
    String tempPathPolyUnacc =
        await copyAssetToTemp("${MetronomeParams.metronomeSoundsPath}/${block.polyUnaccSound.toLowerCase()}.wav");
    String tempPathAcc2 =
        await copyAssetToTemp("${MetronomeParams.metronomeSoundsPath}/${block.accSound2.toLowerCase()}_a.wav");
    String tempPathUnacc2 =
        await copyAssetToTemp("${MetronomeParams.metronomeSoundsPath}/${block.unaccSound2.toLowerCase()}.wav");
    String tempPathPolyAcc2 =
        await copyAssetToTemp("${MetronomeParams.metronomeSoundsPath}/${block.polyAccSound2.toLowerCase()}_a.wav");
    String tempPathPolyUnacc2 =
        await copyAssetToTemp("${MetronomeParams.metronomeSoundsPath}/${block.polyUnaccSound2.toLowerCase()}.wav");

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
    String tempPathAcc2 =
        await copyAssetToTemp("${MetronomeParams.metronomeSoundsPath}/${block.accSound2.toLowerCase()}_a.wav");
    String tempPathUnacc2 =
        await copyAssetToTemp("${MetronomeParams.metronomeSoundsPath}/${block.unaccSound2.toLowerCase()}.wav");
    String tempPathPolyAcc2 =
        await copyAssetToTemp("${MetronomeParams.metronomeSoundsPath}/${block.polyAccSound2.toLowerCase()}_a.wav");
    String tempPathPolyUnacc2 =
        await copyAssetToTemp("${MetronomeParams.metronomeSoundsPath}/${block.polyUnaccSound2.toLowerCase()}.wav");

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
          break;
        case SoundType.unaccented:
          beatType = BeatSound.Unaccented2;
          break;
        case SoundType.polyAccented:
          beatType = BeatSound.PolyAccented2;
          break;
        case SoundType.polyUnaccented:
          beatType = BeatSound.PolyUnaccented2;
          break;
      }
    } else {
      switch (soundType) {
        case SoundType.accented:
          beatType = BeatSound.Accented;
          break;
        case SoundType.unaccented:
          beatType = BeatSound.Unaccented;
          break;
        case SoundType.polyAccented:
          beatType = BeatSound.PolyAccented;
          break;
        case SoundType.polyUnaccented:
          beatType = BeatSound.PolyUnaccented;
          break;
      }
    }

    if (soundType == SoundType.accented || soundType == SoundType.polyAccented) {
      file = "${file}_a";
    }

    String wavFilePath = await copyAssetToTemp("${MetronomeParams.metronomeSoundsPath}/$file.wav");
    metronomeLoadFile(beatType: beatType, wavFilePath: wavFilePath);
  }
}
