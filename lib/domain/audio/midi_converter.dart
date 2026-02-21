import 'dart:io';

import 'package:flutter/services.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/util/log.dart';

class MidiConverter {
  static final logger = createPrefixLogger('MidiConverter');

  final AudioSystem _as;
  final FileSystem _fs;

  MidiConverter(this._as, this._fs);

  Future<String?> convertToWav(String absoluteMidiFilePath) async {
    final sampleRate = await _as.getSampleRate();

    final ts = DateTime.now().millisecondsSinceEpoch;
    final base = _fs.toBasename(absoluteMidiFilePath).replaceAll(RegExp(r'[^\w.-]'), '_');
    final tmpDir = _fs.tmpFolderPath;
    await _fs.createFolder(tmpDir);
    final tmpWavAbs = '$tmpDir/$base.$ts.rendered.wav';

    final sf2Abs = await _resolveSoundFontPath();
    if (sf2Abs == null) return null;

    final success = await _as.mediaPlayerRenderMidiToWav(
      midiPath: absoluteMidiFilePath,
      soundFontPath: sf2Abs,
      wavOutPath: tmpWavAbs,
      sampleRate: sampleRate,
      gain: 0.7,
    );
    return success ? tmpWavAbs : null;
  }

  Future<String?> _resolveSoundFontPath() async {
    const assetPath = 'assets/sound_fonts/piano_01.sf2';
    final tmpDir = _fs.tmpFolderPath;
    await _fs.createFolder(tmpDir);
    final fileName = assetPath.split('/').last;
    final outPath = '$tmpDir/$fileName';

    if (_fs.existsFile(outPath)) return outPath;

    try {
      final data = await rootBundle.load(assetPath);
      final outFile = File(outPath);
      await outFile.writeAsBytes(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes), flush: true);
      return outPath;
    } catch (e, st) {
      logger.e('Failed to load SoundFont asset at "$assetPath": $e\n$st');
      return null;
    }
  }
}
