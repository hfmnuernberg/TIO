import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/util/audio_util.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

abstract class MetronomeFunctions {
  static Future<bool> start(AudioSystem as) async {
    await configureAudioSession(AudioSessionType.playback);
    var success = await as.metronomeStart();
    if (success) {
      await WakelockPlus.enable();
    }
    return success;
  }

  static Future<bool> stop(AudioSystem as) async {
    await WakelockPlus.disable();
    return as.metronomeStop();
  }
}
