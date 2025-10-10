import 'dart:async';

import 'package:tiomusic/services/audio_session.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/wakelock.dart';
import 'package:tiomusic/util/log.dart';

import 'package:tiomusic/pages/media_player/media_player_functions.dart';

class MediaPlayer {
  static final logger = createPrefixLogger('MediaPlayer');

  final AudioSystem _as;
  final AudioSession _audioSession;
  final Wakelock _wakelock;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  final double _markerSoundFrequency = 2000;
  final int _markerSoundDurationInMilliseconds = 80;

  AudioSessionInterruptionListenerHandle? _audioSessionInterruptionListenerHandle;

  MediaPlayer(this._as, this._audioSession, this._wakelock);

  Future<bool> start({required bool looping, required bool useMarkers}) async {
    if (_isPlaying) return true;

    _audioSessionInterruptionListenerHandle ??= await _audioSession.registerInterruptionListener(stop);

    final success = await MediaPlayerFunctions.startPlaying(_as, _audioSession, _wakelock, looping, useMarkers);

    if (!success) {
      logger.e('Unable to start MediaPlayer.');
      return false;
    }

    _isPlaying = true;
    return true;
  }

  Future<void> stop() async {
    if (!_isPlaying) return;

    final success = await MediaPlayerFunctions.stopPlaying(_as, _wakelock);
    if (!success) {
      logger.e('Unable to stop MediaPlayer.');
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
    await _as.mediaPlayerSetRepeat(repeatOne: repeatOne);
  }

  Future<void> setSpeedAndPitch(double speedFactor, double pitchSemitones) async {
    await MediaPlayerFunctions.setSpeedAndPitchInRust(_as, speedFactor, pitchSemitones);
  }

  Future<void> setPlaybackPosFactor(double posFactor) async {
    await _as.mediaPlayerSetPlaybackPosFactor(posFactor: posFactor.clamp(0, 1));
  }

  Future<void> playMarkerPeep() async {
    await _as.generatorNoteOn(newFreq: _markerSoundFrequency);
    Future.delayed(Duration(milliseconds: _markerSoundDurationInMilliseconds), _as.generatorNoteOff);
  }


  Future<dynamic> getState() => _as.mediaPlayerGetState();

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
