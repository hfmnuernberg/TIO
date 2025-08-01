import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/loop_mode.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/util/audio_util.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/log.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

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
    String absoluteFilePath,
    double startFactor,
    double endFactor,
    int numberOfBins,
  ) async {
    var success = await as.mediaPlayerLoadWav(wavFilePath: absoluteFilePath);
    if (success) {
      as.mediaPlayerSetTrim(startFactor: startFactor, endFactor: endFactor);

      var tempRmsList = await as.mediaPlayerGetRms(nBins: numberOfBins);
      return _normalizeRms(tempRmsList);
    }
    return null;
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

  static Future<bool> startPlaying(AudioSystem as, LoopMode loopMode, bool hasMarkers) async {
    await stopRecording(as);
    await as.mediaPlayerSetLoopOne(looping: loopMode == LoopMode.one);
    await configureAudioSession(AudioSessionType.playback);

    if (hasMarkers) {
      await as.generatorStop();
      await as.generatorStart();
    }

    var success = await as.mediaPlayerStart();
    if (success) await WakelockPlus.enable();
    return success;
  }

  static Future<void> stopPlaying(AudioSystem as) async {
    await WakelockPlus.disable();

    await as.generatorStop();

    final mediaPlayerStopSuccess = await as.mediaPlayerStop();
    if (!mediaPlayerStopSuccess) _logger.e('Unable to stop playing.');
  }

  static Future<bool> startRecording(AudioSystem as, bool isPlaying) async {
    if (isPlaying) {
      await stopPlaying(as);
      await Future.delayed(const Duration(milliseconds: TIOMusicParams.millisecondsPlayPauseDebounce));
    }

    if (!await Permission.microphone.request().isGranted) {
      _logger.w('Failed to get microphone permissions.');
      return false;
    }

    await configureAudioSession(AudioSessionType.record);
    var success = await as.mediaPlayerStartRecording();
    if (success) {
      await WakelockPlus.enable();
    }
    return success;
  }

  static Future<bool> stopRecording(AudioSystem as) async {
    await WakelockPlus.disable();
    return as.mediaPlayerStopRecording();
  }

  static Future<Float32List?> openAudioFileInRustAndGetRMSValues(
    AudioSystem as,
    FileSystem fs,
    MediaPlayerBlock block,
    int numOfBins,
  ) async {
    final absolutePath = fs.toAbsoluteFilePath(block.relativePath);
    if (!fs.existsFile(absolutePath)) return null;

    return _setAudioFileAndTrimInRust(as, absolutePath, block.rangeStart, block.rangeEnd, numOfBins);
  }

  static Widget displayRecordingTimer(String label, String duration, double height) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: ColorTheme.tertiary, fontSize: height / 10)),
          Text(duration, style: TextStyle(color: ColorTheme.tertiary, fontSize: height / 6)),
        ],
      ),
    );
  }
}
