import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/src/rust/api/api.dart';

import 'package:tiomusic/widgets/number_input_int_with_slider.dart';
import 'package:tiomusic/util/constants.dart';

import 'package:tiomusic/models/file_io.dart';

class SetRandomMute extends StatefulWidget {
  const SetRandomMute({super.key});

  @override
  State<SetRandomMute> createState() => _SetRandomMuteState();
}

class _SetRandomMuteState extends State<SetRandomMute> {
  late MetronomeBlock _metronomeBlock;
  final TextEditingController _randomMuteController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _metronomeBlock = Provider.of<ProjectBlock>(context, listen: false) as MetronomeBlock;

    _randomMuteController.text = MetronomeParams.defaultRandomMute.toString();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _randomMuteController.addListener(_onUserChangedRandomMute);
    });
  }

  void _onConfirm() async {
    if (_randomMuteController.text != '') {
      int newRandomMute = int.parse(_randomMuteController.text);
      _metronomeBlock.randomMute = newRandomMute;
      metronomeSetBeatMuteChance(muteChance: newRandomMute / 100.0).then((success) => null);
      FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    }

    Navigator.pop(context);
  }

  void _reset() {
    _randomMuteController.text = MetronomeParams.defaultRandomMute.toString();
  }

  void _onCancel() {
    metronomeSetBeatMuteChance(muteChance: _metronomeBlock.randomMute / 100.0).then((success) => null);
    Navigator.pop(context);
  }

  void _onUserChangedRandomMute() async {
    if (_randomMuteController.text != '') {
      double newValue = double.parse(_randomMuteController.text);
      metronomeSetBeatMuteChance(muteChance: newValue / 100.0).then((success) => null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: context.l10n.metronomeSetRandomMute,
      confirm: _onConfirm,
      reset: _reset,
      numberInput: NumberInputIntWithSlider(
        max: 100,
        min: 0,
        defaultValue: _metronomeBlock.randomMute,
        step: 1,
        controller: _randomMuteController,
        label: context.l10n.metronomeRandomMuteProbability,
        buttonRadius: MetronomeParams.plusMinusButtonRadius,
        textFieldWidth: TIOMusicParams.textFieldWidth2Digits,
        textFontSize: MetronomeParams.numInputTextFontSize,
      ),
      cancel: _onCancel,
    );
  }
}
