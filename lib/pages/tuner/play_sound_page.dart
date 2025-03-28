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
  final TextEditingController _octaveController = TextEditingController(text: '4');
  int _octave = 4;
  double _frequency = 0;

  final ActiveReferenceSoundButton _buttonListener = ActiveReferenceSoundButton();
  bool _running = false;

  StreamSubscription<AudioInterruptionEvent>? audioInterruptionListener;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await TunerFunctions.stop();

      _octaveController.addListener(_onOctaveChanged);

      _buttonListener.addListener(_onButtonsChanged);
    });
  }

  List<Widget> _buildSoundButtons(List<int> midiNumbers, int startIdx, int offset) {
    return List.generate(midiNumbers.length, (index) {
      return SoundButton(
        midiNumber: midiNumbers[index] + offset,
        idx: startIdx + index,
        buttonListener: _buttonListener,
      );
    });
  }

  void _onOctaveChanged() {
    final newOctave = int.tryParse(_octaveController.text) ?? 4;
    double newFreq = _frequency;

    if (newOctave > _octave) {
      newFreq = _frequency * 2;
    } else if (newOctave < _octave) {
      newFreq = _frequency / 2;
    }

    setState(() {
      _octave = newOctave;
      _frequency = newFreq;
    });
  }

  void _onButtonsChanged() async {
    if (_buttonListener.buttonOn) {
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

      if (_running) {
        generatorNoteOn(newFreq: _buttonListener.freq);

        setState(() {
          _frequency = _buttonListener.freq;
        });
      }
    } else {
      generatorNoteOff();

      setState(() {
        _frequency = 0;
      });
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    audioInterruptionListener?.cancel();
    TunerFunctions.stopGenerator();
  }

  @override
  void dispose() {
    _octaveController.dispose();
    _buttonListener.removeListener(_onButtonsChanged);
    audioInterruptionListener?.cancel();
    TunerFunctions.stopGenerator();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int offset = (_octave - 1) * 12;

    final octaveInput = NumberInputIntWithSlider(
      max: 7,
      min: 1,
      defaultValue: _octave,
      step: 1,
      controller: _octaveController,
      textFieldWidth: TIOMusicParams.textFieldWidth1Digit,
      label: context.l10n.commonOctave,
    );
    return DismissKeyboard(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(context.l10n.tunerPlayReference),
          backgroundColor: ColorTheme.surfaceBright,
          foregroundColor: ColorTheme.primary,
        ),
        backgroundColor: ColorTheme.primary92,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            octaveInput,
            const SizedBox(height: 40),

            Text(
              '${context.l10n.tunerFrequency}: ${_frequency.floorToDouble()} Hz',
              style: const TextStyle(color: ColorTheme.primary),
            ),
            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ..._buildSoundButtons([25, 27], 0, offset),
                SizedBox(width: buttonWidth + buttonPadding * 2),
                ..._buildSoundButtons([30, 32, 34], 2, offset),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildSoundButtons([24, 26, 28, 29, 31, 33, 35], 5, offset),
            ),
          ],
        ),
      ),
    );
  }
}

class SoundButton extends StatefulWidget {
  final int midiNumber;
  final int idx;
  final ActiveReferenceSoundButton buttonListener;

  const SoundButton({super.key, required this.midiNumber, required this.idx, required this.buttonListener});

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
    return ListenableBuilder(
      listenable: widget.buttonListener,
      builder: (context, child) {
        return Listener(
          onPointerDown: (details) async {
            setState(() {
              if (widget.buttonListener.buttonOn) {
                widget.buttonListener.turnOff();

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
                color:
                    widget.buttonListener.buttonIdx == widget.idx && widget.buttonListener.buttonOn
                        ? ColorTheme.primary
                        : ColorTheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  midiToNameOneChar(widget.midiNumber),
                  style: TextStyle(
                    color:
                        widget.buttonListener.buttonIdx == widget.idx && widget.buttonListener.buttonOn
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
  double freq = 0;

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
