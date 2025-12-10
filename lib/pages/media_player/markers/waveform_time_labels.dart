import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tiomusic/pages/media_player/markers/media_time_text.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants/media_player_constants.dart';

class WaveformTimeLabels extends StatelessWidget {
  final Duration fileDuration;
  final double rangeStart;
  final double rangeEnd;
  final double? position;

  const WaveformTimeLabels({
    super.key,
    required this.fileDuration,
    required this.rangeStart,
    required this.rangeEnd,
    this.position,
  });

  @override
  Widget build(BuildContext context) {
    final totalMs = fileDuration.inMilliseconds;
    if (totalMs <= 0) return const SizedBox.shrink();

    if (position != null) {
      final double clampedPos = position!.clamp(0.0, 1.0);
      final duration = Duration(milliseconds: (totalMs * clampedPos).round());

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [MediaTimeText(duration: duration)],
      );
    }

    final windowStartTime = Duration(milliseconds: (totalMs * rangeStart.clamp(0.0, 1.0)).round());
    final windowEndTime = Duration(milliseconds: (totalMs * rangeEnd.clamp(0.0, 1.0)).round());

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MediaTimeText(duration: windowStartTime),
        const SizedBox(width: 8),
        SvgPicture.asset(
          MediaPlayerParams.arrowRange,
          height: 20,
          width: 20,
          colorFilter: const ColorFilter.mode(ColorTheme.primary, BlendMode.srcIn),
        ),
        const SizedBox(width: 8),
        MediaTimeText(duration: windowEndTime),
      ],
    );
  }
}
