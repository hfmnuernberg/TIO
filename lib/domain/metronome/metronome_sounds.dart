import 'dart:async';

import 'package:flutter/services.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/metronome_sound.dart';
import 'package:tiomusic/pages/metronome/setting_metronome_sound.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';

class MetronomeSounds {
  final AudioSystem _as;
  final FileSystem _fs;

  MetronomeSounds(this._as, this._fs);

  Future<void> loadAllSounds(MetronomeBlock block) async {
    await loadPrimarySounds(block);
    await loadSecondarySounds(block);
  }

  Future<void> loadPrimarySounds(MetronomeBlock block) async => Future.wait([
    _loadSound(BeatSound.Accented, block.accSound, '_a'),
    _loadSound(BeatSound.Unaccented, block.unaccSound),
    _loadSound(BeatSound.PolyAccented, block.polyAccSound, '_a'),
    _loadSound(BeatSound.PolyUnaccented, block.polyUnaccSound),
  ]);

  Future<void> loadSecondarySounds(MetronomeBlock block) async => Future.wait([
    _loadSound(BeatSound.Accented2, block.accSound2, '_a'),
    _loadSound(BeatSound.Unaccented2, block.unaccSound2),
    _loadSound(BeatSound.PolyAccented2, block.polyAccSound2, '_a'),
    _loadSound(BeatSound.PolyUnaccented2, block.polyUnaccSound2),
  ]);

  Future<void> loadSecondarySoundsAsPrimary(MetronomeBlock block) async => Future.wait([
    _loadSound(BeatSound.Accented, block.accSound2, '_a'),
    _loadSound(BeatSound.Unaccented, block.unaccSound2),
    _loadSound(BeatSound.PolyAccented, block.polyAccSound2, '_a'),
    _loadSound(BeatSound.PolyUnaccented, block.polyUnaccSound2),
  ]);

  Future<void> loadSound(bool isSecondary, SoundType soundType, String soundFilename) async =>
      _loadSound(_getBeatSound(soundType, isSecondary), soundFilename, _getSuffix(soundType));

  BeatSound _getBeatSound(SoundType soundType, bool isSecondary) {
    switch (soundType) {
      case SoundType.accented:
        return isSecondary ? BeatSound.Accented2 : BeatSound.Accented;
      case SoundType.unaccented:
        return isSecondary ? BeatSound.Unaccented2 : BeatSound.Unaccented;
      case SoundType.polyAccented:
        return isSecondary ? BeatSound.PolyAccented2 : BeatSound.PolyAccented;
      case SoundType.polyUnaccented:
        return isSecondary ? BeatSound.PolyUnaccented2 : BeatSound.PolyUnaccented;
    }
  }

  String _getSuffix(SoundType soundType) =>
      soundType == SoundType.accented || soundType == SoundType.polyAccented ? '_a' : '';

  Future<bool> _loadSound(BeatSound beatSound, String soundFilename, [String suffix = '']) async {
    String tempPathAcc = await _copyAssetToTemp('${MetronomeSound.fromFilename(soundFilename).file}$suffix.wav');
    return _as.metronomeLoadFile(beatType: beatSound, wavFilePath: tempPathAcc);
  }

  Future<String> _copyAssetToTemp(String assetPath) async {
    final tempAssetPath = '${_fs.tmpFolderPath}/${assetPath.split('/').last}';
    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    await _fs.saveFileAsBytes(tempAssetPath, bytes);
    return tempAssetPath;
  }
}
