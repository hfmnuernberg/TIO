import 'package:flutter/material.dart';
import 'package:tiomusic/util/constants.dart';

class SmallIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;

  const SmallIconButton({super.key, required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: Material(
        elevation: 16,
        borderRadius: BorderRadius.circular(800),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          radius: TIOMusicParams.sizeSmallButtons,
          child: IconButton(icon: icon, iconSize: TIOMusicParams.sizeSmallButtons, onPressed: onPressed),
        ),
      ),
    );
  }
}
