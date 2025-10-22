import 'dart:async';
import 'dart:typed_data';

import 'package:permission_handler/permission_handler.dart';
import 'package:tiomusic/services/audio_session.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/wakelock.dart';
import 'package:tiomusic/util/log.dart';

class Recorder {
  static final logger = createPrefixLogger('AudioRecorder');

  final AudioSystem _as;
  final AudioSession _audioSession;
  final Wakelock _wakelock;

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  AudioSessionInterruptionListenerHandle? _interruptionHandle;

  Recorder(this._as, this._audioSession, this._wakelock);

  Future<bool> start() async {
    if (_isRecording) return true;

    // Request microphone permission
    final micGranted = await Permission.microphone.request().isGranted;
    if (!micGranted) {
      logger.w('Failed to get microphone permissions.');
      return false;
    }

    // Prepare audio session and start recording via AudioSystem
    await _audioSession.prepareRecording();
    final success = await _as.mediaPlayerStartRecording();
    if (!success) {
      logger.e('mediaPlayerStartRecording() returned false');
      return false;
    }

    _isRecording = true;

    // Listen for interruptions and stop recording if needed
    _interruptionHandle ??= await _audioSession.registerInterruptionListener(stop);

    // Keep device awake while recording
    await _wakelock.enable();

    return true;
  }

  Future<bool> stop() async {
    // Always disable wakelock when we *attempt* to stop.
    await _wakelock.disable();

    if (!_isRecording) return true;

    // Stop via AudioSystem
    final success = await _as.mediaPlayerStopRecording();
    if (!success) {
      logger.e('mediaPlayerStopRecording() returned false');
      return false;
    }

    _isRecording = false;

    // Unregister interruption listener
    if (_interruptionHandle != null) {
      await _audioSession.unregisterInterruptionListener(_interruptionHandle!);
      _interruptionHandle = null;
    }

    return true;
  }

  Future<Float64List> getRecordingSamples() async => _as.mediaPlayerGetRecordingSamples();
}
