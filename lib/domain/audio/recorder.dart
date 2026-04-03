import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:permission_handler/permission_handler.dart';
import 'package:tiomusic/services/audio_session.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/wakelock.dart';
import 'package:tiomusic/util/log.dart';

typedef OnIsRecordingChange = void Function(bool isRecording);
typedef OnRecordingLengthChange = void Function(Duration recordingLength);
typedef OnRecordingLimitReached = void Function();

enum RecorderStartResult { success, micPermissionDenied, alreadyRecording, error }

class Recorder {
  static final logger = createPrefixLogger('AudioRecorder');

  /// Max buffer size in samples before auto-stopping.
  /// Peak memory at stop is ~N × 16 bytes (original f32 + clone f32 + f64 conversion).
  /// e.g., 10M samples → ~160 MB peak, ~3.5 min at 48 kHz.
  static final maxBufferSamples = Platform.isIOS ? 30000000 : 20000000;

  final AudioSystem _as;
  final AudioSession _audioSession;
  final Wakelock _wakelock;

  final OnIsRecordingChange _onIsRecordingChange;
  final OnRecordingLengthChange _onRecordingLengthChange;
  final OnRecordingLimitReached _onRecordingLimitReached;

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  Duration _recordingLength = Duration.zero;
  Duration get recordingLength => _recordingLength;

  Timer? _recordingTimer;

  AudioSessionInterruptionListenerHandle? _interruptionHandle;

  Recorder(
    this._as,
    this._audioSession,
    this._wakelock, {
    OnIsRecordingChange? onIsRecordingChange,
    OnRecordingLengthChange? onRecordingLengthChange,
    OnRecordingLimitReached? onRecordingLimitReached,
  }) : _onIsRecordingChange = onIsRecordingChange ?? ((_) {}),
       _onRecordingLengthChange = onRecordingLengthChange ?? ((_) {}),
       _onRecordingLimitReached = onRecordingLimitReached ?? (() {});

  Future<RecorderStartResult> start() async {
    if (_isRecording) return RecorderStartResult.alreadyRecording;

    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      logger.w('Failed to get microphone permissions.');
      return RecorderStartResult.micPermissionDenied;
    }

    await _audioSession.prepareRecording();
    final success = await _as.mediaPlayerStartRecording();
    if (!success) {
      logger.e('Unable to start Audio Recorder.');
      return RecorderStartResult.error;
    }

    _isRecording = true;
    _recordingLength = Duration.zero;
    _onIsRecordingChange(true);
    _onRecordingLengthChange(_recordingLength);

    _interruptionHandle ??= await _audioSession.registerInterruptionListener(stop);

    await _wakelock.enable();

    _recordingTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      _recordingLength += const Duration(seconds: 1);
      _onRecordingLengthChange(_recordingLength);
      _checkBufferSize();
    });

    return RecorderStartResult.success;
  }

  Future<bool> stop() async {
    await _wakelock.disable();

    _recordingTimer?.cancel();
    _recordingTimer = null;

    if (!_isRecording) return true;

    final success = await _as.mediaPlayerStopRecording();
    if (!success) logger.e('Unable to stop Audio Recorder.');

    _isRecording = false;
    _onIsRecordingChange(false);

    if (_interruptionHandle != null) {
      await _audioSession.unregisterInterruptionListener(_interruptionHandle!);
      _interruptionHandle = null;
    }

    return success;
  }

  Future<void> _checkBufferSize() async {
    final bufferSize = await _as.mediaPlayerGetRecordingBufferSize();

    if (bufferSize >= maxBufferSamples) {
      logger.w('Recording buffer limit reached ($bufferSize samples). Auto-stopping.');
      await stop();
      _onRecordingLimitReached();
    }
  }

  Future<Float64List> getRecordingSamples() async => _as.mediaPlayerGetRecordingSamples();
}
