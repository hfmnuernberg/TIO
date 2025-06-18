import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/tuner_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/pages/tuner/tuner_functions.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/dismiss_keyboard.dart';
import 'package:tiomusic/widgets/input/number_input_and_slider_int.dart';
import 'package:tiomusic/widgets/tuner/active_reference_sound_button.dart';
import 'package:tiomusic/widgets/tuner/sound_button_grid.dart';

const defaultOctave = 4;
const minOctave = 1;
const maxOctave = 7;

class PlaySoundPage extends StatefulWidget {
  const PlaySoundPage({super.key});

  @override
  State<PlaySoundPage> createState() => _PlaySoundPageState();
}

class _PlaySoundPageState extends State<PlaySoundPage> {
  final ActiveReferenceSoundButton buttonListener = ActiveReferenceSoundButton();
  int octave = defaultOctave;
  double frequency = 0;
  bool running = false;

  StreamSubscription<AudioInterruptionEvent>? audioInterruptionListener;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await TunerFunctions.stop();
      buttonListener.addListener(_onButtonsChanged);
    });
  }

  @override
  void dispose() {
    buttonListener.removeListener(_onButtonsChanged);
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

  void _onButtonsChanged() async {
    if (buttonListener.buttonOn) {
      if (!running) {
        await TunerFunctions.startGenerator();
        running = true;

        audioInterruptionListener = (await AudioSession.instance).interruptionEventStream.listen((event) {
          if (event.type == AudioInterruptionType.unknown) {
            TunerFunctions.stopGenerator();
            setState(() {
              running = false;
              buttonListener.turnOff();
            });
          }
        });
      }

      if (running) {
        generatorNoteOn(newFreq: buttonListener.freq);
        setState(() => frequency = buttonListener.freq);
      }
    } else {
      generatorNoteOff();
      setState(() => frequency = 0);
    }
  }

  void _handleChange(newOctave) {
    if (newOctave > octave) {
      setState(() => frequency = frequency * 2);
    } else if (newOctave < octave) {
      setState(() => frequency = frequency / 2);
    }

    setState(() => octave = newOctave);
  }

  @override
  Widget build(BuildContext context) {
    int offset = (octave - 1) * 12;
    final l10n = context.l10n;
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
            NumberInputAndSliderInt(
              value: octave,
              onChange: _handleChange,
              min: minOctave,
              max: maxOctave,
              step: 1,
              label: l10n.commonOctave,
              textFieldWidth: TIOMusicParams.textFieldWidth1Digit,
            ),
            const SizedBox(height: 40),
            Text(
              '${l10n.tunerFrequency}: ${l10n.formatNumber(double.parse(frequency.toStringAsFixed(1)))} Hz',
              style: const TextStyle(color: ColorTheme.primary),
            ),
            const SizedBox(height: 40),
            SoundButtonGrid(
              tunerType: tunerBlock.tunerType,
              offset: offset,
              buttonListener: buttonListener,
              onOctaveChange: (newOctave) => setState(() => octave = newOctave),
            ),
          ],
        ),
      ),
    );
  }
}
