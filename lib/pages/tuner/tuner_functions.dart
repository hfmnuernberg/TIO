import 'package:permission_handler/permission_handler.dart';
import 'package:tiomusic/services/audio_session.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/wakelock.dart';
import 'package:tiomusic/util/log.dart';

abstract class TunerFunctions {
  static final _logger = createPrefixLogger('TunerFunctions');

  static Future<bool> start(AudioSystem as, AudioSession audioSession, Wakelock wakelock) async {
    if (await Permission.microphone.request().isGranted) {
      await audioSession.prepareRecording();
      var success = await as.tunerStart();
      if (success) {
        await wakelock.enable();
      }
      return success;
    } else {
      _logger.w('Unable to get microphone permissions.');
      return false;
    }
  }

  static Future<bool> stop(AudioSystem as, Wakelock wakelock) async {
    await wakelock.disable();
    return as.tunerStop();
  }

  static Future<bool> startGenerator(AudioSystem as, AudioSession audioSession) async {
    await audioSession.preparePlayback();
    return as.generatorStart();
  }

  static Future<bool> stopGenerator(AudioSystem as) async {
    await as.generatorNoteOff();
    await Future.delayed(const Duration(milliseconds: 70));
    return as.generatorStop();
  }
}
