import 'dart:async';

import 'package:permission_handler/permission_handler.dart';
import 'package:tiomusic/services/audio_session.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/wakelock.dart';
import 'package:tiomusic/util/log.dart';

const int pollIntervalInMs = 35;

typedef OnTunerFrequencyChange = void Function(double? frequency);
typedef OnTunerRunningChange = void Function(bool isRunning);

class Tuner {
  static final _logger = createPrefixLogger('Tuner');

  final AudioSystem _as;
  final AudioSession _audioSession;
  final Wakelock _wakelock;

  final List<OnTunerFrequencyChange> _onFrequencyChangeListeners = [];
  final List<OnTunerRunningChange> _onRunningChangeListeners = [];

  bool _isRunning = false;
  bool get isRunning => _isRunning;

  Timer? _pollTimer;
  AudioSessionInterruptionListenerHandle? _audioSessionInterruptionListenerHandle;
  AudioSessionInterruptionListenerHandle? _generatorInterruptionListenerHandle;

  Future<void> registerGeneratorInterruptionListener({void Function()? onInterrupted}) async {
    if (_generatorInterruptionListenerHandle != null) {
      await _audioSession.unregisterInterruptionListener(_generatorInterruptionListenerHandle!);
      _generatorInterruptionListenerHandle = null;
    }

    _generatorInterruptionListenerHandle = await _audioSession.registerInterruptionListener(() async {
      await stopGenerator();
      onInterrupted?.call();
    });
  }

  Future<void> unregisterGeneratorInterruptionListener() async {
    if (_generatorInterruptionListenerHandle == null) return;
    await _audioSession.unregisterInterruptionListener(_generatorInterruptionListenerHandle!);
    _generatorInterruptionListenerHandle = null;
  }

  Tuner(
    this._as,
    this._audioSession,
    this._wakelock, {
    OnTunerFrequencyChange? onFrequencyChange,
    OnTunerRunningChange? onRunningChange,
  }) {
    if (onFrequencyChange != null) _onFrequencyChangeListeners.add(onFrequencyChange);
    if (onRunningChange != null) _onRunningChangeListeners.add(onRunningChange);
  }

  void addOnFrequencyChangeListener(OnTunerFrequencyChange listener) => _onFrequencyChangeListeners.add(listener);
  void removeOnFrequencyChangeListener(OnTunerFrequencyChange listener) => _onFrequencyChangeListeners.remove(listener);

  void addOnRunningChangeListener(OnTunerRunningChange listener) => _onRunningChangeListeners.add(listener);
  void removeOnRunningChangeListener(OnTunerRunningChange listener) => _onRunningChangeListeners.remove(listener);

  Future<void> start() async {
    if (_isRunning) return;

    final micGranted = await Permission.microphone.request().isGranted;
    if (!micGranted) {
      _logger.w('Failed to get microphone permissions.');
      return;
    }

    _audioSessionInterruptionListenerHandle ??= await _audioSession.registerInterruptionListener(stop);

    await _audioSession.prepareRecording();

    final success = await _as.tunerStart();
    if (!success) {
      _logger.e('Unable to start Tuner.');
      return;
    }

    await _wakelock.enable();

    _setRunning(true);

    await _pollOnceAndEmit();

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(milliseconds: pollIntervalInMs), (_) async {
      await _pollOnceAndEmit();
    });
  }

  Future<void> stop() async {
    _pollTimer?.cancel();
    _pollTimer = null;

    await _wakelock.disable();

    if (!_isRunning) return;

    if (_audioSessionInterruptionListenerHandle != null) {
      await _audioSession.unregisterInterruptionListener(_audioSessionInterruptionListenerHandle!);
      _audioSessionInterruptionListenerHandle = null;
    }

    await _as.tunerStop();

    _setRunning(false);
    _emitFrequency(null);
  }

  Future<void> dispose() async {
    await unregisterGeneratorInterruptionListener();
    await stop();
    _onFrequencyChangeListeners.clear();
    _onRunningChangeListeners.clear();
  }

  Future<void> _pollOnceAndEmit() async {
    if (!_isRunning) return;
    final freq = await _as.tunerGetFrequency();
    _emitFrequency(freq);
  }

  void _emitFrequency(double? frequency) {
    for (final listener in _onFrequencyChangeListeners) {
      listener(frequency);
    }
  }

  void _setRunning(bool value) {
    if (_isRunning == value) return;
    _isRunning = value;
    for (final listener in _onRunningChangeListeners) {
      listener(_isRunning);
    }
  }

  Future<void> startGenerator() async {
    await _audioSession.preparePlayback();
    await _as.generatorStart();
  }

  Future<void> stopGenerator() async {
    await _as.generatorNoteOff();
    await Future.delayed(const Duration(milliseconds: 70));
    await _as.generatorStop();
  }

  Future<void> generatorNoteOn({required double frequency}) async {
    await _as.generatorNoteOn(newFreq: frequency);
  }

  Future<void> generatorNoteOff() async {
    await _as.generatorNoteOff();
  }
}
