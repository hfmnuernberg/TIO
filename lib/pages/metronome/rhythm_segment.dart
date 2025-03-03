import 'package:flutter/material.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/pages/metronome/beat_button.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';

class RhythmSegment extends StatefulWidget {
  const RhythmSegment({
    super.key,
    required this.activeBeatsNotifier,
    required this.barIdx,
    required this.editFunction,
    required this.metronomeBlock,
    required this.isSecondary,
  });

  final ActiveBeatsModel activeBeatsNotifier;
  final MetronomeBlock metronomeBlock;
  final int barIdx;
  final Function editFunction;
  final bool isSecondary;

  @override
  State<RhythmSegment> createState() => _RhythmSegmentState();
}

class _RhythmSegmentState extends State<RhythmSegment> {
  @override
  Widget build(BuildContext context) {
    var rhythmGroups = widget.metronomeBlock.rhythmGroups;
    if (widget.isSecondary) {
      rhythmGroups = widget.metronomeBlock.rhythmGroups2;
    }

    // this variable needs to be set here and not in initState, because otherwise the box size of the group would not change with changing the number of beats
    double? spaceForEachPoly;
    double? spaceForEachMainBeat;
    double totalGroupWidth = TIOMusicParams.beatButtonSizeMainPage + TIOMusicParams.beatButtonPadding * 2;
    if (rhythmGroups[widget.barIdx].polyBeats.length > rhythmGroups[widget.barIdx].beats.length) {
      totalGroupWidth = totalGroupWidth * rhythmGroups[widget.barIdx].polyBeats.length;
      spaceForEachMainBeat = totalGroupWidth / rhythmGroups[widget.barIdx].beats.length;
    } else {
      totalGroupWidth = totalGroupWidth * rhythmGroups[widget.barIdx].beats.length;
      spaceForEachPoly = totalGroupWidth / rhythmGroups[widget.barIdx].polyBeats.length;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: ColorTheme.primary87),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            SizedBox(
              width: totalGroupWidth,
              child: Row(
                children: _beatButtons(rhythmGroups[widget.barIdx].beats.length, spaceForEachMainBeat, rhythmGroups),
              ),
            ),
            SizedBox(
              // sized box with specific width is needed here for the row to span the whole group width
              width: totalGroupWidth,
              child:
                  rhythmGroups[widget.barIdx].polyBeats.isEmpty
                      ? const SizedBox(
                        height: TIOMusicParams.beatButtonSizeMainPage + TIOMusicParams.beatButtonPadding * 2,
                      )
                      : Row(
                        children: _beatButtons(
                          rhythmGroups[widget.barIdx].polyBeats.length,
                          spaceForEachPoly,
                          rhythmGroups,
                          isPoly: true,
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _beatButtons(int number, double? spaceForEachBeat, var rhythmGroups, {bool isPoly = false}) {
    List<Widget> buttons = [];

    for (int i = 0; i < number; i++) {
      Widget beat;

      var button = ListenableBuilder(
        listenable: widget.activeBeatsNotifier,
        builder: (context, child) {
          bool highlight = false;
          bool polyBeatOn = widget.activeBeatsNotifier.polyBeatOn;
          bool mainBeatOn = widget.activeBeatsNotifier.mainBeatOn;
          int polyBar = widget.activeBeatsNotifier.polyBar;
          int mainBar = widget.activeBeatsNotifier.mainBar;
          int polyBeat = widget.activeBeatsNotifier.polyBeat;
          int mainBeat = widget.activeBeatsNotifier.mainBeat;
          if (widget.isSecondary) {
            polyBeatOn = widget.activeBeatsNotifier.polyBeatOn2;
            mainBeatOn = widget.activeBeatsNotifier.mainBeatOn2;
            polyBar = widget.activeBeatsNotifier.polyBar2;
            mainBar = widget.activeBeatsNotifier.mainBar2;
            polyBeat = widget.activeBeatsNotifier.polyBeat2;
            mainBeat = widget.activeBeatsNotifier.mainBeat2;
          }

          if (isPoly && polyBeatOn) {
            if (polyBar == widget.barIdx && polyBeat == i) {
              highlight = true;
            }
          } else if (!isPoly && mainBeatOn) {
            if (mainBar == widget.barIdx && mainBeat == i) {
              highlight = true;
            }
          }

          return BeatButton(
            color: ColorTheme.surfaceTint,
            beatTypes:
                isPoly
                    ? getBeatButtonsFromBeatsPoly(rhythmGroups[widget.barIdx].polyBeats)
                    : getBeatButtonsFromBeats(rhythmGroups[widget.barIdx].beats),
            beatTypeIndex: i,
            buttonSize: TIOMusicParams.beatButtonSizeMainPage,
            beatHighlighted: highlight,
          );
        },
      );

      if (!isPoly) {
        var noteSymbol = CircleAvatar(
          radius: TIOMusicParams.beatButtonSizeBig / 4,
          backgroundColor: Colors.transparent,
          child: NoteHandler.getNoteSvg(rhythmGroups[widget.barIdx].noteKey),
        );

        beat = Column(children: [noteSymbol, const SizedBox(height: 4), button]);
      } else {
        beat = button;
      }

      buttons.add(Padding(padding: const EdgeInsets.all(TIOMusicParams.beatButtonPadding), child: beat));

      if (spaceForEachBeat != null) {
        buttons.add(
          SizedBox(
            width: spaceForEachBeat - TIOMusicParams.beatButtonSizeMainPage - TIOMusicParams.beatButtonPadding * 2,
          ),
        );
      }
    }

    return buttons;
  }
}

// this change notifier gets changed when a beat is starting or ending
// the change notifier then notifies the rhythm segments to change the blinking dot

class ActiveBeatsModel with ChangeNotifier {
  // first metronome
  bool mainBeatOn = false;
  bool polyBeatOn = false;

  int mainBar = 0;
  int polyBar = 0;

  int mainBeat = 0;
  int polyBeat = 0;

  // second metronome
  bool mainBeatOn2 = false;
  bool polyBeatOn2 = false;

  int mainBar2 = 0;
  int polyBar2 = 0;

  int mainBeat2 = 0;
  int polyBeat2 = 0;

  void setBeatOnOff(bool on, int barIdx, int beatIdx, bool isPoly, bool isSecondary) {
    if (isSecondary) {
      if (isPoly) {
        polyBeatOn2 = on;
        polyBar2 = barIdx;
        polyBeat2 = beatIdx;
      } else {
        mainBeatOn2 = on;
        mainBar2 = barIdx;
        mainBeat2 = beatIdx;
      }
    } else {
      if (isPoly) {
        polyBeatOn = on;
        polyBar = barIdx;
        polyBeat = beatIdx;
      } else {
        mainBeatOn = on;
        mainBar = barIdx;
        mainBeat = beatIdx;
      }
    }

    notifyListeners();
  }
}
