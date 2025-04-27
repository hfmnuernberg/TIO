import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/tuner_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/input/number_input_and_slider_dec.dart';

const maxConcertPitch = 600.0;
const minConcertPitch = 200.0;

class SetConcertPitch extends StatefulWidget {
  const SetConcertPitch({super.key});

  @override
  State<SetConcertPitch> createState() => _SetConcertPitchState();
}

class _SetConcertPitchState extends State<SetConcertPitch> {
  late double _concertPitch;
  late TunerBlock _tunerBlock;

  @override
  void initState() {
    super.initState();
    _tunerBlock = Provider.of<ProjectBlock>(context, listen: false) as TunerBlock;
    _concertPitch = _tunerBlock.chamberNoteHz;
  }

  void _handleChange(double newPitch) =>
      setState(() => _concertPitch = newPitch.clamp(minConcertPitch, maxConcertPitch));

  void _handleReset() => _handleChange(TunerParams.defaultConcertPitch);

  void _handleConfirm() {
    _tunerBlock.chamberNoteHz = _concertPitch;
    context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: context.l10n.tunerSetConcertPitch,
      numberInput: NumberInputAndSliderDec(
        value: _concertPitch,
        min: minConcertPitch,
        max: maxConcertPitch,
        step: 1,
        stepIntervalInMs: 200,
        label: context.l10n.tunerConcertPitchInHz,
        textFieldWidth: TIOMusicParams.textFieldWidth4Digits,
        onChange: _handleChange,
      ),
      confirm: _handleConfirm,
      reset: _handleReset,
    );
  }
}
