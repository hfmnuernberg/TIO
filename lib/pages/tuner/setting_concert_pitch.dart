import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/blocks/tuner_block.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/number_input_double.dart';

class SetConcertPitch extends StatefulWidget {
  const SetConcertPitch({super.key});

  @override
  State<SetConcertPitch> createState() => _SetConcertPitchState();
}

class _SetConcertPitchState extends State<SetConcertPitch> {
  late NumberInputDouble _concertPitchInput;
  late TunerBlock _tunerBlock;

  @override
  void initState() {
    super.initState();

    _tunerBlock = Provider.of<ProjectBlock>(context, listen: false) as TunerBlock;

    _concertPitchInput = NumberInputDouble(
      max: 600.0,
      min: 200.0,
      defaultValue: _tunerBlock.chamberNoteHz,
      step: 1.0,
      countingIntervalMs: 200,
      controller: TextEditingController(),
      descriptionText: "Concert Pitch in Hz",
      textFieldWidth: TIOMusicParams.textFieldWidth4Digits,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: "Set Concert Pitch",
      numberInput: _concertPitchInput,
      confirm: _onConfirm,
      reset: _reset,
    );
  }

  void _onConfirm() async {
    if (_concertPitchInput.controller.value.text != '') {
      double newConcertPitch = double.parse(_concertPitchInput.controller.value.text);
      _tunerBlock.chamberNoteHz = newConcertPitch;

      FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    }

    Navigator.pop(context);
  }

  void _reset() {
    _concertPitchInput.controller.value =
        _concertPitchInput.controller.value.copyWith(text: TunerParams.defaultConcertPitch.toString());
  }
}
