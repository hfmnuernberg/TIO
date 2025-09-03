import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/domain/metronome/metronome.dart';
import 'package:tiomusic/widgets/input/number_input_and_slider_int.dart';

class SetRandomMute extends StatefulWidget {
  const SetRandomMute({super.key});

  @override
  State<SetRandomMute> createState() => _SetRandomMuteState();
}

class _SetRandomMuteState extends State<SetRandomMute> {
  late final Metronome metronome;

  late int value;

  late MetronomeBlock metronomeBlock;

  @override
  void initState() {
    super.initState();
    metronome = context.read<Metronome>();
    metronomeBlock = Provider.of<ProjectBlock>(context, listen: false) as MetronomeBlock;
    value = metronomeBlock.randomMute;
  }

  void handleChange(newValue) async {
    setState(() => value = newValue);
    metronome.setChanceOfMuteBeat(newValue).then((success) => null);
  }

  void handleReset() => value = MetronomeParams.defaultRandomMute;

  void handleConfirm() async {
    metronomeBlock.randomMute = value;
    metronome.setChanceOfMuteBeat(value).then((success) => null);
    await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _handleCancel() {
    metronome.setChanceOfMuteBeat(metronomeBlock.randomMute).then((success) => null);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: context.l10n.metronomeSetRandomMute,
      numberInput: NumberInputAndSliderInt(
        value: value,
        onChange: handleChange,
        max: 100,
        min: 0,
        step: 1,
        label: context.l10n.metronomeRandomMuteProbability,
        buttonRadius: MetronomeParams.plusMinusButtonRadius,
        textFieldWidth: TIOMusicParams.textFieldWidth2Digits,
        textFontSize: MetronomeParams.numInputTextFontSize,
      ),
      confirm: handleConfirm,
      reset: handleReset,
      cancel: _handleCancel,
    );
  }
}
