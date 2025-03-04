import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/util/audio_util.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

abstract class MetronomeFunctions {
  static Future<bool> start() async {
    await configureAudioSession(AudioSessionType.playback);
    var success = await metronomeStart();
    if (success) {
      await WakelockPlus.enable();
    }
    return success;
  }

  static Future<bool> stop() async {
    await WakelockPlus.disable();
    return metronomeStop();
  }
}
