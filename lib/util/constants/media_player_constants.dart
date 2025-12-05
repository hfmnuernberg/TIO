import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';

class MediaPlayerParams {
  static const String kind = 'media_player';
  static const String displayName = 'Media Player';

  static const double defaultPitchSemitones = 0;
  static const double defaultSpeedFactor = 1;
  static const double defaultRangeStart = 0;
  static const double defaultRangeEnd = 1;
  static const String defaultPath = '';
  static const bool defaultRepeat = false;

  static const double binWidth = 8;

  static const double markerIconSize = 36;
  static const double markerButton = 52;

  static const Icon icon = Icon(Icons.play_arrow, color: ColorTheme.primary);
}
