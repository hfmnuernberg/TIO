import 'package:circular_widgets/circular_widgets.dart';
import 'package:flutter/material.dart';
import 'package:tiomusic/pages/metronome/beat_button.dart';
import 'package:tiomusic/pages/metronome/rhythm_segment.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/on_off_button.dart';

class BeatCircle extends StatelessWidget {
  final List<BeatType> beats;
  final List<BeatTypePoly> polyBeats;
  final bool isMain;
  final double centerWidgetRadius;
  final double buttonSize;
  final Color beatButtonColor;
  final bool noInnerBorder;
  final ActiveBeatsModel activeBeatsModel;
  final bool isPlaying;
  final VoidCallback onStartStop;
  final Function(int index) onTapBeat;

  const BeatCircle({
    super.key,
    required this.beats,
    required this.polyBeats,
    required this.isMain,
    required this.centerWidgetRadius,
    required this.buttonSize,
    required this.beatButtonColor,
    required this.noInnerBorder,
    required this.activeBeatsModel,
    required this.isPlaying,
    required this.onStartStop,
    required this.onTapBeat,
  });

  @override
  Widget build(BuildContext context) {
    final items = isMain ? beats : polyBeats;

    return DecoratedBox(
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ColorTheme.primary80)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: CircularWidgets(
          itemBuilder: (context, index) {
            return ListenableBuilder(
              listenable: activeBeatsModel,
              builder: (context, child) {
                final isHighlighted =
                    isMain
                        ? index == activeBeatsModel.mainBeat && activeBeatsModel.mainBeatOn
                        : index == activeBeatsModel.polyBeat && activeBeatsModel.polyBeatOn;

                return BeatButton(
                  color: beatButtonColor,
                  beatTypes: isMain ? getBeatButtonsFromBeats(beats) : getBeatButtonsFromBeatsPoly(polyBeats),
                  beatTypeIndex: index,
                  buttonSize: buttonSize,
                  beatHighlighted: isHighlighted,
                  onTap: () => onTapBeat(index),
                );
              },
            );
          },
          itemsLength: items.length,
          config: CircularWidgetConfig(itemRadius: 16, centerWidgetRadius: centerWidgetRadius),
          centerWidgetBuilder: (context) {
            return noInnerBorder
                ? Container()
                : DecoratedBox(
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ColorTheme.primary80)),
                  child: OnOffButton(
                    isActive: isPlaying,
                    buttonSize: TIOMusicParams.sizeBigButtons,
                    iconOff: Icons.play_arrow,
                    iconOn: TIOMusicParams.pauseIcon,
                    onTap: onStartStop,
                  ),
                );
          },
        ),
      ),
    );
  }
}
