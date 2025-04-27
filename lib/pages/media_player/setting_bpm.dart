import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/widgets/number_input_int_with_slider.dart';
import 'package:tiomusic/widgets/tap_to_tempo.dart';

const defaultBpm = 80;
const minBpm = 10;
const maxBpm = 500;

class SetBPM extends StatefulWidget {
  const SetBPM({super.key});

  @override
  State<SetBPM> createState() => _SetBPMState();
}

class _SetBPMState extends State<SetBPM> {
  late MediaPlayerBlock _mediaPlayerBlock;
  final TextEditingController _bpmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mediaPlayerBlock = Provider.of<ProjectBlock>(context, listen: false) as MediaPlayerBlock;
    _bpmController.text = _mediaPlayerBlock.bpm.toString();
  }

  @override
  void dispose() {
    _bpmController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    if (_bpmController.text.isNotEmpty) {
      final newBpm = int.tryParse(_bpmController.text) ?? defaultBpm;
      _mediaPlayerBlock.bpm = newBpm;
      context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
    }

    Navigator.pop(context);
  }

  void _reset() {
    _bpmController.text = defaultBpm.toString();
  }

  void _onCancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: context.l10n.mediaPlayerSetBasicBeat,
      confirm: _onConfirm,
      reset: _reset,
      cancel: _onCancel,
      numberInput: NumberInputIntWithSlider(
        max: maxBpm,
        min: minBpm,
        defaultValue: _mediaPlayerBlock.bpm,
        step: 1,
        controller: _bpmController,
        label: context.l10n.mediaPlayerBasicBeat,
        buttonRadius: 20,
        textFieldWidth: 100,
        textFontSize: 32,
      ),
      customWidget: Tap2Tempo(bpmHandle: _bpmController),
    );
  }
}
