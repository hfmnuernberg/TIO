import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:uuid/uuid.dart';

class MetronomeParams {
  static const Uuid _uuid = Uuid();

  static const String kind = 'metronome';
  static const String displayName = 'Metronome';

  static const String svgIconPath = 'assets/icons/Metronome.svg';

  // General parameters

  // Default BPM value
  static const int defaultBPM = 80;
  // Default random mute value
  static const int defaultRandomMute = 0;
  // Default rhythm
  static const String defaultId = '';
  // this function should be called in the constructor of the RhythmGroup class, to turn the empty string into a unique id
  static String getNewKeyID() {
    return _uuid.v4();
  }

  static const List<BeatType> defaultBeats = [
    BeatType.Accented,
    BeatType.Unaccented,
    BeatType.Unaccented,
    BeatType.Unaccented,
  ];
  static const List<BeatTypePoly> defaultPolyBeats = [];
  static const String defaultNoteKey = NoteValues.quarter;

  // Maximum BPM value
  static const int maxBPM = 500;
  // Minimum BPM value
  static const int minBPM = 10;

  // BPM input

  // Button radius
  static const double plusMinusButtonRadius = 20;
  // Text font size
  static const double numInputTextFontSize = 32;

  // Size of blinking circle
  static const double blinkingCircleRadius = 5;
  // Size of Rhythm Segments
  static const double rhythmSegmentSize = 48;
  // Maximum number of beats
  static const int maxBeatCount = 20;
  // Button radius in popup window
  static const double popupButtonRadius = 20;
  // Text font size in popup window
  static const double popupTextFontSize = 30;

  static const double heightRhythmGroups = 110;

  static SvgPicture icon = SvgPicture.asset(
    svgIconPath,
    colorFilter: const ColorFilter.mode(ColorTheme.primary, BlendMode.srcIn),
  );
}
