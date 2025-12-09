import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/pages/media_player/markers/media_time_text.dart';
import 'package:tiomusic/pages/media_player/markers/waveform_viewport_controller.dart';
import 'package:tiomusic/util/color_constants.dart';

class WaveformGestureControls extends StatelessWidget {
  final Duration fileDuration;
  final double position;
  final WaveformViewportController viewport;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onScrollLeft;
  final VoidCallback onScrollRight;

  const WaveformGestureControls({
    super.key,
    required this.fileDuration,
    required this.position,
    required this.viewport,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onScrollLeft,
    required this.onScrollRight,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const enabledColor = ColorTheme.primary;
    const disabledColor = ColorTheme.secondary;

    final double span = viewport.currentSpan;
    final bool canZoomIn = span > viewport.minSpan;
    final bool canZoomOut = span < viewport.maxSpan;
    final bool canScrollLeft = viewport.viewStart > 0.0;
    final bool canScrollRight = viewport.viewEnd < 1.0;

    final double clampedPos = position.clamp(0.0, 1.0);
    final duration = Duration(milliseconds: (fileDuration.inMilliseconds * clampedPos).round());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.zoom_out),
          tooltip: l10n.mediaPlayerWaveformZoomOut,
          color: canZoomOut ? enabledColor : disabledColor,
          onPressed: canZoomOut ? onZoomOut : null,
        ),
        IconButton(
          icon: const Icon(Icons.west),
          tooltip: l10n.mediaPlayerWaveformScrollLeft,
          color: canScrollLeft ? enabledColor : disabledColor,
          onPressed: canScrollLeft ? onScrollLeft : null,
        ),
        Center(child: MediaTimeText(duration: duration)),
        IconButton(
          icon: const Icon(Icons.east),
          tooltip: l10n.mediaPlayerWaveformScrollRight,
          color: canScrollRight ? enabledColor : disabledColor,
          onPressed: canScrollRight ? onScrollRight : null,
        ),
        IconButton(
          icon: const Icon(Icons.zoom_in),
          tooltip: l10n.mediaPlayerWaveformZoomIn,
          color: canZoomIn ? enabledColor : disabledColor,
          onPressed: canZoomIn ? onZoomIn : null,
        ),
      ],
    );
  }
}
