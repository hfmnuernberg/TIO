import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tiomusic/pages/media_player/media_player_repeat_button.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';

const String _back10SecondsIcon = 'assets/icons/back_10_seconds.svg';
const String _forward10SecondsIcon = 'assets/icons/forward_10_seconds.svg';
const String _nextMarkerIcon = 'assets/icons/next_marker.svg';
const String _previousMarkerIcon = 'assets/icons/previous_marker.svg';

class PlaybackControls extends StatelessWidget {
  final bool hasMarkers;
  final Key repeatKey;
  final Future<void> Function() onRepeatToggle;
  final Future<void> Function(bool forward) onSkip10Seconds;
  final Future<void> Function(bool forward)? onSkipToMarker;

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
        IconButton(
          onPressed: () async => onSkip10Seconds(false),
          icon: SvgPicture.asset(
            _back10SecondsIcon,
            colorFilter: ColorFilter.mode(ColorTheme.primary, BlendMode.srcIn),
          ),
          tooltip: l10n.mediaPlayerSkip10Backwards,
        ),

        if (hasMarkers)
          IconButton(
            onPressed: () async => onSkipToMarker!(false),
            icon: SvgPicture.asset(
              _previousMarkerIcon,
              colorFilter: ColorFilter.mode(ColorTheme.primary, BlendMode.srcIn),
            ),
            tooltip: l10n.mediaPlayerSkipBackToMarker,
          ),

        Container(
          key: repeatKey,
          child: MediaPlayerRepeatButton(onToggle: onRepeatToggle),
        ),

        if (hasMarkers)
          IconButton(
            onPressed: () async => onSkipToMarker!(true),
            icon: SvgPicture.asset(_nextMarkerIcon, colorFilter: ColorFilter.mode(ColorTheme.primary, BlendMode.srcIn)),
            tooltip: l10n.mediaPlayerSkipForwardToMarker,
          ),

        IconButton(
          onPressed: () async => onSkip10Seconds(true),
          icon: SvgPicture.asset(
            _forward10SecondsIcon,
            colorFilter: ColorFilter.mode(ColorTheme.primary, BlendMode.srcIn),
          ),
          tooltip: l10n.mediaPlayerSkip10Forward,
        ),
      ],
    );
  }
}
