import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tiomusic/rust_api/ffi.dart';
import 'package:tiomusic/util/audio_util.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

abstract class TunerFunctions {
  static Future<bool> start() async {
    if (await Permission.microphone.request().isGranted) {
      await configureAudioSession(AudioSessionType.record);
      var success = await rustApi.tunerStart();
      if (success) {
        await WakelockPlus.enable();
      }
      return success;
    } else {
      debugPrint("failed to get mic permissions");
      return false;
    }
  }

  static Future<bool> stop() async {
    await WakelockPlus.disable();
    return await rustApi.tunerStop();
  }

  static Future<bool> generatorStart() async {
    await configureAudioSession(AudioSessionType.playback);
    return await rustApi.generatorStart();
  }

  static Future<bool> generatorStop() async {
    await rustApi.generatorNoteOff();
    await Future.delayed(const Duration(milliseconds: 70));
    return await rustApi.generatorStop();
  }
}
