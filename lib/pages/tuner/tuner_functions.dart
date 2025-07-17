import 'package:permission_handler/permission_handler.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/wakelock.dart';
import 'package:tiomusic/util/audio_util.dart';
import 'package:tiomusic/util/log.dart';

abstract class TunerFunctions {
  static final _logger = createPrefixLogger('TunerFunctions');

  static Future<bool> start(AudioSystem as, Wakelock wl) async {
    if (await Permission.microphone.request().isGranted) {
      await configureAudioSession(AudioSessionType.record);
      var success = await as.tunerStart();
      if (success) {
        await wl.enable();
      }
      return success;
    } else {
      _logger.w('Unable to get microphone permissions.');
      return false;
    }
  }

  static Future<bool> stop(AudioSystem as, Wakelock wl) async {
    await wl.disable();
    return as.tunerStop();
  }

  static Future<bool> startGenerator(AudioSystem as) async {
    await configureAudioSession(AudioSessionType.playback);
    return as.generatorStart();
  }

  static Future<bool> stopGenerator(AudioSystem as) async {
    await as.generatorNoteOff();
    await Future.delayed(const Duration(milliseconds: 70));
    return as.generatorStop();
  }
}
