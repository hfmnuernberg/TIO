import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/pages/media_player/markers/media_time_text.dart';
import 'package:tiomusic/pages/media_player/markers/waveform_viewport_controller.dart';
import 'package:tiomusic/util/color_constants.dart';

class WaveformGestureControls extends StatelessWidget {
  final Duration fileDuration;
  final double viewStart;
  final double viewEnd;
  final WaveformViewportController? viewport;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onScrollLeft;
  final VoidCallback? onScrollRight;

  const WaveformGestureControls({
    super.key,
    required this.fileDuration,
    required this.viewStart,
    required this.viewEnd,
    this.viewport,
    this.onZoomIn,
    this.onZoomOut,
    this.onScrollLeft,
    this.onScrollRight,
  });

  @override
  Widget build(BuildContext context) {
    final totalMs = fileDuration.inMilliseconds;
    if (totalMs <= 0) return const SizedBox.shrink();

    final windowStartTime = Duration(milliseconds: (totalMs * viewStart).round());
    final windowEndTime = Duration(milliseconds: (totalMs * viewEnd).round());

    final l10n = context.l10n;

    final span = viewport!.currentSpan;
    final canZoomIn = span > viewport!.minSpan + 1e-6;
    final canZoomOut = span < viewport!.maxSpan;
    final canScrollLeft = viewport!.viewStart > 0.0;
    final canScrollRight = viewport!.viewEnd < 1.0;

    return Row(
      children: [
        Row(
          children: [
            RotatedBox(
              quarterTurns: 1,
              child: const Icon(Icons.vertical_align_bottom, size: 16, color: ColorTheme.primary),
            ),
            const SizedBox(width: 4),
            MediaTimeText(duration: windowStartTime),
          ],
        ),
        Expanded(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _iconButton(
                  icon: const Icon(Icons.zoom_out),
                  tooltip: l10n.mediaPlayerWaveformZoomOut,
                  enabled: canZoomOut,
                  onPressed: onZoomOut,
                ),
                _iconButton(
                  icon: const Icon(Icons.west),
                  tooltip: l10n.mediaPlayerWaveformScrollLeft,
                  enabled: canScrollLeft,
                  onPressed: onScrollLeft,
                ),
                _iconButton(
                  icon: const Icon(Icons.east),
                  tooltip: l10n.mediaPlayerWaveformScrollRight,
                  enabled: canScrollRight,
                  onPressed: onScrollRight,
                ),
                _iconButton(
                  icon: const Icon(Icons.zoom_in),
                  tooltip: l10n.mediaPlayerWaveformZoomIn,
                  enabled: canZoomIn,
                  onPressed: onZoomIn,
                ),
              ],
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MediaTimeText(duration: windowEndTime),
            const SizedBox(width: 4),
            RotatedBox(
              quarterTurns: 3,
              child: const Icon(Icons.vertical_align_bottom, size: 16, color: ColorTheme.primary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _iconButton({
    required Icon icon,
    required String tooltip,
    required bool enabled,
    required VoidCallback? onPressed,
  }) {
    return IconButton(
      iconSize: 20,
      visualDensity: VisualDensity(horizontal: -3, vertical: -3),
      icon: icon,
      tooltip: tooltip,
      color: enabled ? ColorTheme.primary : ColorTheme.secondary,
      onPressed: enabled ? onPressed : null,
    );
  }
}
