import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/blocks/piano_block.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/number_input_double_with_slider.dart';

const double defaultConcertPitch = 440;

class SetConcertPitch extends StatefulWidget {
  const SetConcertPitch({super.key});

  @override
  State<SetConcertPitch> createState() => _SetConcertPitchState();
}

class _SetConcertPitchState extends State<SetConcertPitch> {
  late NumberInputDoubleWithSlider _concertPitchInput;
  late PianoBlock _pianoBlock;

  @override
  void initState() {
    super.initState();

    _pianoBlock = Provider.of<ProjectBlock>(context, listen: false) as PianoBlock;

    _concertPitchInput = NumberInputDoubleWithSlider(
      max: 600,
      min: 200,
      defaultValue: _pianoBlock.concertPitch,
      step: 1,
      stepIntervalInMs: 200,
      controller: TextEditingController(),
      label: 'Concert Pitch in Hz',
      textFieldWidth: TIOMusicParams.textFieldWidth4Digits,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: 'Set Concert Pitch',
      numberInput: _concertPitchInput,
      confirm: _onConfirm,
      reset: _reset,
    );
  }

  void _onConfirm() async {
    if (_concertPitchInput.controller.value.text != '') {
      double newConcertPitch = double.parse(_concertPitchInput.controller.value.text);
      _pianoBlock.concertPitch = newConcertPitch;

      FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    }

    Navigator.pop(context);
  }

  void _reset() {
    _concertPitchInput.controller.value = _concertPitchInput.controller.value.copyWith(
      text: defaultConcertPitch.toString(),
    );
  }
}
