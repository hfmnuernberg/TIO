import 'package:flutter/material.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/pages/metronome/metronome.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/card_list_tile.dart';

Text getSnackbarTextContent(VolumeLevel? deviceVolumeLevel) {
  if (deviceVolumeLevel == VolumeLevel.muted) {
    return Text(
        'The device volume is set to silent. Please make sure to adjust the device volume in addition to the metronome volume.');
  }
  if (deviceVolumeLevel == VolumeLevel.low) {
    return Text(
        'The device volume is set very low. Please make sure to adjust the device volume in addition to the metronome volume.');
  }
  return Text(
      'The device volume is set very high. Please be careful! If you want to increase the volume even further, we recommend using an external speaker.');
}

class SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final dynamic leadingIcon;
  final Widget settingPage;
  final ProjectBlock block;
  final Function? callOnReturn;
  final Function? callBeforeOpen;
  final bool inactive;
  final VolumeLevel? deviceVolumeLevel;

  const SettingsTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leadingIcon,
    required this.settingPage,
    required this.block,
    this.callOnReturn,
    this.callBeforeOpen,
    this.inactive = false,
    this.deviceVolumeLevel,
  });

  Icon? getInfoIcon() {
    if (deviceVolumeLevel == VolumeLevel.muted) return const Icon(Icons.warning_amber, color: ColorTheme.tertiaryContainer);
    if (deviceVolumeLevel == VolumeLevel.low) return const Icon(Icons.warning_amber, color: ColorTheme.primary);
    if (deviceVolumeLevel == VolumeLevel.normal) return const Icon(Icons.info_outline);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final infoIcon = getInfoIcon();
    return CardListTile(
      title: title,
      subtitle: subtitle,
      textColor: inactive ? ColorTheme.secondary : ColorTheme.primary,
      leadingIconColor: inactive ? ColorTheme.secondary : ColorTheme.primary,
      trailingIcon: IconButton(
        onPressed: inactive
            ? null
            : () {
                if (callBeforeOpen != null) {
                  callBeforeOpen!();
                }
                openSettingPage(settingPage, context, block, callbackOnReturn: callOnReturn ?? (value) {});
              },
        icon: const Icon(Icons.arrow_forward),
        color: ColorTheme.primaryFixedDim,
        disabledColor: ColorTheme.secondary,
      ),
      menuIconOne: infoIcon == null
          ? null
          : IconButton(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: getSnackbarTextContent(deviceVolumeLevel),
                    duration: Duration(seconds: 5),
                  ),
                );
              },
              icon: infoIcon,
              color: ColorTheme.surfaceTint,
            ),
      leadingPicture: leadingIcon is String
          ? leadingIcon
          : Icon(
              leadingIcon,
              color: inactive ? ColorTheme.secondary : ColorTheme.primary,
            ),
      onTapFunction: () {
        if (callBeforeOpen != null) {
          callBeforeOpen!();
        }
        openSettingPage(settingPage, context, block, callbackOnReturn: callOnReturn ?? (value) {});
      },
      disableTap: inactive,
    );
  }
}
