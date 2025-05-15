import 'package:flutter/material.dart';
import 'package:tiomusic/util/constants.dart';

class TioIconButton extends StatelessWidget {
  final Widget icon;
  final String? tooltip;
  final double? size;
  final VoidCallback? onPressed;

  const TioIconButton({super.key, required this.icon, this.tooltip, this.size, this.onPressed});

  factory TioIconButton.xs({required Widget icon, String? tooltip, VoidCallback? onPressed}) =>
      TioIconButton(icon: icon, tooltip: tooltip, onPressed: onPressed);

  factory TioIconButton.sm({required Widget icon, String? tooltip, VoidCallback? onPressed}) =>
      TioIconButton(icon: icon, tooltip: tooltip, size: TIOMusicParams.sizeSmallButtons, onPressed: onPressed);

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
          child: IconButton(
            icon: icon,
            iconSize: TIOMusicParams.sizeSmallButtons,
            tooltip: tooltip,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
