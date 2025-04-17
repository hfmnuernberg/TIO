import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/input/number_input_and_slider_int.dart';

class SetRandomMute extends StatefulWidget {
  const SetRandomMute({super.key});

  @override
  State<SetRandomMute> createState() => _SetRandomMuteState();
}

class _SetRandomMuteState extends State<SetRandomMute> {
  late int value;
  late MetronomeBlock _metronomeBlock;

  @override
  void initState() {
    super.initState();
    _metronomeBlock = Provider.of<ProjectBlock>(context, listen: false) as MetronomeBlock;
    value = _metronomeBlock.randomMute;
  }

  void _handleChange(newValue) async {
    setState(() => value = newValue);
    metronomeSetBeatMuteChance(muteChance: newValue / 100.0).then((success) => null);
  }

  void _handleReset() => value = MetronomeParams.defaultRandomMute;

  void _handleConfirm() async {
    _metronomeBlock.randomMute = value;
    metronomeSetBeatMuteChance(muteChance: value / 100.0).then((success) => null);
    FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    Navigator.pop(context);
  }

  void _handleCancel() {
    metronomeSetBeatMuteChance(muteChance: _metronomeBlock.randomMute / 100.0).then((success) => null);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: context.l10n.metronomeSetRandomMute,
      numberInput: NumberInputAndSliderInt(
        value: value,
        onChanged: _handleChange,
        max: 100,
        min: 0,
        defaultValue: _metronomeBlock.randomMute,
        step: 1,
        label: context.l10n.metronomeRandomMuteProbability,
        buttonRadius: MetronomeParams.plusMinusButtonRadius,
        textFieldWidth: TIOMusicParams.textFieldWidth2Digits,
        textFontSize: MetronomeParams.numInputTextFontSize,
      ),
      confirm: _handleConfirm,
      reset: _handleReset,
      cancel: _handleCancel,
    );
  }
}
