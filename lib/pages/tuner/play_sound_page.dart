import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/tuner_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/tuner_type.dart';
import 'package:tiomusic/pages/tuner/tuner_functions.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/util_midi.dart';
import 'package:tiomusic/widgets/dismiss_keyboard.dart';
import 'package:tiomusic/widgets/tuner/chromatic_play_reference.dart';
import 'package:tiomusic/widgets/tuner/instrument_play_reference.dart';

class PlaySoundPage extends StatefulWidget {
  const PlaySoundPage({super.key});

  @override
  State<PlaySoundPage> createState() => _PlaySoundPageState();
}

class _PlaySoundPageState extends State<PlaySoundPage> {
  int? midi;

  late AudioSystem _as;

  StreamSubscription<AudioInterruptionEvent>? audioInterruptionListener;

  @override
  void initState() {
    super.initState();

    _as = context.read<AudioSystem>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await TunerFunctions.stop(_as);
      await TunerFunctions.startGenerator(_as);

      await setupAudioInterruptionListener();
    });
  }

  @override
  void dispose() {
    audioInterruptionListener?.cancel();
    TunerFunctions.stopGenerator(_as);
    super.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
    audioInterruptionListener?.cancel();
    TunerFunctions.stopGenerator(_as);
  }

  Future<void> setupAudioInterruptionListener() async {
    audioInterruptionListener?.cancel();
    audioInterruptionListener = (await AudioSession.instance).interruptionEventStream.listen((event) {
      if (event.type == AudioInterruptionType.unknown) {
        TunerFunctions.stopGenerator(_as);
        setState(() => midi = null);
      }
    });
  }

  void handleToggle(int midiNumber) async {
    final tunerBlock = context.read<ProjectBlock>() as TunerBlock;
    final isSameButton = midi == midiNumber;
    final isOn = midi != null;

    if (isOn && isSameButton) {
      await _as.generatorNoteOff();
      setState(() => midi = null);
      return;
    }

    await _as.generatorNoteOn(newFreq: midiToFreq(midiNumber, concertPitch: tunerBlock.chamberNoteHz));
    setState(() => midi = midiNumber);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tunerBlock = context.read<ProjectBlock>() as TunerBlock;
    final frequency = midi != null ? midiToFreq(midi!, concertPitch: tunerBlock.chamberNoteHz) : 0.0;

    return DismissKeyboard(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(l10n.tunerPlayReference),
          backgroundColor: ColorTheme.surfaceBright,
          foregroundColor: ColorTheme.primary,
        ),
        backgroundColor: ColorTheme.primary92,
        body:
            tunerBlock.tunerType == TunerType.chromatic
                ? ChromaticPlayReference(midi: midi, frequency: frequency, onToggle: handleToggle)
                : InstrumentPlayReference(
                  tunerType: tunerBlock.tunerType,
                  midi: midi,
                  frequency: frequency,
                  onToggle: handleToggle,
                ),
      ),
    );
  }
}
