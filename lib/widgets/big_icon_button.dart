import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';

class BigIconButton extends StatelessWidget {
  final Function? onPressed;
  final IconData icon;

  const BigIconButton({super.key, this.onPressed, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: Material(
        elevation: 16.0,
        borderRadius: BorderRadius.circular(800.0),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          radius: TIOMusicParams.sizeBigButtons,
          child: IconButton(
            onPressed: () {
              if (onPressed != null) {
                onPressed!();
              }
            },
            iconSize: TIOMusicParams.sizeBigButtons,
            icon: Icon(
              icon,
              color: ColorTheme.tertiary,
            ),
          ),
        ),
      ),
    );
  }
}
