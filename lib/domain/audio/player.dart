import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

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

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  bool _repeatOne = false;
  bool get repeatOne => _repeatOne;

  final double _markerSoundFrequency = 2000;
  final int _markerSoundDurationInMilliseconds = 80;

  late List<double> _markerPositions;
  UnmodifiableListView<double> get markerPositions => UnmodifiableListView(_markerPositions);
  set markerPositions(List<double> value) {
    _markerPositions = List.of(value);
  }

  AudioSessionInterruptionListenerHandle? _audioSessionInterruptionListenerHandle;

  Player(this._as, this._audioSession, this._fs, this._wakelock);

  Future<Float32List?> openFileAndGetRms({
    required String absolutePath,
    required double startFactor,
    required double endFactor,
    required int numberOfBins,
  }) {
    return MediaPlayerFunctions.openAudioFileFromPathAndGetRMSValues(
      _as,
      _fs,
      absolutePath,
      startFactor,
      endFactor,
      numberOfBins,
    );
  }

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

  Future<void> jumpSeconds(int seconds, Duration totalDuration) async {
    final state = await _as.mediaPlayerGetState();
    if (state == null) {
      logger.w('Cannot jump $seconds seconds - State is null');
      return;
    }

    final totalSecs = totalDuration.inSeconds;
    final secondFactor = totalSecs > 0 ? seconds.toDouble() / totalSecs : 1.0;
    final newPos = state.playbackPositionFactor + secondFactor;

    await _as.mediaPlayerSetPlaybackPosFactor(posFactor: newPos);
  }
}
