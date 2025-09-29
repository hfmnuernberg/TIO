import 'dart:async';

import 'package:audio_session/audio_session.dart' as core;
import 'package:flutter/services.dart';
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

  // @override
  // Future<void> preparePlayback() async {
  //   final session = await core.AudioSession.instance;
  //   await session.configure(
  //     core.AudioSessionConfiguration(
  //       avAudioSessionCategory: core.AVAudioSessionCategory.playback,
  //       avAudioSessionCategoryOptions:
  //           // core.AVAudioSessionCategoryOptions.defaultToSpeaker |
  //           // core.AVAudioSessionCategoryOptions.allowBluetooth |
  //           // core.AVAudioSessionCategoryOptions.allowAirPlay,
  //           core.AVAudioSessionCategoryOptions.allowBluetoothA2dp |
  //           core.AVAudioSessionCategoryOptions.allowAirPlay |
  //           core.AVAudioSessionCategoryOptions.mixWithOthers,
  //     ),
  //   );
  // }
  @override
  Future<void> preparePlayback() async {
    final session = await core.AudioSession.instance;

    // Cache last-applied playback config to avoid redundant configure()s.
    // Put these two fields at class level (AudioSessionImpl) if you want persistence across calls:
    // bool _playbackConfigured = false;
    // core.AudioSessionConfiguration? _lastPlaybackCfg;

    Future<void> attempt(core.AudioSessionConfiguration cfg) async {
      try {
        await session.configure(cfg);
        // _lastPlaybackCfg = cfg;
        // _playbackConfigured = true;
      } on PlatformException catch (e) {
        // This can fail if permissions are not granted yet.
        // ignore: avoid_print
        print('[AudioSession] configure failed: $e for cfg=$cfg');
        rethrow;
      }
    }

    // IMPORTANT: Start from a robust baseline.
    // 1) Playback + mix (safe, works on speaker, doesn’t fight routes)
    try {
      await attempt(
        core.AudioSessionConfiguration(
          avAudioSessionCategory: core.AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions: core.AVAudioSessionCategoryOptions.mixWithOthers,
        ),
      );
      return;
    } catch (_) {}

    // 2) Playback (no options) – even safer
    try {
      await attempt(const core.AudioSessionConfiguration(avAudioSessionCategory: core.AVAudioSessionCategory.playback));
      return;
    } catch (_) {}

    // 3) Fallback: ambient (obeys mute switch; last resort)
    await attempt(const core.AudioSessionConfiguration(avAudioSessionCategory: core.AVAudioSessionCategory.ambient));
  }

  @override
  Future<void> prepareRecording() async {
    final session = await core.AudioSession.instance;
    await session.configure(
      core.AudioSessionConfiguration(
        avAudioSessionCategory: core.AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions:
            core.AVAudioSessionCategoryOptions.defaultToSpeaker |
            core.AVAudioSessionCategoryOptions.allowBluetooth |
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
