import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/on_off_button.dart';

class MarkerEditControls extends StatelessWidget {
  final Key keyAddRemove;
  final bool isPlaying;
  final bool hasSelectedMarker;
  final VoidCallback onTogglePlaying;
  final VoidCallback onRemoveSelectedMarker;
  final VoidCallback onAddMarker;

  const MarkerEditControls({
    super.key,
    required this.keyAddRemove,
    required this.isPlaying,
    required this.hasSelectedMarker,
    required this.onTogglePlaying,
    required this.onRemoveSelectedMarker,
    required this.onAddMarker,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final bool markerIsActive = hasSelectedMarker;
    final IconData markerIcon = hasSelectedMarker ? Icons.delete_outlined : Icons.add;
    final String markerTooltip = hasSelectedMarker ? l10n.mediaPlayerRemoveMarker : l10n.mediaPlayerAddMarker;
    final VoidCallback markerOnTap = hasSelectedMarker ? onRemoveSelectedMarker : onAddMarker;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const PlaceholderButton(buttonSize: TIOMusicParams.sizeSmallButtons),
          OnOffButton(
            isActive: isPlaying,
            onTap: onTogglePlaying,
            buttonSize: TIOMusicParams.sizeBigButtons,
            iconOff: Icons.play_arrow,
            iconOn: TIOMusicParams.pauseIcon,
            tooltipOff: l10n.mediaPlayerPause,
            tooltipOn: l10n.mediaPlayerPlay,
          ),
          OnOffButton(
            key: keyAddRemove,
            isActive: markerIsActive,
            onTap: markerOnTap,
            buttonSize: TIOMusicParams.sizeSmallButtons,
            iconOff: markerIcon,
            iconOn: markerIcon,
            tooltipOff: markerTooltip,
            tooltipOn: markerTooltip,
          ),
        ],
      ),
    );
  }
}
