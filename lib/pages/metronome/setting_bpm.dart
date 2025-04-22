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
import 'package:tiomusic/widgets/input/tap_to_tempo.dart';

class SetBPM extends StatefulWidget {
  const SetBPM({super.key});

  @override
  State<SetBPM> createState() => _SetBPMState();
}

class _SetBPMState extends State<SetBPM> {
  late int bpm;
  late MetronomeBlock _metronomeBlock;

  @override
  void initState() {
    super.initState();
    _metronomeBlock = Provider.of<ProjectBlock>(context, listen: false) as MetronomeBlock;
    bpm = _metronomeBlock.bpm;
  }

  Future<void> _updateBpm(newPitch) async {
    final success = await metronomeSetBpm(bpm: bpm.toDouble());
    if (!success) {
      throw 'Setting bpm in rust failed using value: $bpm';
    }
  }

  Future<void> _handleChange(int newBpm) async {
    setState(() => bpm = newBpm.clamp(MetronomeParams.minBPM, MetronomeParams.maxBPM));
    await _updateBpm(bpm);
  }

  Future<void> _handleReset() async => _handleChange(MetronomeParams.defaultBPM);

  void _handleConfirm() {
    _metronomeBlock.bpm = bpm;
    FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    Navigator.pop(context);
  }

  Future<void> _handleCancel() async {
    await _handleChange(_metronomeBlock.bpm);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: context.l10n.metronomeSetBpm,
      numberInput: NumberInputAndSliderInt(
        value: bpm,
        max: MetronomeParams.maxBPM,
        min: MetronomeParams.minBPM,
        defaultValue: _metronomeBlock.bpm,
        step: 1,
        label: context.l10n.commonBpm,
        buttonRadius: MetronomeParams.plusMinusButtonRadius,
        textFieldWidth: TIOMusicParams.textFieldWidth2Digits,
        textFontSize: MetronomeParams.numInputTextFontSize,
        onChanged: _handleChange,
      ),
      customWidget: Tap2Tempo(value: bpm, onChanged: _handleChange),
      confirm: _handleConfirm,
      reset: _handleReset,
      cancel: _handleCancel,
    );
  }
}
