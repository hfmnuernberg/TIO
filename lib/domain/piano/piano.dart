import 'dart:async';

import 'package:flutter/services.dart';
import 'package:tiomusic/models/sound_font.dart';
import 'package:tiomusic/services/audio_session.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/file_system.dart';

class Piano {
  final AudioSystem _as;
  final AudioSession _audioSession;
  final FileSystem _fs;

  bool isPlaying = false;

  AudioSessionInterruptionListenerHandle? _audioSessionInterruptionListenerHandle;

  Piano(this._as, this._audioSession, this._fs);

  void playNoteOn(int note) => _as.pianoNoteOn(note: note);

  void playNoteOff(int note) => _as.pianoNoteOff(note: note);

  Future<void> setVolume(double volume) async => _as.pianoSetVolume(volume: volume);

  Future<bool> initPiano(String soundFontPath) async {
    // rust cannot access asset files which are not really files on disk, so we need to copy to a temp file
    final tempSoundFontPath = '${_fs.tmpFolderPath}/sound_font.sf2';
    final byteData = await rootBundle.load(soundFontPath);
    final bytes = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    await _fs.saveFileAsBytes(tempSoundFontPath, bytes);
    return _as.pianoSetup(soundFontPath: tempSoundFontPath);
  }

  Future<void> pianoStart(double concertPitch, int soundFontIndex) async {
    if (isPlaying) return;
    _audioSessionInterruptionListenerHandle = await _audioSession.registerInterruptionListener(pianoStop);

    bool initSuccess = await initPiano(SoundFont.values[soundFontIndex].file);
    await _audioSession.preparePlayback();
    if (!initSuccess) return;

    pianoSetConcertPitch(concertPitch);

    bool success = await _as.pianoStart();
    isPlaying = success;
  }

  Future<void> pianoStop() async {
    if (_audioSessionInterruptionListenerHandle != null) {
      _audioSession.unregisterInterruptionListener(_audioSessionInterruptionListenerHandle!);
      _audioSessionInterruptionListenerHandle = null;
    }
    if (isPlaying) {
      await _as.pianoStop();
    }
    isPlaying = false;
  }

  Future<void> pianoSetConcertPitch(double concertPitch) async {
    bool success = await _as.pianoSetConcertPitch(newConcertPitch: concertPitch);

    if (!success) {
      throw 'Rust library failed to update new concert pitch: $concertPitch';
    }
  }

  Future<void> reloadSoundFont(double concertPitch, String soundFontPath) async {
    await pianoStop();

    if (!await initPiano(soundFontPath)) return;

    await _audioSession.preparePlayback();
    await pianoSetConcertPitch(concertPitch);
    isPlaying = await _as.pianoStart();
  }
}
