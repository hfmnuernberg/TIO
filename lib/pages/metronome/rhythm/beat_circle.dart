import 'package:circular_widgets/circular_widgets.dart';
import 'package:flutter/material.dart';
import 'package:tiomusic/pages/metronome/beat_button.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/on_off_button.dart';

class BeatCircle extends StatelessWidget {
  final int beatCount;
  final int? currentBeatIndex;
  final List<BeatButtonType> beatTypes;
  final bool isPlaying;
  final double centerWidgetRadius;
  final double buttonSize;
  final Color beatButtonColor;
  final bool noInnerBorder;
  final VoidCallback onStartStop;
  final Function(int index) onTapBeat;

  const BeatCircle({
    super.key,
    required this.beatCount,
    required this.currentBeatIndex,
    required this.beatTypes,
    required this.isPlaying,
    required this.centerWidgetRadius,
    required this.buttonSize,
    required this.beatButtonColor,
    required this.noInnerBorder,
    required this.onStartStop,
    required this.onTapBeat,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ColorTheme.primary80)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: CircularWidgets(
          itemBuilder:
              (context, index) => BeatButton(
                color: beatButtonColor,
                beatTypes: beatTypes,
                beatTypeIndex: index,
                buttonSize: buttonSize,
                beatHighlighted: index == currentBeatIndex,
                onTap: () => onTapBeat(index),
              ),
          itemsLength: beatCount,
          config: CircularWidgetConfig(itemRadius: 16, centerWidgetRadius: centerWidgetRadius),
          centerWidgetBuilder:
              (context) =>
                  noInnerBorder
                      ? Container()
                      : DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: ColorTheme.primary80),
                        ),
                        child: OnOffButton(
                          isActive: isPlaying,
                          buttonSize: TIOMusicParams.sizeBigButtons,
                          iconOff: Icons.play_arrow,
                          iconOn: TIOMusicParams.pauseIcon,
                          onTap: onStartStop,
                        ),
                      ),
        ),
      ),
    );
  }
}
