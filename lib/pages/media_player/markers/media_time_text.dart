import 'package:flutter/cupertino.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';

class MediaTimeText extends StatelessWidget {
  final Duration duration;

  const MediaTimeText({super.key, required this.duration});

  @override
  Widget build(BuildContext context) {
    return Text(context.l10n.formatDurationWithMillis(duration), style: const TextStyle(color: ColorTheme.primary));
  }
}
