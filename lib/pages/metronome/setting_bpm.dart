import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/constants/constants.dart';
import 'package:tiomusic/domain/metronome/metronome.dart';
import 'package:tiomusic/util/constants/metronome_constants.dart';
import 'package:tiomusic/widgets/input/number_input_and_slider_int.dart';
import 'package:tiomusic/widgets/input/tap_to_tempo.dart';

class SetBPM extends StatefulWidget {
  const SetBPM({super.key});

  @override
  State<SetBPM> createState() => _SetBPMState();
}

class _SetBPMState extends State<SetBPM> {
  late final Metronome metronome;

  late int bpm;

  late MetronomeBlock metronomeBlock;

  @override
  void initState() {
    super.initState();
    metronome = context.read<Metronome>();
    metronomeBlock = Provider.of<ProjectBlock>(context, listen: false) as MetronomeBlock;
    bpm = metronomeBlock.bpm;
  }

  Future<void> handleChange(int newBpm) async {
    setState(() => bpm = newBpm.clamp(MetronomeParams.minBPM, MetronomeParams.maxBPM));
    await metronome.setBpm(bpm);
  }

  Future<void> handleReset() async => handleChange(MetronomeParams.defaultBPM);

  Future<void> handleConfirm() async {
    metronomeBlock.bpm = bpm;
    await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> handleCancel() async {
    await handleChange(metronomeBlock.bpm);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: context.l10n.commonBasicBeatSetting,
      numberInput: NumberInputAndSliderInt(
        value: bpm,
        max: MetronomeParams.maxBPM,
        min: MetronomeParams.minBPM,
        step: 1,
        label: context.l10n.commonBpm,
        buttonRadius: MetronomeParams.plusMinusButtonRadius,
        textFieldWidth: TIOMusicParams.textFieldWidth2Digits,
        textFontSize: MetronomeParams.numInputTextFontSize,
        onChange: handleChange,
      ),
      customWidget: Tap2Tempo(value: bpm, onChange: handleChange),
      confirm: handleConfirm,
      reset: handleReset,
      cancel: handleCancel,
    );
  }
}
