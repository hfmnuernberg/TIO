import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';

const double markerSize = 32;
const double arrowSize = 20;
const double arrowOffset = 10;
const color = ColorTheme.primary;

class SkipToMarkerIcon extends StatelessWidget {
  final bool forward;

  const SkipToMarkerIcon({super.key, required this.forward});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!forward) Icon(Icons.arrow_drop_down, size: markerSize, color: color),
        Transform.translate(
          offset: Offset(forward ? arrowOffset : -arrowOffset, 0),
          child: Icon(forward ? Icons.arrow_forward : Icons.arrow_back, size: arrowSize, color: color),
        ),
        if (forward) Icon(Icons.arrow_drop_down, size: markerSize, color: color),
      ],
    );
  }
}
