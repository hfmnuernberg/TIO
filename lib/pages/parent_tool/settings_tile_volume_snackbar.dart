import 'package:flutter/material.dart';
import 'package:tiomusic/pages/metronome/metronome.dart';
import 'package:tiomusic/util/color_constants.dart';

Icon? getVolumeInfoIcon(deviceVolumeLevel) {
  if (deviceVolumeLevel == VolumeLevel.muted) return const Icon(Icons.warning_amber, color: ColorTheme.error);
  if (deviceVolumeLevel == VolumeLevel.low) return const Icon(Icons.warning_amber, color: ColorTheme.primary);
  if (deviceVolumeLevel == VolumeLevel.normal) return const Icon(Icons.info_outline);
  return null;
}

Text _getSnackbarTextContent(deviceVolumeLevel) {
  if (deviceVolumeLevel == VolumeLevel.muted) {
    return Text(
        'The device volume is muted. Please make sure to adjust the device volume in addition to the metronome volume.');
  }
  if (deviceVolumeLevel == VolumeLevel.low) {
    return Text(
        'The device volume is set very low. Please make sure to adjust the device volume in addition to the metronome volume.');
  }
  return Text('If the volume is still too low please use an external speaker.');
}

showSnackbar({
  required BuildContext context,
  required VolumeLevel? deviceVolumeLevel,
}) =>
    () => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _getSnackbarTextContent(deviceVolumeLevel),
        duration: const Duration(seconds: 5),
        backgroundColor: ColorTheme.surfaceTint,
        behavior: SnackBarBehavior.floating,
      ));

