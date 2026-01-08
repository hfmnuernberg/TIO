import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tiomusic/util/color_constants.dart';

class TunerParams {
  static const String kind = 'tuner';
  static const String displayName = 'Tuner';

  static const String svgIconPath = 'assets/icons/Tuner.svg';

  static const double defaultConcertPitch = 440;

  static SvgPicture icon = SvgPicture.asset(
    svgIconPath,
    colorFilter: const ColorFilter.mode(ColorTheme.primary, BlendMode.srcIn),
  );
}
