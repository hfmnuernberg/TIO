import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/number_input_double_with_slider.dart';

class SetPitch extends StatefulWidget {
  const SetPitch({super.key});

  @override
  State<SetPitch> createState() => _SetPitchState();
}

class _SetPitchState extends State<SetPitch> {
  late MediaPlayerBlock _mediaPlayerBlock;
  final TextEditingController _pitchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _mediaPlayerBlock = Provider.of<ProjectBlock>(context, listen: false) as MediaPlayerBlock;

    _pitchController.text = _mediaPlayerBlock.pitchSemitones.toString();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pitchController.addListener(_onUserChangedPitch);
    });
  }

  @override
  void dispose() {
    _pitchController.removeListener(_onUserChangedPitch);
    _pitchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: context.l10n.mediaPlayerSetPitch,
      confirm: _onConfirm,
      reset: _reset,
      numberInput: NumberInputDoubleWithSlider(
        max: 24,
        min: -24,
        defaultValue: _mediaPlayerBlock.pitchSemitones,
        step: 0.1,
        stepIntervalInMs: 200,
        controller: _pitchController,
        label: context.l10n.mediaPlayerSemitonesLabel,
        textFieldWidth: TIOMusicParams.textFieldWidth4Digits,
        allowNegativeNumbers: true,
      ),
      cancel: _onCancel,
    );
  }

  void _onConfirm() async {
    if (_pitchController.text.isNotEmpty) {
      final newPitchValue = double.parse(_pitchController.text);
      _mediaPlayerBlock.pitchSemitones = newPitchValue;

      FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());

      final success = await mediaPlayerSetPitchSemitones(pitchSemitones: newPitchValue);
      if (!success) {
        throw 'Setting pitch semitones in rust failed using value: $newPitchValue';
      }
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _reset() {
    _pitchController.text = MediaPlayerParams.defaultPitchSemitones.toString();
  }

  void _onCancel() async {
    final success = await mediaPlayerSetPitchSemitones(pitchSemitones: _mediaPlayerBlock.pitchSemitones);
    if (!success) {
      throw 'Setting pitch semitones in rust failed using value: ${_mediaPlayerBlock.pitchSemitones}';
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _onUserChangedPitch() async {
    if (_pitchController.text.isNotEmpty) {
      final newPitchValue = double.parse(_pitchController.text);
      final success = await mediaPlayerSetPitchSemitones(pitchSemitones: newPitchValue);
      if (!success) {
        throw 'Setting pitch semitones in rust failed using value: $newPitchValue';
      }
    }
  }
}
