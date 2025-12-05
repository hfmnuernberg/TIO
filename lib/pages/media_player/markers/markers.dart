import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/pages/media_player/waveform_visualizer.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants/media_player_constants.dart';

class Markers extends StatelessWidget {
  final Float32List rmsValues;
  final double paintedWidth;
  final double waveFormHeight;
  final List<double> markerPositions;
  final double? selectedMarkerPosition;
  final double viewStart;
  final double viewEnd;
  final ValueChanged<double> onTap;

  const Markers({
    super.key,
    required this.rmsValues,
    required this.paintedWidth,
    required this.waveFormHeight,
    required this.markerPositions,
    required this.selectedMarkerPosition,
    required this.viewStart,
    required this.viewEnd,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (paintedWidth <= 0) return const SizedBox.shrink();

    final int totalBins = rmsValues.length;
    if (totalBins <= 0) return const SizedBox.shrink();

    final double markerTop = (waveFormHeight / 2) - MediaPlayerParams.markerIconSize - 20;

    final double clampedStart = viewStart.clamp(0.0, 1.0);
    final double clampedEnd = viewEnd.clamp(clampedStart, 1.0);

    final int firstVisibleIndex = (clampedStart * (totalBins - 1)).round().clamp(0, totalBins - 1);
    final int lastVisibleIndex = (clampedEnd * (totalBins - 1)).round().clamp(firstVisibleIndex, totalBins - 1);
    final int visibleBins = (lastVisibleIndex - firstVisibleIndex + 1).clamp(1, totalBins);

    final List<Widget> children = [];

    for (final position in markerPositions) {
      final bool isSelected = selectedMarkerPosition != null && position == selectedMarkerPosition;

      final double clampedPos = position.clamp(0.0, 1.0);
      if (clampedPos < clampedStart || clampedPos > clampedEnd) continue;

      final int globalIndex = (clampedPos * (totalBins - 1)).round().clamp(0, totalBins - 1);
      final int localIndex = globalIndex - firstVisibleIndex;
      if (localIndex < 0 || localIndex >= visibleBins) continue;

      final double markerCenter = WaveformVisualizer.xForIndex(localIndex, paintedWidth, visibleBins);
      final double markerLeft = markerCenter - (MediaPlayerParams.markerButton / 2);

      children.add(
        MarkerButton(
          startPosition: markerLeft,
          topPosition: markerTop,
          isSelected: isSelected,
          onTap: () => onTap(position),
        ),
      );
    }

    return Stack(children: children);
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
