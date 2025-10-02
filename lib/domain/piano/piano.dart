import 'dart:async';

import 'package:flutter/services.dart';
import 'package:tiomusic/models/sound_font.dart';
import 'package:tiomusic/services/audio_session.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/util/log.dart';

class Piano {
  static final logger = createPrefixLogger('Piano');

  final AudioSystem _as;
  final AudioSession _audioSession;
  final FileSystem _fs;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  static int _startedPianos = 0;
  int get startedPianos => _startedPianos;

  double _concertPitch = 440;
  double get concertPitch => _concertPitch;

  SoundFont _soundFont = SoundFont.piano1;
  SoundFont get soundFont => _soundFont;

  AudioSessionInterruptionListenerHandle? _audioSessionInterruptionListenerHandle;

  Piano(this._as, this._audioSession, this._fs);

  void playNote(int note) => _as.pianoNoteOn(note: note);

  void releaseNote(int note) => _as.pianoNoteOff(note: note);

  Future<void> setVolume(double volume) async => _as.pianoSetVolume(volume: volume);

  Future<void> setConcertPitch(double concertPitch) async {
    await _as.pianoSetConcertPitch(newConcertPitch: concertPitch);
    _concertPitch = concertPitch;
  }

  Future<void> setSoundFont(SoundFont soundFont) async {
    _soundFont = soundFont;
    await restart();
  }

  Future<void> start() async {
    if (_isPlaying) return;

    _audioSessionInterruptionListenerHandle = await _audioSession.registerInterruptionListener(stop);

    bool initSuccess = await _loadSoundFontFile(_soundFont.file);
    await _audioSession.preparePlayback();
    if (!initSuccess) return;

    if (_startedPianos == 0) {
      bool success = await _as.pianoStart();
      if (!success) return logger.e('Unable to start Piano.');
    }

    _isPlaying = true;
    _startedPianos++;
  }

  Future<void> stop() async {
    if (!_isPlaying) return;

    if (_audioSessionInterruptionListenerHandle != null) {
      _audioSession.unregisterInterruptionListener(_audioSessionInterruptionListenerHandle!);
      _audioSessionInterruptionListenerHandle = null;
    }

    _isPlaying = false;
    _startedPianos--;

    if (_startedPianos == 0) {
      final success = await _as.pianoStop();
      if (!success) {
        logger.e('Unable to stop Piano.');
        _startedPianos = 1;
        _isPlaying = true;
        return;
      }
    }
  }

  Future<void> restart() async {
    if (!_isPlaying) return;
    await stop();
    await start();
  }

  Future<bool> _loadSoundFontFile(String soundFontPath) async {
    final tempSoundFontPath = '${_fs.tmpFolderPath}/sound_font.sf2';
    final byteData = await rootBundle.load(soundFontPath);
    final bytes = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    await _fs.saveFileAsBytes(tempSoundFontPath, bytes);
    return _as.pianoSetup(soundFontPath: tempSoundFontPath);
  }
}
