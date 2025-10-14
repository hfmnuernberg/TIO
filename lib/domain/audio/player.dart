import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:tiomusic/services/audio_session.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/wakelock.dart';
import 'package:tiomusic/util/log.dart';

import 'package:tiomusic/pages/media_player/media_player_functions.dart';

class Player {
  static final logger = createPrefixLogger('AudioPlayer');

  final AudioSystem _as;
  final AudioSession _audioSession;
  final FileSystem _fs;
  final Wakelock _wakelock;

  final double _markerSoundFrequency = 2000;
  final int _markerSoundDurationInMilliseconds = 80;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  bool _repeatOne = false;
  bool get repeatOne => _repeatOne;

  String? _absoluteFilePath;
  String? get absoluteFilePath => _absoluteFilePath;

  double _startPosition = 0;
  // this getter is currently not used
  // ignore: unnecessary_getters_setters
  double get startPosition => _startPosition;
  set startPosition(double value) {
    _startPosition = value;
  }

  double _endPosition = 1;
  // this getter is currently not used
  // ignore: unnecessary_getters_setters
  double get endPosition => _endPosition;
  set endPosition(double value) {
    _endPosition = value;
  }

  late List<double> _markerPositions;
  UnmodifiableListView<double> get markerPositions => UnmodifiableListView(_markerPositions);
  set markerPositions(List<double> value) {
    _markerPositions = List.of(value);
  }

  Duration _fileDuration = Duration.zero;
  Duration get fileDuration => _fileDuration;

  AudioSessionInterruptionListenerHandle? _audioSessionInterruptionListenerHandle;

  Player(this._as, this._audioSession, this._fs, this._wakelock);

  Future<bool> start({bool? repeatOne}) async {
    if (_isPlaying) return true;

    _audioSessionInterruptionListenerHandle ??= await _audioSession.registerInterruptionListener(stop);

    await MediaPlayerFunctions.stopRecording(_as, _wakelock);
    await _as.mediaPlayerSetRepeat(repeatOne: repeatOne ?? _repeatOne);
    await _audioSession.preparePlayback();

    if (_markerPositions.isNotEmpty) {
      await _as.generatorStop();
      await _as.generatorStart();
    }

    final success = await _as.mediaPlayerStart();
    if (success) {
      await _wakelock.enable();
      _isPlaying = true;
    } else {
      logger.e('Unable to start Audio Player.');
      return false;
    }

    return true;
  }

  Future<void> stop() async {
    if (!_isPlaying) return;

    await _wakelock.disable();
    final success = await _as.mediaPlayerStop();
    if (!success) {
      logger.e('Unable to stop Audio Player.');
      return;
    }

    if (_audioSessionInterruptionListenerHandle != null) {
      await _audioSession.unregisterInterruptionListener(_audioSessionInterruptionListenerHandle!);
      _audioSessionInterruptionListenerHandle = null;
    }

    _isPlaying = false;
  }

  Future<void> setVolume(double volume) async {
    await _as.mediaPlayerSetVolume(volume: volume);
  }

  Future<void> setRepeat(bool repeatOne) async {
    _repeatOne = repeatOne;
    await _as.mediaPlayerSetRepeat(repeatOne: repeatOne);
  }

  Future<void> setPitch(double pitchSemitones) async {
    await _as.mediaPlayerSetPitchSemitones(pitchSemitones: pitchSemitones);
  }

  Future<void> setSpeed(double speedFactor) async {
    await _as.mediaPlayerSetSpeedFactor(speedFactor: speedFactor);
  }

  Future<void> setPlaybackPosition(double posFactor) async {
    await _as.mediaPlayerSetPlaybackPosFactor(posFactor: posFactor.clamp(0, 1));
  }

  Future<void> setAbsoluteFilePath(String relativePath) async {
    _absoluteFilePath = _fs.toAbsoluteFilePath(relativePath);
  }

  Future<void> playMarkerPeep() async {
    await _as.generatorNoteOn(newFreq: _markerSoundFrequency);
    Future.delayed(Duration(milliseconds: _markerSoundDurationInMilliseconds), _as.generatorNoteOff);
  }

  // instead use getter (isPlaying, playbackPosition) -> get rid of this method
  Future<dynamic> getState() async {
    final state = await _as.mediaPlayerGetState();
    if (state != null) {
      _isPlaying = state.playing;
    }
    return state;
  }

  Future<void> jumpSeconds({required int seconds}) async {
    final state = await _as.mediaPlayerGetState();
    if (state == null) {
      logger.w('Cannot jump $seconds seconds - State is null');
      return;
    }

    final totalSecs = _fileDuration.inSeconds;
    final secondFactor = totalSecs > 0 ? seconds.toDouble() / totalSecs : 1.0;
    final newPos = state.playbackPositionFactor + secondFactor;

    await _as.mediaPlayerSetPlaybackPosFactor(posFactor: newPos);
  }

  Future<void> _renderMidiToTempWav() async {
    final sampleRate = await _as.getSampleRate();

    final ts = DateTime.now().millisecondsSinceEpoch;
    final base = _fs.toBasename(_absoluteFilePath!).replaceAll(RegExp(r'[^\w.-]'), '_');
    final tmpDir = _fs.tmpFolderPath;
    await _fs.createFolder(tmpDir);
    final tmpWavAbs = '$tmpDir/$base.$ts.rendered.wav';

    final sf2Abs = await _resolveSoundFontPath();
    if (sf2Abs == null) {
      _absoluteFilePath = null;
      return;
    }

    final success = await _as.mediaPlayerRenderMidiToWav(
      midiPath: _absoluteFilePath!,
      soundFontPath: sf2Abs,
      wavOutPath: tmpWavAbs,
      sampleRate: sampleRate,
      gain: 0.7,
    );
    _absoluteFilePath = success ? tmpWavAbs : null;
  }

  Future<bool> _loadAudioFile(String path) async {
    return _as.mediaPlayerLoadWav(wavFilePath: path);
  }

  Future<void> _applyTrim() async {
    await _as.mediaPlayerSetTrim(startFactor: _startPosition, endFactor: _endPosition);
  }

  Future<Float32List?> _getRmsNormalized({required int numberOfBins}) async {
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

  Future<void> _setFileDuration() async {
    final state = await _as.mediaPlayerGetState();
    if (state != null) {
      _fileDuration = Duration(milliseconds: (state.totalLengthSeconds * 1000).toInt());
    }
  }

  Future<Float32List?> processFile({required int numberOfBins}) async {
    if (_absoluteFilePath == null) return null;

    final isMidi = _absoluteFilePath!.toLowerCase().endsWith('.mid');
    if (isMidi) await _renderMidiToTempWav();

    final loaded = await _loadAudioFile(_absoluteFilePath!);
    if (!loaded) return null;

    await _applyTrim();
    await _setFileDuration();
    return _getRmsNormalized(numberOfBins: numberOfBins);
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
}

// onPlaybackPositionChange (optional)
// onMarkerReached (optional)
