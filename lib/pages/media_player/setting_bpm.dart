import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/widgets/input/number_input_and_slider_int.dart';
import 'package:tiomusic/widgets/input/tap_to_tempo.dart';

const defaultBpm = 80;
const minBpm = 10;
const maxBpm = 500;

class SetBPM extends StatefulWidget {
  const SetBPM({super.key});

  @override
  State<SetBPM> createState() => _SetBPMState();
}

class _SetBPMState extends State<SetBPM> {
  late int value;
  late MediaPlayerBlock _mediaPlayerBlock;

  @override
  void initState() {
    super.initState();
    _mediaPlayerBlock = Provider.of<ProjectBlock>(context, listen: false) as MediaPlayerBlock;
    value = _mediaPlayerBlock.bpm;
  }

  void _handleChange(int newBpm) => setState(() => value = newBpm);

  void _handleReset() => _handleChange(defaultBpm);

  void _handleConfirm() {
    _mediaPlayerBlock.bpm = value;
    FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: context.l10n.mediaPlayerSetBasicBeat,
      numberInput: NumberInputAndSliderInt(
        value: value,
        onChange: _handleChange,
        min: minBpm,
        max: maxBpm,
        step: 1,
        label: context.l10n.mediaPlayerBasicBeat,
        buttonRadius: 20,
        textFieldWidth: 100,
        textFontSize: 32,
      ),
      customWidget: Tap2Tempo(value: value, onChange: _handleChange),
      confirm: _handleConfirm,
      reset: _handleReset,
    );
  }
}
