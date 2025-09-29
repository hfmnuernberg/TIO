import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/services/audio_session.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/wakelock.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/log.dart';

abstract class MediaPlayerFunctions {
  static final _logger = createPrefixLogger('MediaPlayerFunctions');

  static void setSpeedAndPitchInRust(
    AudioSystem as,
    double speedFactor,
    double pitchSemitones, {
    PlayerId playerId = kDefaultPlayerId,
  }) {
    as
        .mediaPlayerSetSpeedFactor(speedFactor: speedFactor, playerId: playerId)
        .then((success) => {if (!success) throw 'Setting speed factor in rust failed using this value: $speedFactor'});
    as
        .mediaPlayerSetPitchSemitones(pitchSemitones: pitchSemitones, playerId: playerId)
        .then(
          (success) => {if (!success) throw 'Setting pitch semitones in rust failed using this value: $pitchSemitones'},
        );
  }

  static Future<Float32List?> _setAudioFileAndTrimInRust(
    AudioSystem as,
    String absoluteFilePath,
    double startFactor,
    double endFactor,
    int numberOfBins, {
    PlayerId playerId = kDefaultPlayerId,
  }) async {
    final success = await as.mediaPlayerLoadWav(wavFilePath: absoluteFilePath, playerId: playerId);
    _logger.t('[MP] loadFile ok=$success');
    if (!success) return null;

    await as.mediaPlayerSetTrim(startFactor: startFactor, endFactor: endFactor, playerId: playerId);
    _logger.t('[MP] setTrim done start=$startFactor end=$endFactor');

    final tempRmsList = await as
        .mediaPlayerGetRms(nBins: numberOfBins, playerId: playerId)
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            _logger.e('[MP] getRms timeout after 15s (bins=$numberOfBins)');
            throw 'getRms timeout';
          },
        );
    _logger.t('[MP] getRms done len=${tempRmsList.length}');
    return _normalizeRms(tempRmsList);
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
    bool hasMarkers, {
    PlayerId playerId = kDefaultPlayerId,
  }) async {
    await stopRecording(as, wakelock);
    await as.mediaPlayerSetRepeat(repeatOne: repeatOne, playerId: playerId);
    await audioSession.preparePlayback();
    await audioSession.start();

    if (hasMarkers) {
      await as.generatorStop();
      await as.generatorStart();
    }

    final success = await as.mediaPlayerStart(playerId: playerId);
    if (success) await wakelock.enable();
    return success;
  }

  static Future<bool> stopPlaying(
    AudioSystem as,
    AudioSession audioSession,
    Wakelock wakelock, {
    PlayerId playerId = kDefaultPlayerId,
  }) async {
    // await wakelock.disable();
    // return as.mediaPlayerStop(playerId: playerId);
    final ok = await as.mediaPlayerStop(playerId: playerId);
    await audioSession.stop();
    return ok;
  }

  static Future<bool> startRecording(
    AudioSystem as,
    AudioSession audioSession,
    Wakelock wakelock,
    bool isPlaying,
  ) async {
    if (isPlaying) {
      await stopPlaying(as, audioSession, wakelock);
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
    int numOfBins, {
    PlayerId playerId = kDefaultPlayerId,
  }) async {
    final absolutePath = fs.toAbsoluteFilePath(block.relativePath);
    if (!fs.existsFile(absolutePath)) return null;

    return _setAudioFileAndTrimInRust(
      as,
      absolutePath,
      block.rangeStart,
      block.rangeEnd,
      numOfBins,
      playerId: playerId,
    );
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
