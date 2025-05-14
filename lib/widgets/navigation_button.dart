import 'package:flutter/material.dart';

class NavigationButton extends StatelessWidget {
  final Widget icon;
  final String? tooltip;
  final VoidCallback? onPressed;

  const NavigationButton({super.key, required this.icon, this.tooltip, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: Material(
        elevation: 16,
        borderRadius: BorderRadius.circular(800),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(icon: icon, tooltip: tooltip, onPressed: onPressed),
        ),
      ),
    );
  }
}
