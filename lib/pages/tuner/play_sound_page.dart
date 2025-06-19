import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/tuner_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/tuner_type.dart';
import 'package:tiomusic/pages/tuner/tuner_functions.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/util_midi.dart';
import 'package:tiomusic/widgets/dismiss_keyboard.dart';
import 'package:tiomusic/widgets/tuner/chromatic_play_reference.dart';
import 'package:tiomusic/widgets/tuner/instrument_play_reference.dart';

const defaultOctave = 4;
const minOctave = 1;
const maxOctave = 7;

class PlaySoundPage extends StatefulWidget {
  const PlaySoundPage({super.key});

  @override
  State<PlaySoundPage> createState() => _PlaySoundPageState();
}

class _PlaySoundPageState extends State<PlaySoundPage> {
  int octave = defaultOctave;
  int? midi;
  bool isOn = false;

  StreamSubscription<AudioInterruptionEvent>? audioInterruptionListener;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await TunerFunctions.stop();
    });
  }

  @override
  void dispose() {
    audioInterruptionListener?.cancel();
    TunerFunctions.stopGenerator();
    super.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
    audioInterruptionListener?.cancel();
    TunerFunctions.stopGenerator();
  }

  // void _onButtonsChanged() async {
  //   if (buttonListener.buttonOn) {
  //     if (!running) {
  //       await TunerFunctions.startGenerator();
  //       running = true;
  //
  //       audioInterruptionListener = (await AudioSession.instance).interruptionEventStream.listen((event) {
  //         if (event.type == AudioInterruptionType.unknown) {
  //           TunerFunctions.stopGenerator();
  //           setState(() {
  //             running = false;
  //             buttonListener.turnOff();
  //           });
  //         }
  //       });
  //     }
  //
  //     if (running) {
  //       generatorNoteOn(newFreq: buttonListener.freq);
  //       setState(() => frequency = buttonListener.freq);
  //     }
  //   } else {
  //     generatorNoteOff();
  //     setState(() => frequency = 0);
  //   }
  // }

  void _handleToggle(int midiNumber) async {
    final isSameButton = midi == midiNumber;
    final wasOn = isOn;

    if (wasOn && isSameButton) {
      // Case: turn off the current note
      generatorNoteOff();
      TunerFunctions.stopGenerator();
      setState(() {
        isOn = false;
        midi = null;
      });
      return;
    }

    if (wasOn && !isSameButton) {
      // Case: switch to a different note (stop current one first)
      generatorNoteOff();
    }

    // Start generator (either first time or switching)
    await TunerFunctions.startGenerator();

    // Reset interruption listener
    audioInterruptionListener?.cancel();
    audioInterruptionListener = (await AudioSession.instance).interruptionEventStream.listen((event) {
      if (event.type == AudioInterruptionType.unknown) {
        TunerFunctions.stopGenerator();
        setState(() {
          isOn = false;
          midi = null;
        });
      }
    });

    // Activate the new note
    setState(() {
      midi = midiNumber;
      isOn = true;
      octave = (midiNumber / 12 - 1).floor();
    });

    generatorNoteOn(newFreq: midiToFreq(midiNumber));
  }

  void _handleChange(newOctave) => setState(() => octave = newOctave);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final frequency = isOn && midi != null ? midiToFreq(midi!) : 0.0;
    final tunerBlock = Provider.of<ProjectBlock>(context, listen: false) as TunerBlock;

    return DismissKeyboard(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(l10n.tunerPlayReference),
          backgroundColor: ColorTheme.surfaceBright,
          foregroundColor: ColorTheme.primary,
        ),
        backgroundColor: ColorTheme.primary92,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (tunerBlock.tunerType == TunerType.chromatic)
              ChromaticPlayReference(
                octave: octave,
                midi: midi,
                frequency: frequency,
                tunerType: tunerBlock.tunerType,
                onOctaveChange: _handleChange,
                onButtonToggle: _handleToggle,
              )
            else
              InstrumentPlayReference(
                octave: octave,
                midi: midi,
                frequency: frequency,
                tunerType: tunerBlock.tunerType,
                onOctaveChange: _handleChange,
                onButtonToggle: _handleToggle,
              ),
          ],
        ),
      ),
    );
  }
}
