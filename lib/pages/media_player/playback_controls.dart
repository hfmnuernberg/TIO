import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/pages/media_player/media_player_repeat_button.dart';
import 'package:tiomusic/pages/media_player/skip_to_marker_icon.dart';

class PlaybackControls extends StatelessWidget {
  final bool hasMarkers;
  final Key repeatKey;
  final Future<void> Function() onRepeatToggle;
  final Future<void> Function(bool forward) onSkip10Seconds;
  final Future<void> Function(bool forward) onSkipToMarker;

  const PlaybackControls({
    super.key,
    required this.hasMarkers,
    required this.repeatKey,
    required this.onRepeatToggle,
    required this.onSkip10Seconds,
    required this.onSkipToMarker,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TextButton(onPressed: () => onSkip10Seconds(false), child: Text('-10 ${l10n.mediaPlayerSecShort}')),

        if (hasMarkers)
          IconButton(
            onPressed: () => onSkipToMarker(false),
            icon: SkipToMarkerIcon(forward: false),
            tooltip: l10n.mediaPlayerSkipBackToMarker,
          ),

        Container(
          key: repeatKey,
          child: MediaPlayerRepeatButton(onToggle: onRepeatToggle),
        ),

        if (hasMarkers)
          IconButton(
            onPressed: () => onSkipToMarker(true),
            icon: SkipToMarkerIcon(forward: true),
            tooltip: l10n.mediaPlayerSkipForwardToMarker,
          ),

        TextButton(onPressed: () => onSkip10Seconds(true), child: Text('+10 ${l10n.mediaPlayerSecShort}')),
      ],
    );
  }
}
