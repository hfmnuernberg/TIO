import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants/constants.dart';

class SettingsButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const SettingsButton({super.key, required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: TIOMusicParams.edgeInset,
        right: TIOMusicParams.edgeInset,
        top: 4,
        bottom: 4,
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        tileColor: ColorTheme.surface,
        textColor: ColorTheme.surfaceTint,
        iconColor: ColorTheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: onTap,
      ),
    );
  }
}
