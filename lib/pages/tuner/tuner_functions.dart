import 'package:permission_handler/permission_handler.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/util/audio_util.dart';
import 'package:tiomusic/util/log.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

abstract class TunerFunctions {
  static final _logger = createPrefixLogger('TunerFunctions');

  static Future<bool> start() async {
    if (await Permission.microphone.request().isGranted) {
      await configureAudioSession(AudioSessionType.record);
      var success = await tunerStart();
      if (success) {
        await WakelockPlus.enable();
      }
      return success;
    } else {
      _logger.w('Unable to get microphone permissions.');
      return false;
    }
  }

  static Future<bool> stop() async {
    await WakelockPlus.disable();
    return tunerStop();
  }

  static Future<bool> startGenerator() async {
    await configureAudioSession(AudioSessionType.playback);
    return generatorStart();
  }

  static Future<bool> stopGenerator() async {
    await generatorNoteOff();
    await Future.delayed(const Duration(milliseconds: 70));
    return generatorStop();
  }
}
