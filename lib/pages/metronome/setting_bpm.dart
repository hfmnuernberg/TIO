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
import 'package:tiomusic/widgets/tap_to_tempo.dart';

class SetBPM extends StatefulWidget {
  const SetBPM({super.key});

  @override
  State<SetBPM> createState() => _SetBPMState();
}

class _SetBPMState extends State<SetBPM> {
  late int value;
  late MetronomeBlock _metronomeBlock;

  @override
  void initState() {
    super.initState();
    _metronomeBlock = Provider.of<ProjectBlock>(context, listen: false) as MetronomeBlock;
    value = _metronomeBlock.bpm;
  }

  void _handleChange(int newBpm) {
    setState(() => value = newBpm);
    if (newBpm >= MetronomeParams.minBPM && newBpm <= MetronomeParams.maxBPM) {
      metronomeSetBpm(bpm: newBpm.toDouble());
    }
  }

  void _handleReset() => _handleChange(MetronomeParams.defaultBPM);

  void _handleConfirm() async {
    _metronomeBlock.bpm = value;
    FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    Navigator.pop(context);
  }

  void _handleCancel() {
    metronomeSetBpm(bpm: _metronomeBlock.bpm.toDouble());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: context.l10n.metronomeSetBpm,
      confirm: _handleConfirm,
      reset: _handleReset,
      cancel: _handleCancel,
      numberInput: NumberInputAndSliderInt(
        value: value,
        onChanged: _handleChange,
        max: MetronomeParams.maxBPM,
        min: MetronomeParams.minBPM,
        defaultValue: _metronomeBlock.bpm,
        step: 1,
        label: context.l10n.commonBpm,
        buttonRadius: MetronomeParams.plusMinusButtonRadius,
        textFieldWidth: TIOMusicParams.textFieldWidth2Digits,
        textFontSize: MetronomeParams.numInputTextFontSize,
      ),
      customWidget: Tap2Tempo(value: value, onChanged: _handleChange),
    );
  }
}
