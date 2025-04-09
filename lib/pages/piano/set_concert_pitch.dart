import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
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
  late PianoBlock _pianoBlock;
  final TextEditingController _pitchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _pianoBlock = Provider.of<ProjectBlock>(context, listen: false) as PianoBlock;

    _pitchController.text = _pianoBlock.concertPitch.toString();
  }

  @override
  void dispose() {
    _pitchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: context.l10n.pianoSetConcertPitch,
      numberInput: NumberInputDoubleWithSlider(
        max: 600,
        min: 200,
        defaultValue: _pianoBlock.concertPitch,
        step: 1,
        stepIntervalInMs: 200,
        controller: _pitchController,
        label: context.l10n.pianoConcertPitchInHz,
        textFieldWidth: TIOMusicParams.textFieldWidth4Digits,
      ),
      confirm: _onConfirm,
      reset: _reset,
    );
  }

  void _onConfirm() async {
    if (_pitchController.text != '') {
      double newConcertPitch = double.parse(_pitchController.text);
      _pianoBlock.concertPitch = newConcertPitch;

      FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    }

    Navigator.pop(context);
  }

  void _reset() {
    _pitchController.value = _pitchController.value.copyWith(text: defaultConcertPitch.toString());
  }
}
