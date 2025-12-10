import 'package:flutter/material.dart';
import 'package:tiomusic/pages/media_player/markers/media_time_text.dart';

class WaveformTimeLabels extends StatelessWidget {
  final Duration fileDuration;
  final double position;

  const WaveformTimeLabels({
    super.key,
    required this.fileDuration,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    final double clampedPos = position.clamp(0.0, 1.0);
    final duration = Duration(milliseconds: (fileDuration.inMilliseconds * clampedPos).round());

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(child: MediaTimeText(duration: duration)),
      ],
    );
  }
}
