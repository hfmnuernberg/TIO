import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/tuner_block.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/old_number_input_double_with_slider.dart';

class SetConcertPitch extends StatefulWidget {
  const SetConcertPitch({super.key});

  @override
  State<SetConcertPitch> createState() => _SetConcertPitchState();
}

class _SetConcertPitchState extends State<SetConcertPitch> {
  final TextEditingController _controller = TextEditingController();
  late TunerBlock _tunerBlock;

  double _defaultValue = 0;

  @override
  void initState() {
    super.initState();

    _tunerBlock = Provider.of<ProjectBlock>(context, listen: false) as TunerBlock;
    _defaultValue = _tunerBlock.chamberNoteHz;

    _controller.text = _defaultValue.toString();
  }

  void _onConfirm() async {
    final text = _controller.text;

    if (text.isNotEmpty) {
      final newConcertPitch = double.tryParse(text);
      if (newConcertPitch != null) {
        _tunerBlock.chamberNoteHz = newConcertPitch;
        FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
      }
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _reset() {
    _controller.text = TunerParams.defaultConcertPitch.toString();
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: context.l10n.tunerSetConcertPitch,
      numberInput: OldNumberInputDoubleWithSlider(
        max: 600,
        min: 200,
        defaultValue: _defaultValue,
        step: 1,
        stepIntervalInMs: 200,
        controller: _controller,
        label: context.l10n.tunerConcertPitchInHz,
        textFieldWidth: TIOMusicParams.textFieldWidth4Digits,
      ),
      confirm: _onConfirm,
      reset: _reset,
    );
  }
}
