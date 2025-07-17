import 'dart:async';

import 'package:audio_session/audio_session.dart' as core;
import 'package:tiomusic/services/audio_session.dart';

class AudioSessionInterruptionListenerHandleImpl implements AudioSessionInterruptionListenerHandle {
  final StreamSubscription<core.AudioInterruptionEvent> _listener;

  AudioSessionInterruptionListenerHandleImpl(core.AudioSession session, AudioSessionInterruptionCallback onInterrupt)
    : _listener = session.interruptionEventStream.listen((event) {
        if (event.type == core.AudioInterruptionType.unknown) onInterrupt();
      });

  @override
  Future<void> cancel() async => _listener.cancel();
}

class AudioSessionImpl implements AudioSession {
  @override
  Future<bool> start() async {
    final session = await core.AudioSession.instance;
    return session.setActive(true);
  }

  @override
  Future<bool> stop() async {
    final session = await core.AudioSession.instance;
    return session.setActive(false);
  }

  @override
  Future<void> preparePlayback() async {
    final session = await core.AudioSession.instance;
    await session.configure(
      core.AudioSessionConfiguration(
        avAudioSessionCategory: core.AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions:
            core.AVAudioSessionCategoryOptions.defaultToSpeaker &
            core.AVAudioSessionCategoryOptions.allowBluetooth &
            core.AVAudioSessionCategoryOptions.allowAirPlay,
      ),
    );
  }

  @override
  Future<void> prepareRecording() async {
    final session = await core.AudioSession.instance;
    await session.configure(
      core.AudioSessionConfiguration(
        avAudioSessionCategory: core.AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions:
            core.AVAudioSessionCategoryOptions.defaultToSpeaker &
            core.AVAudioSessionCategoryOptions.allowBluetooth &
            core.AVAudioSessionCategoryOptions.allowAirPlay,
      ),
    );
  }

  @override
  Future<AudioSessionInterruptionListenerHandle> registerInterruptionListener(
    AudioSessionInterruptionCallback onInterrupt,
  ) async {
    final session = await core.AudioSession.instance;
    return AudioSessionInterruptionListenerHandleImpl(session, onInterrupt);
  }

  @override
  Future<void> unregisterInterruptionListener(AudioSessionInterruptionListenerHandle handle) async => handle.cancel();
}
