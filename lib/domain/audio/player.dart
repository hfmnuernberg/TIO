import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:tiomusic/domain/audio/markers.dart';
import 'package:tiomusic/pages/media_player/media_player_functions.dart';
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

  final AudioSystem _as;
  final AudioSession _audioSession;
  final FileSystem _fs;
  final Wakelock _wakelock;

  final OnPlaybackPositionChange _onPlaybackPositionChange;
  final OnIsPlayingChange _onIsPlayingChange;

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
  }) : _markers = Markers(_as),
       _onIsPlayingChange = onIsPlayingChange ?? ((_) {}),
       _onPlaybackPositionChange = onPlaybackPositionChange ?? ((_) {});

  Future<void> start() async {
    if (_isPlaying) return;

    _audioSessionInterruptionListenerHandle ??= await _audioSession.registerInterruptionListener(stop);

    await MediaPlayerFunctions.stopRecording(_as, _wakelock);
    await _as.mediaPlayerSetRepeat(repeatOne: _repeat);
    await _audioSession.preparePlayback();

    await _markers.start();

    final success = await _as.mediaPlayerStart();
    if (!success) {
      logger.e('Unable to start Audio Player.');
      return;
    }

    _playbackSamplingTimer = Timer.periodic(
      const Duration(milliseconds: playbackSamplingIntervalInMs),
      (t) => _update(),
    );

    await _update();
    await _wakelock.enable();
    return;
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

    await _markers.stop();
    await _update();
  }

  Future<void> setVolume(double volume) async {
    await _as.mediaPlayerSetVolume(volume: volume);
  }

  Future<void> setRepeat(bool repeat) async {
    _repeat = repeat;
    await _as.mediaPlayerSetRepeat(repeatOne: repeat);
  }

  Future<void> setPitch(double pitchSemitones) async {
    await _as.mediaPlayerSetPitchSemitones(pitchSemitones: pitchSemitones);
  }

  Future<void> setSpeed(double speedFactor) async {
    await _as.mediaPlayerSetSpeedFactor(speedFactor: speedFactor);
  }

  Future<void> setPlaybackPosition(double posFactor) async {
    await _as.mediaPlayerSetPlaybackPosFactor(posFactor: posFactor.clamp(0, 1));
    await _update();
  }

  Future<void> setTrim(double startPosition, double endPosition) async {
    _startPosition = startPosition;
    _endPosition = endPosition;
    if (_loaded) _as.mediaPlayerSetTrim(startFactor: startPosition, endFactor: endPosition);
  }

  Future<void> skip({required int seconds}) async {
    final state = await _as.mediaPlayerGetState();
    if (state == null) return logger.e('Cannot skip - State is null');

    final totalSecs = _fileDuration.inSeconds;
    final secondFactor = totalSecs > 0 ? seconds / totalSecs : 1.0;
    final newPos = state.playbackPositionFactor + secondFactor;

    await setPlaybackPosition(newPos);
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

    final loaded = await _as.mediaPlayerLoadWav(wavFilePath: wavFilePath);
    if (!loaded) return false;
    _loaded = true;

    await setTrim(_startPosition, _endPosition);
    await _setFileDuration();
    _markers.reset();
    _update();
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

    try {
      final data = await rootBundle.load(assetPath);
      final tmpDir = _fs.tmpFolderPath;
      await _fs.createFolder(tmpDir);
      final fileName = assetPath.split('/').last;
      final outPath = '$tmpDir/$fileName';
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
      _onIsPlayingChange(state.playing);
    }

    if (state.playbackPositionFactor != _playbackPosition) {
      final previousPosition = _playbackPosition;
      _playbackPosition = state.playbackPositionFactor;
      _onPlaybackPositionChange(state.playbackPositionFactor);

      await _markers.onPlaybackPositionChange(previousPosition: previousPosition, currentPosition: _playbackPosition);
    }
  }
}
