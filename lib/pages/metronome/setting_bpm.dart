// Setting page for BPM value

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/number_input_int_with_slider.dart';
import 'package:tiomusic/widgets/tap_to_tempo.dart';

class SetBPM extends StatefulWidget {
  const SetBPM({super.key});

  @override
  State<SetBPM> createState() => _SetBPMState();
}

class _SetBPMState extends State<SetBPM> {
  late MetronomeBlock _metronomeBlock;
  late NumberInputIntWithSlider _bpmInput;

  @override
  void initState() {
    super.initState();

    _metronomeBlock = Provider.of<ProjectBlock>(context, listen: false) as MetronomeBlock;

    _bpmInput = NumberInputIntWithSlider(
      max: MetronomeParams.maxBPM,
      min: MetronomeParams.minBPM,
      defaultValue: _metronomeBlock.bpm,
      step: 1,
      controller: TextEditingController(),
      label: 'BPM',
      buttonRadius: MetronomeParams.plusMinusButtonRadius,
      textFieldWidth: TIOMusicParams.textFieldWidth2Digits,
      textFontSize: MetronomeParams.numInputTextFontSize,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bpmInput.controller.addListener(_onUserChangedBpm);
    });
  }

  void _onConfirm() async {
    if (_bpmInput.controller.value.text != '') {
      int newBpm = int.parse(_bpmInput.controller.value.text);
      if (newBpm >= MetronomeParams.minBPM && newBpm <= MetronomeParams.maxBPM) {
        metronomeSetBpm(bpm: newBpm.toDouble());
      }
      _metronomeBlock.bpm = newBpm;
      FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    }

    Navigator.pop(context);
  }

  void _reset() {
    _bpmInput.controller.value = _bpmInput.controller.value.copyWith(text: MetronomeParams.defaultBPM.toString());
  }

  void _onCancel() {
    metronomeSetBpm(bpm: _metronomeBlock.bpm.toDouble());
    Navigator.pop(context);
  }

  void _onUserChangedBpm() async {
    if (_bpmInput.controller.value.text != '') {
      int newBpm = int.parse(_bpmInput.controller.value.text);
      if (newBpm >= MetronomeParams.minBPM && newBpm <= MetronomeParams.maxBPM) {
        metronomeSetBpm(bpm: newBpm.toDouble());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: "Set BPM",
      confirm: _onConfirm,
      reset: _reset,
      cancel: _onCancel,
      numberInput: _bpmInput,
      customWidget: Tap2Tempo(bpmHandle: _bpmInput.controller),
    );
  }
}
