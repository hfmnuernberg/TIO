import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/pages/media_player/waveform_visualizer.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';

class Markers extends StatelessWidget {
  final Float32List rmsValues;
  final double paintedWidth;
  final double waveFormHeight;
  final List<double> markerPositions;
  final double? selectedMarkerPosition;
  final ValueChanged<double> onTap;

  const Markers({
    super.key,
    required this.rmsValues,
    required this.paintedWidth,
    required this.waveFormHeight,
    required this.markerPositions,
    required this.selectedMarkerPosition,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final int binCount = rmsValues.length;
    final double markerTop = (waveFormHeight / 2) - MediaPlayerParams.markerIconSize - 20;

    return Stack(
      children: markerPositions.map((position) {
        final bool isSelected = selectedMarkerPosition != null && position == selectedMarkerPosition;

        final int markerBinIndex = (position.clamp(0.0, 1.0) * (binCount - 1)).round();
        final double markerCenter = WaveformVisualizer.xForIndex(markerBinIndex, paintedWidth, binCount);
        final double markerLeft = TIOMusicParams.edgeInset + (markerCenter - (MediaPlayerParams.markerButton / 2));

        return MarkerButton(
          startPosition: markerLeft,
          topPosition: markerTop,
          isSelected: isSelected,
          onTap: () => onTap(position),
        );
      }).toList(),
    );
  }
}

class MarkerButton extends StatelessWidget {
  final double startPosition;
  final double topPosition;
  final bool isSelected;
  final VoidCallback onTap;

  const MarkerButton({
    super.key,
    required this.startPosition,
    required this.topPosition,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: startPosition,
      top: topPosition,
      child: IconButton(
        icon: Icon(
          isSelected ? Icons.arrow_drop_down_circle_outlined : Icons.arrow_drop_down,
          color: ColorTheme.primary,
          size: MediaPlayerParams.markerIconSize,
        ),
        tooltip: context.l10n.mediaPlayerMarker,
        onPressed: onTap,
      ),
    );
  }
}
