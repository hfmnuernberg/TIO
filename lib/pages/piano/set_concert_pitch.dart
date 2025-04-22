import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/piano_block.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/input/number_input_and_slider_dec.dart';

const maxConcertPitch = 600.0;
const minConcertPitch = 200.0;
const double defaultConcertPitch = 440;

class SetConcertPitch extends StatefulWidget {
  const SetConcertPitch({super.key});

  @override
  State<SetConcertPitch> createState() => _SetConcertPitchState();
}

class _SetConcertPitchState extends State<SetConcertPitch> {
  late double _concertPitch;
  late PianoBlock _pianoBlock;

  @override
  void initState() {
    super.initState();
    _pianoBlock = Provider.of<ProjectBlock>(context, listen: false) as PianoBlock;
    _concertPitch = _pianoBlock.concertPitch;
  }

  void _handleChange(double newPitch) =>
      setState(() => _concertPitch = newPitch.clamp(minConcertPitch, maxConcertPitch));

  void _handleReset() => _handleChange(defaultConcertPitch);

  void _handleConfirm() async {
    _pianoBlock.concertPitch = _concertPitch;
    FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: context.l10n.pianoSetConcertPitch,
      numberInput: NumberInputAndSliderDec(
        value: _concertPitch,
        max: maxConcertPitch,
        min: minConcertPitch,
        defaultValue: _pianoBlock.concertPitch,
        step: 1,
        stepIntervalInMs: 200,
        label: context.l10n.pianoConcertPitchInHz,
        textFieldWidth: TIOMusicParams.textFieldWidth4Digits,
        onChanged: _handleChange,
      ),
      confirm: _handleConfirm,
      reset: _handleReset,
    );
  }
}
