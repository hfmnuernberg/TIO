import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:tiomusic/domain/audio/marker_navigation.dart';
import 'package:tiomusic/domain/audio/markers.dart';
import 'package:tiomusic/services/audio_session.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/wakelock.dart';
import 'package:tiomusic/util/log.dart';

const int playbackSamplingIntervalInMs = 120;

typedef OnPlaybackPositionChange = void Function(double playbackPosition);
typedef OnIsPlayingChange = void Function(bool isPlaying);

class Player {
  static final logger = createPrefixLogger('AudioPlayer');
  static Player? _currentlyPlaying;

  final AudioSystem _as;
  final AudioSession _audioSession;
  final FileSystem _fs;
  final Wakelock _wakelock;

  final List<OnPlaybackPositionChange> _onPlaybackPositionChangeListeners = [];
  final List<OnIsPlayingChange> _onIsPlayingChangeListeners = [];

  final Markers _markers;
  Markers get markers => _markers;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  double _playbackPosition = 0;
  double get playbackPosition => _playbackPosition;

  bool _repeat = false;
  bool get repeat => _repeat;

  bool _loaded = false;
  bool get loaded => _loaded;

  String? _wavFilePath;

  double _volume = 1;
  double _pitchSemitones = 0;
  double _speedFactor = 1;

  double _startPosition = 0;
  double _endPosition = 1;

  Duration _fileDuration = Duration.zero;
  Duration get fileDuration => _fileDuration;

  Timer? _playbackSamplingTimer;

  AudioSessionInterruptionListenerHandle? _audioSessionInterruptionListenerHandle;

  Player(
    this._as,
    this._audioSession,
    this._fs,
    this._wakelock, {
    OnIsPlayingChange? onIsPlayingChange,
    OnPlaybackPositionChange? onPlaybackPositionChange,
  }) : _markers = Markers(_as) {
    if (onIsPlayingChange != null) _onIsPlayingChangeListeners.add(onIsPlayingChange);
    if (onPlaybackPositionChange != null) _onPlaybackPositionChangeListeners.add(onPlaybackPositionChange);
  }

  void addOnPlaybackPositionChangeListener(OnPlaybackPositionChange listener) =>
      _onPlaybackPositionChangeListeners.add(listener);
  void removeOnPlaybackPositionChangeListener(OnPlaybackPositionChange listener) =>
      _onPlaybackPositionChangeListeners.remove(listener);

  void addOnIsPlayingChangeListener(OnIsPlayingChange listener) => _onIsPlayingChangeListeners.add(listener);
  void removeOnIsPlayingChangeListener(OnIsPlayingChange listener) => _onIsPlayingChangeListeners.remove(listener);

  Future<void> start() async {
    if (_isPlaying) return;

    // Only one Player can play at a time (main tool vs island tool).
    final other = _currentlyPlaying;
    if (other != null && other != this) await other.stop();
    _currentlyPlaying = this;

    if (!_loaded || _wavFilePath == null) {
      logger.e('Cannot start Audio Player - no file loaded.');
      if (_currentlyPlaying == this) _currentlyPlaying = null;
      return;
    }

    _audioSessionInterruptionListenerHandle ??= await _audioSession.registerInterruptionListener(stop);

    // Backend media player is shared globally. Before starting, re-apply this
    // Player's complete state so the correct tool's audio/settings play.
    final loaded = await _as.mediaPlayerLoadWav(wavFilePath: _wavFilePath!);
    if (!loaded) {
      logger.e('Unable to load Audio Player wav before start.');
      if (_currentlyPlaying == this) _currentlyPlaying = null;
      return;
    }

    await _as.mediaPlayerSetPitchSemitones(pitchSemitones: _pitchSemitones);
    await _as.mediaPlayerSetPlaybackPosFactor(posFactor: _playbackPosition.clamp(0.0, 1.0));
    await _as.mediaPlayerSetRepeat(repeatOne: _repeat);
    await _as.mediaPlayerSetSpeedFactor(speedFactor: _speedFactor);
    await _as.mediaPlayerSetTrim(startFactor: _startPosition, endFactor: _endPosition);
    await _as.mediaPlayerSetVolume(volume: (_volume * _volume).clamp(0, 1));

    await _audioSession.preparePlayback();
    await _markers.start();

    final success = await _as.mediaPlayerStart();
    if (!success) {
      logger.e('Unable to start Audio Player.');
      if (_currentlyPlaying == this) _currentlyPlaying = null;
      return;
    }

    _playbackSamplingTimer = Timer.periodic(
      const Duration(milliseconds: playbackSamplingIntervalInMs),
      (t) => _update(),
    );

    await _update();
    await _wakelock.enable();
  }

  Future<void> stop() async {
    _playbackSamplingTimer?.cancel();
    _playbackSamplingTimer = null;

    await _wakelock.disable();

    if (!_isPlaying) return;

    final success = await _as.mediaPlayerStop();
    if (!success) {
      logger.e('Unable to stop Audio Player.');
      return;
    }

    if (_audioSessionInterruptionListenerHandle != null) {
      await _audioSession.unregisterInterruptionListener(_audioSessionInterruptionListenerHandle!);
      _audioSessionInterruptionListenerHandle = null;
    }

    // Only stop marker beeps if this player owned the backend.
    if (_currentlyPlaying == this) await _markers.stop();
    await _update();

    if (_currentlyPlaying == this) _currentlyPlaying = null;
  }

  Future<void> setVolume(double volume) async {
    _volume = volume;

    // Shared backend: only the currently playing Player may mutate backend state.
    final isBackendOwner = _currentlyPlaying == this && _isPlaying;
    if (isBackendOwner) await _as.mediaPlayerSetVolume(volume: (volume * volume).clamp(0, 1));
  }

  Future<void> setRepeat(bool repeat) async {
    _repeat = repeat;

    // Shared backend: only the currently playing Player may mutate backend state.
    final isBackendOwner = _currentlyPlaying == this && _isPlaying;
    if (isBackendOwner) await _as.mediaPlayerSetRepeat(repeatOne: repeat);
  }

  Future<void> setPitch(double pitchSemitones) async {
    _pitchSemitones = pitchSemitones;

    // Shared backend: only the currently playing Player may mutate backend state.
    final isBackendOwner = _currentlyPlaying == this && _isPlaying;
    if (isBackendOwner) await _as.mediaPlayerSetPitchSemitones(pitchSemitones: pitchSemitones);
  }

  Future<void> setSpeed(double speedFactor) async {
    _speedFactor = speedFactor;

    // Shared backend: only the currently playing Player may mutate backend state.
    final isBackendOwner = _currentlyPlaying == this && _isPlaying;
    if (isBackendOwner) await _as.mediaPlayerSetSpeedFactor(speedFactor: speedFactor);
  }

  Future<void> setPlaybackPosition(double posFactor) async {
    final clamped = posFactor.clamp(0.0, 1.0);

    // The backend media player is shared globally. Only the currently playing
    // Player instance may mutate backend playback state.
    final bool isBackendOwner = _currentlyPlaying == this && _isPlaying;
    if (isBackendOwner) await _as.mediaPlayerSetPlaybackPosFactor(posFactor: clamped);

    final previousPosition = _playbackPosition;
    if (_playbackPosition != clamped) {
      _playbackPosition = clamped;
      for (final listener in _onPlaybackPositionChangeListeners) {
        listener(_playbackPosition);
      }

      // Only the playing tool should trigger marker sounds.
      if (isBackendOwner) {
        await _markers.onPlaybackPositionChange(previousPosition: previousPosition, currentPosition: _playbackPosition);
      }
    }
  }

  Future<void> setTrim(double startPosition, double endPosition) async {
    _startPosition = startPosition;
    _endPosition = endPosition;

    // Only the currently playing Player may mutate backend playback state.
    final bool isBackendOwner = _currentlyPlaying == this && _isPlaying;
    if (_loaded && isBackendOwner) _as.mediaPlayerSetTrim(startFactor: startPosition, endFactor: endPosition);
  }

  Future<void> skip({required int seconds}) async {
    // Use the Player’s current position instead of querying the backend state.
    // The backend can lag right after seeking, which would make repeated skips
    // compute the same target position.
    final totalSecs = _fileDuration.inSeconds;
    if (totalSecs <= 0) return;

    final secondFactor = seconds / totalSecs;
    final newPos = (_playbackPosition + secondFactor).clamp(0.0, 1.0);

    await setPlaybackPosition(newPos);
  }

  Future<void> skipToMarker({required bool forward}) async {
    final sortedMarkers = [..._markers.positions]..sort();
    if (sortedMarkers.isEmpty) return;

    if (forward) {
      final targetMarker = MarkerNavigation.next(playbackPosition, sortedMarkers);
      await setPlaybackPosition(targetMarker);
      return;
    }

    final targetMarker = MarkerNavigation.previousWithWindow(
      position: playbackPosition,
      sortedMarkers: sortedMarkers,
      fileDuration: fileDuration,
    );
    await setPlaybackPosition(targetMarker);
  }

  Future<Float32List> getRmsValues(int numberOfBins) async {
    final rmsList = await _as.mediaPlayerGetRms(nBins: numberOfBins);

    Float32List newList = Float32List(rmsList.length);
    var minValue = rmsList.reduce(min);
    var maxValue = rmsList.reduce(max);
    if (minValue == maxValue) return newList;

    for (int i = 0; i < rmsList.length; i++) {
      newList[i] = (rmsList[i] - minValue) / (maxValue - minValue);
    }
    return newList;
  }

  Future<bool> loadAudioFile(String absoluteFilePath) async {
    _loaded = false;
    final isMidi = absoluteFilePath.toLowerCase().endsWith('.mid');
    final wavFilePath = isMidi ? (await _convertMidiToWav(absoluteFilePath)) : absoluteFilePath;
    if (wavFilePath == null) return false;

    _wavFilePath = wavFilePath;

    final loaded = await _as.mediaPlayerLoadWav(wavFilePath: wavFilePath);
    if (!loaded) return false;
    _loaded = true;

    await setTrim(_startPosition, _endPosition);
    await _setFileDuration();
    _markers.reset();
    await _update();
    return true;
  }

  Future<String?> _convertMidiToWav(String absoluteMidiFilePath) async {
    final sampleRate = await _as.getSampleRate();

    final ts = DateTime.now().millisecondsSinceEpoch;
    final base = _fs.toBasename(absoluteMidiFilePath).replaceAll(RegExp(r'[^\w.-]'), '_');
    final tmpDir = _fs.tmpFolderPath;
    await _fs.createFolder(tmpDir);
    final tmpWavAbs = '$tmpDir/$base.$ts.rendered.wav';

    final sf2Abs = await _resolveSoundFontPath();
    if (sf2Abs == null) return null;

    final success = await _as.mediaPlayerRenderMidiToWav(
      midiPath: absoluteMidiFilePath,
      soundFontPath: sf2Abs,
      wavOutPath: tmpWavAbs,
      sampleRate: sampleRate,
      gain: 0.7,
    );
    return success ? tmpWavAbs : null;
  }

  Future<void> _setFileDuration() async {
    final state = await _as.mediaPlayerGetState();
    if (state != null) {
      _fileDuration = Duration(milliseconds: (state.totalLengthSeconds * 1000).toInt());
    }
  }

  Future<String?> _resolveSoundFontPath() async {
    const assetPath = 'assets/sound_fonts/piano_01.sf2';
    final tmpDir = _fs.tmpFolderPath;
    await _fs.createFolder(tmpDir);
    final fileName = assetPath.split('/').last;
    final outPath = '$tmpDir/$fileName';

    if (_fs.existsFile(outPath)) return outPath;

    try {
      final data = await rootBundle.load(assetPath);
      final outFile = File(outPath);
      await outFile.writeAsBytes(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes), flush: true);
      return outPath;
    } catch (e, st) {
      logger.e('Failed to load SoundFont asset at "$assetPath": $e\n$st');
      return null;
    }
  }

  Future<void> _update() async {
    final state = await _as.mediaPlayerGetState();
    if (state == null) return;

    if (state.playing != _isPlaying) {
      _isPlaying = state.playing;
      for (final listener in _onIsPlayingChangeListeners) {
        listener(state.playing);
      }
    }

    if (state.playbackPositionFactor != _playbackPosition) {
      final previousPosition = _playbackPosition;
      _playbackPosition = state.playbackPositionFactor;
      for (final listener in _onPlaybackPositionChangeListeners) {
        listener(state.playbackPositionFactor);
      }

      await _markers.onPlaybackPositionChange(previousPosition: previousPosition, currentPosition: _playbackPosition);
    }
  }
}
