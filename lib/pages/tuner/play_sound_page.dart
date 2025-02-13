import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/blocks/tuner_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/pages/tuner/tuner_functions.dart';
import 'package:tiomusic/src/rust/api/api.dart';

import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_midi.dart';
import 'package:tiomusic/widgets/number_input_int_with_slider.dart';
import 'package:tiomusic/widgets/dismiss_keyboard.dart';

const double buttonWidth = 40;
const double buttonPadding = 4;

class PlaySoundPage extends StatefulWidget {
  const PlaySoundPage({super.key});

  @override
  State<PlaySoundPage> createState() => _PlaySoundPageState();
}

class _PlaySoundPageState extends State<PlaySoundPage> {
  int _octave = 4;
  late NumberInputIntWithSlider _octaveInput;

  final ActiveReferenceSoundButton _buttonListener = ActiveReferenceSoundButton();
  bool _running = false;

  StreamSubscription<AudioInterruptionEvent>? audioInterruptionListener;

  @override
  void initState() {
    super.initState();

    _octaveInput = NumberInputIntWithSlider(
      max: 7,
      min: 1,
      defaultValue: _octave,
      step: 1,
      controller: TextEditingController(),
      textFieldWidth: TIOMusicParams.textFieldWidth1Digit,
      descriptionText: "Octave",
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await TunerFunctions.stop();

      _octaveInput.controller.addListener(_onOctaveChanged);

      _buttonListener.addListener(_onButtonsChanged);
    });
  }

  void _onOctaveChanged() {
    setState(() {
      _octave = int.parse(_octaveInput.controller.text);
    });
  }

  void _onButtonsChanged() async {
    if (_buttonListener.buttonOn) {
      // start generator if not running
      if (!_running) {
        await TunerFunctions.startGenerator();
        _running = true;

        audioInterruptionListener = (await AudioSession.instance).interruptionEventStream.listen((event) {
          if (event.type == AudioInterruptionType.unknown) {
            TunerFunctions.stopGenerator();
            setState(() {
              _running = false;
              _buttonListener.turnOff();
            });
          }
        });
      }

      // play sound
      if (_running) {
        generatorNoteOn(newFreq: _buttonListener.freq);
      }
    } else {
      // stop sound
      generatorNoteOff();
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    audioInterruptionListener?.cancel();
    TunerFunctions.stopGenerator();
  }

  @override
  Widget build(BuildContext context) {
    int offset = _octave * 12;
    return DismissKeyboard(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("Play Reference"),
          backgroundColor: ColorTheme.surfaceBright,
          foregroundColor: ColorTheme.primary,
        ),
        backgroundColor: ColorTheme.primary92,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _octaveInput,
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SoundButton(midiNumber: 25 + offset, idx: 0, buttonListener: _buttonListener),
                SoundButton(midiNumber: 27 + offset, idx: 1, buttonListener: _buttonListener),
                const SizedBox(width: buttonWidth + buttonPadding * 2),
                SoundButton(midiNumber: 30 + offset, idx: 2, buttonListener: _buttonListener),
                SoundButton(midiNumber: 32 + offset, idx: 3, buttonListener: _buttonListener),
                SoundButton(midiNumber: 34 + offset, idx: 4, buttonListener: _buttonListener),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SoundButton(midiNumber: 24 + offset, idx: 5, buttonListener: _buttonListener),
                SoundButton(midiNumber: 26 + offset, idx: 6, buttonListener: _buttonListener),
                SoundButton(midiNumber: 28 + offset, idx: 7, buttonListener: _buttonListener),
                SoundButton(midiNumber: 29 + offset, idx: 8, buttonListener: _buttonListener),
                SoundButton(midiNumber: 31 + offset, idx: 9, buttonListener: _buttonListener),
                SoundButton(midiNumber: 33 + offset, idx: 10, buttonListener: _buttonListener),
                SoundButton(midiNumber: 35 + offset, idx: 11, buttonListener: _buttonListener),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// class for the individual sound buttons
class SoundButton extends StatefulWidget {
  final int midiNumber;
  final int idx;
  final ActiveReferenceSoundButton buttonListener;

  const SoundButton({
    super.key,
    required this.midiNumber,
    required this.idx,
    required this.buttonListener,
  });

  @override
  State<SoundButton> createState() => _SoundButtonState();
}

class _SoundButtonState extends State<SoundButton> {
  late double _concertPitch;

  @override
  void initState() {
    super.initState();
    _concertPitch = (Provider.of<ProjectBlock>(context, listen: false) as TunerBlock).chamberNoteHz;
  }

  @override
  Widget build(BuildContext context) {
    // update the frequency on rebuild, in case the octave has changed
    if (widget.buttonListener.buttonOn) {
      generatorNoteOn(newFreq: midiToFreq(widget.midiNumber, concertPitch: _concertPitch));
    }

    return ListenableBuilder(
      listenable: widget.buttonListener,
      builder: (BuildContext context, Widget? child) {
        return Listener(
          onPointerDown: (details) async {
            setState(() {
              // if any button is on, turn it off
              if (widget.buttonListener.buttonOn) {
                widget.buttonListener.turnOff();

                // if clicked on the same button, do nothing
                // if clicked on a different button, turn it on
                if (widget.buttonListener.buttonIdx != widget.idx) {
                  widget.buttonListener.turnOn(widget.idx, midiToFreq(widget.midiNumber, concertPitch: _concertPitch));
                }
              } else {
                widget.buttonListener.turnOn(widget.idx, midiToFreq(widget.midiNumber, concertPitch: _concertPitch));
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(buttonPadding),
            child: Container(
              width: buttonWidth,
              height: 60,
              decoration: BoxDecoration(
                color: widget.buttonListener.buttonIdx == widget.idx && widget.buttonListener.buttonOn
                    ? ColorTheme.primary
                    : ColorTheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  midiToNameOneChar(widget.midiNumber.toInt()),
                  style: TextStyle(
                    color: widget.buttonListener.buttonIdx == widget.idx && widget.buttonListener.buttonOn
                        ? ColorTheme.surface
                        : ColorTheme.primary,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ActiveReferenceSoundButton with ChangeNotifier {
  int buttonIdx = 0;
  bool buttonOn = false;
  double freq = 0.0;

  void turnOff() {
    buttonOn = false;
    notifyListeners();
  }

  void turnOn(int idx, double frequency) {
    buttonOn = true;
    buttonIdx = idx;
    freq = frequency;
    notifyListeners();
  }
}
