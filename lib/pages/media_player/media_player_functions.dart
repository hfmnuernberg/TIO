import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tiomusic/services/audio_session.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/wakelock.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/log.dart';

abstract class MediaPlayerFunctions {
  static final _logger = createPrefixLogger('MediaPlayerFunctions');

  static Future<bool> startRecording(
    AudioSystem as,
    AudioSession audioSession,
    Wakelock wakelock,
    bool isPlaying,
  ) async {
    if (isPlaying) {
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
