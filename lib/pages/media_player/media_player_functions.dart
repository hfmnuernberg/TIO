import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/util/audio_util.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

abstract class MediaPlayerFunctions {
  static void setSpeedAndPitchInRust(double speedFactor, double pitchSemitones) {
    mediaPlayerSetSpeedFactor(speedFactor: speedFactor).then(
      (success) => {
        if (!success) {throw 'Setting speed factor in rust failed using this value: $speedFactor'},
      },
    );
    mediaPlayerSetPitchSemitones(pitchSemitones: pitchSemitones).then(
      (success) => {
        if (!success) {throw 'Setting pitch semitones in rust failed using this value: $pitchSemitones'},
      },
    );
  }

  static Future<Float32List?> _setAudioFileAndTrimInRust(
    String absoluteFilePath,
    double startFactor,
    double endFactor,
    int numberOfBins,
  ) async {
    var success = await mediaPlayerLoadWav(wavFilePath: absoluteFilePath);
    if (success) {
      mediaPlayerSetTrim(startFactor: startFactor, endFactor: endFactor);

      var tempRmsList = await mediaPlayerGetRms(nBins: numberOfBins);
      return _normalizeRms(tempRmsList);
    }
    return null;
  }

  static Float32List _normalizeRms(Float32List rmsList) {
    Float32List newList = Float32List(rmsList.length);
    var minValue = rmsList.reduce(min);
    var maxValue = rmsList.reduce(max);
    for (int i = 0; i < rmsList.length; i++) {
      newList[i] = (rmsList[i] - minValue) / (maxValue - minValue);
    }
    return newList;
  }

  static Future<bool> startPlaying(bool looping) async {
    await stopRecording();
    await mediaPlayerSetLoop(looping: looping);
    await configureAudioSession(AudioSessionType.playback);
    var success = await mediaPlayerStart();
    if (success) {
      await WakelockPlus.enable();
    }
    return success;
  }

  static Future<bool> stopPlaying() async {
    await WakelockPlus.disable();
    return mediaPlayerStop();
  }

  static Future<bool> startRecording(bool isPlaying) async {
    if (isPlaying) {
      await stopPlaying();
      await Future.delayed(const Duration(milliseconds: TIOMusicParams.millisecondsPlayPauseDebounce));
    }

    if (!await Permission.microphone.request().isGranted) {
      debugPrint('failed to get mic permissions (in starting Recording in Media Player)');
      return false;
    }

    await configureAudioSession(AudioSessionType.record);
    var success = await mediaPlayerStartRecording();
    if (success) {
      await WakelockPlus.enable();
    }
    return success;
  }

  static Future<bool> stopRecording() async {
    await WakelockPlus.disable();
    return mediaPlayerStopRecording();
  }

  static Future<String?> writeRecordingToFile(
    String newFileName,
    String? relativePathOfPreviousFile,
    ProjectLibrary projectLibrary,
  ) async {
    final samples = await mediaPlayerGetRecordingSamples();
    return FileIO.writeSamplesToWaveFile(samples, newFileName, relativePathOfPreviousFile, projectLibrary);
  }

  static Future<Float32List?> openAudioFileInRustAndGetRMSValues(MediaPlayerBlock block, int numOfBins) async {
    var absolutePath = await FileIO.getAbsoluteFilePath(block.relativePath);
    if (!File(absolutePath).existsSync()) return null;
    return _setAudioFileAndTrimInRust(absolutePath, block.rangeStart, block.rangeEnd, numOfBins);
  }

  static Widget displayRecordingTimer(String label, Duration duration, double height) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: ColorTheme.tertiary, fontSize: height / 10)),
          Text(getDurationFormated(duration), style: TextStyle(color: ColorTheme.tertiary, fontSize: height / 6)),
        ],
      ),
    );
  }
}
