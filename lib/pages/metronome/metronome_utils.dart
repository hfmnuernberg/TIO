import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/pages/metronome/setting_metronome_sound.dart';
import 'package:tiomusic/rust_api/ffi.dart';
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

    rustApi.metronomeLoadFile(beatType: BeatSound.Accented, wavFilePath: tempPathAcc);
    rustApi.metronomeLoadFile(beatType: BeatSound.Unaccented, wavFilePath: tempPathUnacc);
    rustApi.metronomeLoadFile(beatType: BeatSound.PolyAccented, wavFilePath: tempPathPolyAcc);
    rustApi.metronomeLoadFile(beatType: BeatSound.PolyUnaccented, wavFilePath: tempPathPolyUnacc);
    rustApi.metronomeLoadFile(beatType: BeatSound.Accented2, wavFilePath: tempPathAcc2);
    rustApi.metronomeLoadFile(beatType: BeatSound.Unaccented2, wavFilePath: tempPathUnacc2);
    rustApi.metronomeLoadFile(beatType: BeatSound.PolyAccented2, wavFilePath: tempPathPolyAcc2);
    rustApi.metronomeLoadFile(beatType: BeatSound.PolyUnaccented2, wavFilePath: tempPathPolyUnacc2);
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

    rustApi.metronomeLoadFile(beatType: BeatSound.Accented, wavFilePath: tempPathAcc2);
    rustApi.metronomeLoadFile(beatType: BeatSound.Unaccented, wavFilePath: tempPathUnacc2);
    rustApi.metronomeLoadFile(beatType: BeatSound.PolyAccented, wavFilePath: tempPathPolyAcc2);
    rustApi.metronomeLoadFile(beatType: BeatSound.PolyUnaccented, wavFilePath: tempPathPolyUnacc2);
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
        default:
          throw Exception("Invalid sound type");
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
        default:
          throw Exception("Invalid sound type");
      }
    }

    if (soundType == SoundType.accented || soundType == SoundType.polyAccented) {
      file = "${file}_a";
    }

    String wavFilePath = await copyAssetToTemp("${MetronomeParams.metronomeSoundsPath}/$file.wav");
    rustApi.metronomeLoadFile(beatType: beatType, wavFilePath: wavFilePath);
  }
}
