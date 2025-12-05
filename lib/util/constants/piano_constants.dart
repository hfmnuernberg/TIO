import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';

class PianoParams {
  static const String kind = 'piano';
  static const String displayName = 'Piano';

  static const int defaultKeyboardPosition = 60;

  // the lowest and highest midi notes should be white keys
  static const int lowestMidiNote = 21;
  static const int highestMidiNote = 108;

  static const int numberOfWhiteKeys = 12;

  static const int defaultSoundFontIndex = 0;

  static const Icon icon = Icon(Icons.piano, color: ColorTheme.primary);
  static const String pedalIcon = 'assets/icons/piano_pedal.svg';
}
