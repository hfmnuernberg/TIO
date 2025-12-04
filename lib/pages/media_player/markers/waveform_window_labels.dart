import 'package:flutter/material.dart';
import 'package:tiomusic/pages/media_player/markers/media_time_text.dart';
import 'package:tiomusic/util/color_constants.dart';

class WaveformWindowLabels extends StatelessWidget {
  final Duration fileDuration;
  final double viewStart;
  final double viewEnd;

  const WaveformWindowLabels({super.key, required this.fileDuration, required this.viewStart, required this.viewEnd});

  @override
  Widget build(BuildContext context) {
    final totalMs = fileDuration.inMilliseconds;
    if (totalMs <= 0) return const SizedBox.shrink();

    final windowStartTime = Duration(milliseconds: (totalMs * viewStart).round());
    final windowEndTime = Duration(milliseconds: (totalMs * viewEnd).round());

    return Row(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RotatedBox(
              quarterTurns: 1,
              child: const Icon(Icons.vertical_align_bottom, size: 16, color: ColorTheme.primary),
            ),
            const SizedBox(width: 4),
            MediaTimeText(duration: windowStartTime),
          ],
        ),
        const Spacer(),
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
}
