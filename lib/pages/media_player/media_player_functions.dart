import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/sound_font.dart';
import 'package:tiomusic/services/audio_session.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/wakelock.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/log.dart';

abstract class MediaPlayerFunctions {
  static final _logger = createPrefixLogger('MediaPlayerFunctions');

  static void setSpeedAndPitchInRust(AudioSystem as, double speedFactor, double pitchSemitones) {
    as
        .mediaPlayerSetSpeedFactor(speedFactor: speedFactor)
        .then(
          (success) => {
            if (!success) {throw 'Setting speed factor in rust failed using this value: $speedFactor'},
          },
        );
    as
        .mediaPlayerSetPitchSemitones(pitchSemitones: pitchSemitones)
        .then(
          (success) => {
            if (!success) {throw 'Setting pitch semitones in rust failed using this value: $pitchSemitones'},
          },
        );
  }

  static Future<Float32List?> _setAudioFileAndTrimInRust(
    AudioSystem as,
    FileSystem fs,
    String absoluteFilePath,
    double startFactor,
    double endFactor,
    int numberOfBins,
  ) async {
    print('++++++++++++++ Setting audio file in Rust: $absoluteFilePath');
    final isMidi = absoluteFilePath.toLowerCase().endsWith('.mid');
    final pathForPlayer = isMidi ? (await _renderMidiToTempWav(as, fs, absoluteFilePath)) : absoluteFilePath;
    print('++++++++++++++ Path for player: $pathForPlayer, isMidi: $isMidi');

    if (pathForPlayer == null) return null;

    var success = await as.mediaPlayerLoadWav(wavFilePath: pathForPlayer);
    if (success) {
      as.mediaPlayerSetTrim(startFactor: startFactor, endFactor: endFactor);
      var tempRmsList = await as.mediaPlayerGetRms(nBins: numberOfBins);
      return _normalizeRms(tempRmsList);
    }
    return null;
  }

  static Future<String?> _renderMidiToTempWav(AudioSystem as, FileSystem fs, String midiAbs) async {
    // Sample rate comes from the audio engine, not the file system.
    final sampleRate = await as.getSampleRate();

    // Build a temp WAV path under the FileSystem's tmp folder.
    final ts = DateTime.now().millisecondsSinceEpoch;
    final base = fs.toBasename(midiAbs).replaceAll(RegExp(r'[^\w.-]'), '_');
    final tmpDir = fs.tmpFolderPath;
    await fs.createFolder(tmpDir);
    final tmpWavAbs = '$tmpDir/$base.$ts.rendered.wav';

    // Resolve a SoundFont (.sf2) file to synthesize the MIDI.
    final sf2Abs = await _resolveSoundFontPath(fs);
    if (sf2Abs == null) {
      return null; // Let caller show an error dialog.
    }

    final ok = await as.mediaPlayerRenderMidiToWav(
      midiPath: midiAbs,
      soundFontPath: sf2Abs,
      wavOutPath: tmpWavAbs,
      sampleRate: sampleRate,
      gain: 0.7,
    );
    return ok ? tmpWavAbs : null;
  }

  static Future<String?> _resolveSoundFontPath(
    FileSystem fs, {
    SoundFont? soundFont, // if null, fall back to a sensible default
  }) async {
    // Decide which asset path to load, preferring the caller-provided enum
    final assetPath = soundFont != null
        ? _soundFontAssetFromEnum(soundFont)
        : 'assets/sound_fonts/piano_01.sf2'; // default fallback you already use in Piano

    try {
      // Copy bundled asset into a readable file path for Rust
      final data = await rootBundle.load(assetPath);
      final tmpDir = fs.tmpFolderPath;
      await fs.createFolder(tmpDir);
      final fileName = assetPath.split('/').last;
      final outPath = '$tmpDir/$fileName';
      final outFile = File(outPath);
      await outFile.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
      return outPath;
    } catch (e, st) {
      _logger.e('Failed to load SoundFont asset at "$assetPath": $e\n$st');
      return null;
    }
  }

  static String _soundFontAssetFromEnum(SoundFont sf) {
    switch (sf) {
      // TODO: Extend this mapping with your actual enum values
      // Example guesses — adjust to your real names:
      case SoundFont.piano1:
        return 'assets/sound_fonts/piano_01.sf2';
      // Add more cases here:
      // case SoundFont.fluidR3:
      //   return 'assets/sound_fonts/FluidR3_GM.sf2';
      default:
        return 'assets/sound_fonts/piano_01.sf2';
    }
  }

  static Float32List _normalizeRms(Float32List rmsList) {
    Float32List newList = Float32List(rmsList.length);
    var minValue = rmsList.reduce(min);
    var maxValue = rmsList.reduce(max);
    if (minValue == maxValue) return newList;

    for (int i = 0; i < rmsList.length; i++) {
      newList[i] = (rmsList[i] - minValue) / (maxValue - minValue);
    }
    return newList;
  }

  static Future<bool> startPlaying(
    AudioSystem as,
    AudioSession audioSession,
    Wakelock wakelock,
    bool repeatOne,
    bool hasMarkers,
  ) async {
    await stopRecording(as, wakelock);
    await as.mediaPlayerSetRepeat(repeatOne: repeatOne);
    await audioSession.preparePlayback();

    if (hasMarkers) {
      await as.generatorStop();
      await as.generatorStart();
    }

    var success = await as.mediaPlayerStart();
    if (success) {
      await wakelock.enable();
    }
    return success;
  }

  static Future<bool> stopPlaying(AudioSystem as, Wakelock wakelock) async {
    await wakelock.disable();
    return as.mediaPlayerStop();
  }

  static Future<bool> startRecording(
    AudioSystem as,
    AudioSession audioSession,
    Wakelock wakelock,
    bool isPlaying,
  ) async {
    if (isPlaying) {
      await stopPlaying(as, wakelock);
      await Future.delayed(const Duration(milliseconds: TIOMusicParams.millisecondsPlayPauseDebounce));
    }

    if (!await Permission.microphone.request().isGranted) {
      _logger.w('Failed to get microphone permissions.');
      return false;
    }

    await audioSession.prepareRecording();
    var success = await as.mediaPlayerStartRecording();
    if (success) {
      await wakelock.enable();
    }
    return success;
  }

  static Future<bool> stopRecording(AudioSystem as, Wakelock wakelock) async {
    await wakelock.disable();
    return as.mediaPlayerStopRecording();
  }

  static Future<Float32List?> openAudioFileInRustAndGetRMSValues(
    AudioSystem as,
    FileSystem fs,
    MediaPlayerBlock block,
    int numOfBins,
  ) async {
    print('++++++++++++++ Opening audio file: ${block.relativePath}');
    final absolutePath = fs.toAbsoluteFilePath(block.relativePath);
    if (!fs.existsFile(absolutePath)) return null;

    final newRms = await _setAudioFileAndTrimInRust(as, fs, absolutePath, block.rangeStart, block.rangeEnd, numOfBins);
    print('++++++++++++++ Audio file opened: ${newRms.toString()}');
    return newRms;
  }

  static Widget displayRecordingTimer(String label, String duration, double height) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(color: ColorTheme.tertiary, fontSize: height / 10),
          ),
          Text(
            duration,
            style: TextStyle(color: ColorTheme.tertiary, fontSize: height / 6),
          ),
        ],
      ),
    );
  }
}
