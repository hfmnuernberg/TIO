import 'package:audio_session/audio_session.dart';
import 'package:tiomusic/util/log.dart';

/* These functions are used for microphone capture on ios via rust (cpal) */
/* An audio session has to be started before cpal can detect the built in microphone on ios */

Future<void> startAudioSession() async {
  final session = await AudioSession.instance;
  final success = await session.setActive(true);
  if (!success) logger.e('Unable to start audio session.');
}

enum AudioSessionType { playback, record }

Future<void> configureAudioSession(AudioSessionType type) async {
  final session = await AudioSession.instance;

  switch (type) {
    case AudioSessionType.playback:
      await session.configure(
        AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.defaultToSpeaker &
              AVAudioSessionCategoryOptions.allowBluetooth &
              AVAudioSessionCategoryOptions.allowAirPlay,
        ),
      );
    case AudioSessionType.record:
      await session.configure(
        AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.defaultToSpeaker &
              AVAudioSessionCategoryOptions.allowBluetooth &
              AVAudioSessionCategoryOptions.allowAirPlay,
        ),
      );
  }
}
