// Setting page for BPM value

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/rust_api/ffi.dart';
import 'package:tiomusic/widgets/number_input_int.dart';
import 'package:tiomusic/pages/metronome/tap_to_tempo.dart';
import 'package:tiomusic/util/constants.dart';

class SetBPM extends StatefulWidget {
  const SetBPM({super.key});

  @override
  State<SetBPM> createState() => _SetBPMState();
}

class _SetBPMState extends State<SetBPM> {
  late MetronomeBlock _metronomeBlock;
  late NumberInputInt _bpmInput;

  @override
  void initState() {
    super.initState();

    _metronomeBlock = Provider.of<ProjectBlock>(context, listen: false) as MetronomeBlock;

    _bpmInput = NumberInputInt(
      maxValue: MetronomeParams.maxBPM,
      minValue: MetronomeParams.minBPM,
      defaultValue: _metronomeBlock.bpm,
      countingValue: 1,
      displayText: TextEditingController(),
      descriptionText: 'BPM',
      buttonRadius: MetronomeParams.plusMinusButtonRadius,
      textFieldWidth: TIOMusicParams.textFieldWidth2Digits,
      textFontSize: MetronomeParams.numInputTextFontSize,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bpmInput.displayText.addListener(_onUserChangedBpm);
    });
  }

  void _onConfirm() async {
    if (_bpmInput.displayText.value.text != '') {
      int newBpm = int.parse(_bpmInput.displayText.value.text);
      if (newBpm >= MetronomeParams.minBPM && newBpm <= MetronomeParams.maxBPM) {
        rustApi.metronomeSetBpm(bpm: newBpm.toDouble());
      }
      _metronomeBlock.bpm = newBpm;
      FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    }

    Navigator.pop(context);
  }

  void _reset() {
    _bpmInput.displayText.value = _bpmInput.displayText.value.copyWith(text: MetronomeParams.defaultBPM.toString());
  }

  void _onCancel() {
    rustApi.metronomeSetBpm(bpm: _metronomeBlock.bpm.toDouble());
    Navigator.pop(context);
  }

  void _onUserChangedBpm() async {
    if (_bpmInput.displayText.value.text != '') {
      int newBpm = int.parse(_bpmInput.displayText.value.text);
      if (newBpm >= MetronomeParams.minBPM && newBpm <= MetronomeParams.maxBPM) {
        rustApi.metronomeSetBpm(bpm: newBpm.toDouble());
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
      customWidget: Tap2Tempo(bpmHandle: _bpmInput.displayText),
    );
  }
}
