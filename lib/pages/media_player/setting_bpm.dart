// Setting page for BPM value

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/widgets/number_input_int_with_slider.dart';
import 'package:tiomusic/pages/metronome/tap_to_tempo.dart';

final defaultBPM = 80;
final minBPM = 10;
final maxBPM = 500;

class SetBPM extends StatefulWidget {
  const SetBPM({super.key});

  @override
  State<SetBPM> createState() => _SetBPMState();
}

class _SetBPMState extends State<SetBPM> {
  late MediaPlayerBlock _mediaPlayerBlock;
  late NumberInputInt _bpmInput;

  @override
  void initState() {
    super.initState();

    _mediaPlayerBlock = Provider.of<ProjectBlock>(context, listen: false) as MediaPlayerBlock;

    _bpmInput = NumberInputInt(
      max: maxBPM,
      min: minBPM,
      defaultValue: _mediaPlayerBlock.bpm,
      step: 1,
      controller: TextEditingController(),
      descriptionText: 'Basic Beat',
      buttonRadius: 20,
      textFieldWidth: 100,
      textFontSize: 32,
    );
  }

  void _onConfirm() async {
    if (_bpmInput.controller.value.text != '') {
      int newBpm = int.parse(_bpmInput.controller.value.text);
      _mediaPlayerBlock.bpm = newBpm;
      FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    }

    Navigator.pop(context);
  }

  void _reset() {
    _bpmInput.controller.value = _bpmInput.controller.value.copyWith(text: defaultBPM.toString());
  }

  void _onCancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: "Set Basic Beat",
      confirm: _onConfirm,
      reset: _reset,
      cancel: _onCancel,
      numberInput: _bpmInput,
      customWidget: Tap2Tempo(bpmHandle: _bpmInput.controller),
    );
  }
}
