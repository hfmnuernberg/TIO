import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localization.dart';
import 'package:tiomusic/util/color_constants.dart';

enum VolumeLevel { muted, low, normal }

VolumeLevel getVolumeLevel(double volume) {
  if (volume <= 0.0) return VolumeLevel.muted;
  if (volume <= 0.50) return VolumeLevel.low;
  return VolumeLevel.normal;
}

Color getVolumeInfoIconColor(VolumeLevel volumeLevel) {
  switch (volumeLevel) {
    case VolumeLevel.muted:
      return ColorTheme.error;
    case VolumeLevel.low:
      return ColorTheme.warning;
    case VolumeLevel.normal:
      return ColorTheme.primary;
  }
}

IconData getVolumeInfoIconData(VolumeLevel volumeLevel) {
  switch (volumeLevel) {
    case VolumeLevel.muted:
      return Icons.volume_off;
    case VolumeLevel.low:
      return Icons.volume_down;
    case VolumeLevel.normal:
      return Icons.hearing_disabled;
  }
}

Icon getVolumeInfoIcon(VolumeLevel volumeLevel) =>
    Icon(getVolumeInfoIconData(volumeLevel), color: getVolumeInfoIconColor(volumeLevel));

String getVolumeInfoText(VolumeLevel volumeLevel, AppLocalizations l10n) => switch (volumeLevel) {
  VolumeLevel.muted => l10n.commonVolumeHintMuted,
  VolumeLevel.low => l10n.commonVolumeHintLow,
  VolumeLevel.normal => l10n.commonVolumeHintMid,
};
