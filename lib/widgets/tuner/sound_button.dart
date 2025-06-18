import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/blocks/tuner_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/util_midi.dart';
import 'package:tiomusic/widgets/tuner/active_reference_sound_button.dart';

const double buttonWidth = 40;
const double buttonPadding = 4;

class SoundButton extends StatefulWidget {
  final int midiNumber;
  final int idx;
  final ActiveReferenceSoundButton buttonListener;
  final String? customLabel;
  final void Function(int) onOctaveChange;

  const SoundButton({
    super.key,
    required this.midiNumber,
    required this.idx,
    required this.buttonListener,
    this.customLabel,
    required this.onOctaveChange,
  });

  @override
  State<SoundButton> createState() => _SoundButtonState();
}

class _SoundButtonState extends State<SoundButton> {
  late double concertPitch;

  @override
  void initState() {
    super.initState();
    concertPitch = (Provider.of<ProjectBlock>(context, listen: false) as TunerBlock).chamberNoteHz;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.buttonListener,
      builder: (context, child) {
        final bool isButtonOn = widget.buttonListener.buttonOn;
        final bool isSelectedButton = widget.buttonListener.buttonIdx == widget.idx;

        return Listener(
          onPointerDown: (details) async {
            int octave = (widget.midiNumber / 12 - 1).floor();
            widget.onOctaveChange.call(octave);
            setState(() {
              if (isButtonOn) {
                widget.buttonListener.turnOff();
                if (!isSelectedButton) {
                  widget.buttonListener.turnOn(widget.idx, midiToFreq(widget.midiNumber, concertPitch: concertPitch));
                }
              } else {
                widget.buttonListener.turnOn(widget.idx, midiToFreq(widget.midiNumber, concertPitch: concertPitch));
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(buttonPadding),
            child: Container(
              width: buttonWidth,
              height: 60,
              decoration: BoxDecoration(
                color: isSelectedButton && isButtonOn ? ColorTheme.primary : ColorTheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  widget.customLabel ?? midiToNameOneChar(widget.midiNumber),
                  style: TextStyle(color: isSelectedButton && isButtonOn ? ColorTheme.surface : ColorTheme.primary),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
