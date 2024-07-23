// Setting page for random mute

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/rust_api/ffi.dart';
import 'package:tiomusic/widgets/number_input_int.dart';
import 'package:tiomusic/util/constants.dart';

import '../../models/file_io.dart';

class SetRandomMute extends StatefulWidget {
  const SetRandomMute({super.key});

  @override
  State<SetRandomMute> createState() => _SetRandomMuteState();
}

class _SetRandomMuteState extends State<SetRandomMute> {
  late MetronomeBlock _metronomeBlock;
  late NumberInputInt _randomMuteProbInput;

  @override
  void initState() {
    super.initState();

    _metronomeBlock = Provider.of<ProjectBlock>(context, listen: false) as MetronomeBlock;

    _randomMuteProbInput = NumberInputInt(
      maxValue: 100,
      minValue: 0,
      defaultValue: _metronomeBlock.randomMute,
      countingValue: 1,
      displayText: TextEditingController(),
      descriptionText: 'Probability in %',
      buttonRadius: MetronomeParams.plusMinusButtonRadius,
      textFieldWidth: TIOMusicParams.textFieldWidth2Digits,
      textFontSize: MetronomeParams.numInputTextFontSize,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _randomMuteProbInput.displayText.addListener(_onUserChangedRandomMute);
    });
  }

  void _onConfirm() async {
    if (_randomMuteProbInput.displayText.value.text != '') {
      int newRandomMute = int.parse(_randomMuteProbInput.displayText.value.text);
      _metronomeBlock.randomMute = newRandomMute;
      rustApi.metronomeSetBeatMuteChance(muteChance: newRandomMute / 100.0).then((success) => null);
      FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    }

    Navigator.pop(context);
  }

  void _reset() {
    _randomMuteProbInput.displayText.value =
        _randomMuteProbInput.displayText.value.copyWith(text: MetronomeParams.defaultRandomMute.toString());
  }

  void _onCancel() {
    rustApi.metronomeSetBeatMuteChance(muteChance: _metronomeBlock.randomMute / 100.0).then((success) => null);
    Navigator.pop(context);
  }

  void _onUserChangedRandomMute() async {
    if (_randomMuteProbInput.displayText.value.text != '') {
      double newValue = double.parse(_randomMuteProbInput.displayText.value.text);
      rustApi.metronomeSetBeatMuteChance(muteChance: newValue / 100.0).then((success) => null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: "Set Random Mute",
      confirm: _onConfirm,
      reset: _reset,
      numberInput: _randomMuteProbInput,
      cancel: _onCancel,
    );
  }
}
