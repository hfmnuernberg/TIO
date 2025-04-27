import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/services/project_repository.dart';
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
  final TextEditingController _bpmController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _metronomeBlock = Provider.of<ProjectBlock>(context, listen: false) as MetronomeBlock;

    _bpmController.text = _metronomeBlock.bpm.toString();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bpmController.addListener(_onUserChangedBpm);
    });
  }

  @override
  void dispose() {
    _bpmController.removeListener(_onUserChangedBpm);
    _bpmController.dispose();
    super.dispose();
  }

  void _onConfirm() async {
    if (_bpmController.text != '') {
      int newBpm = int.parse(_bpmController.text);
      if (newBpm >= MetronomeParams.minBPM && newBpm <= MetronomeParams.maxBPM) {
        metronomeSetBpm(bpm: newBpm.toDouble());
      }
      _metronomeBlock.bpm = newBpm;
      context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
    }

    Navigator.pop(context);
  }

  void _reset() {
    _bpmController.text = MetronomeParams.defaultBPM.toString();
  }

  void _onCancel() {
    metronomeSetBpm(bpm: _metronomeBlock.bpm.toDouble());
    Navigator.pop(context);
  }

  void _onUserChangedBpm() async {
    if (_bpmController.text != '') {
      int newBpm = int.parse(_bpmController.text);
      if (newBpm >= MetronomeParams.minBPM && newBpm <= MetronomeParams.maxBPM) {
        metronomeSetBpm(bpm: newBpm.toDouble());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: context.l10n.metronomeSetBpm,
      confirm: _onConfirm,
      reset: _reset,
      cancel: _onCancel,
      numberInput: NumberInputIntWithSlider(
        max: MetronomeParams.maxBPM,
        min: MetronomeParams.minBPM,
        defaultValue: _metronomeBlock.bpm,
        step: 1,
        controller: _bpmController,
        label: context.l10n.commonBpm,
        buttonRadius: MetronomeParams.plusMinusButtonRadius,
        textFieldWidth: TIOMusicParams.textFieldWidth2Digits,
        textFontSize: MetronomeParams.numInputTextFontSize,
      ),
      customWidget: Tap2Tempo(bpmHandle: _bpmController),
    );
  }
}
