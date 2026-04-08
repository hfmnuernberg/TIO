import 'package:flutter/cupertino.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/media_time_format.dart';

class MediaTimeText extends StatelessWidget {
  final Duration duration;

  const MediaTimeText({super.key, required this.duration});

  @override
  Widget build(BuildContext context) {
    return Text(formatMediaDuration(duration), style: const TextStyle(color: ColorTheme.primary));
  }
}
