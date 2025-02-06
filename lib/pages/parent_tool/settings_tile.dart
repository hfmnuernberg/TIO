import 'package:flutter/material.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/card_list_tile.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final dynamic leadingIcon;
  final Widget settingPage;
  final ProjectBlock block;
  final Function? callOnReturn;
  final Function? callBeforeOpen;
  final bool inactive;
  final Icon icon;
  final VoidCallback? onIconPressed;

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
    this.icon = const Icon(Icons.info),
    this.onIconPressed,
  });

  @override
  Widget build(BuildContext context) {
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
      menuIconOne: onIconPressed == null
          ? null
          : IconButton(
              onPressed: onIconPressed,
              icon: icon,
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
