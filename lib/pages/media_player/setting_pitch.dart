import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/src/rust/api/ffi.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/input/number_input_and_slider_dec.dart';

const minPitch = -24.0;
const maxPitch = 24.0;

class SetPitch extends StatefulWidget {
  const SetPitch({super.key});

  @override
  State<SetPitch> createState() => _SetPitchState();
}

class _SetPitchState extends State<SetPitch> {
  late double pitch;
  late MediaPlayerBlock _mediaPlayerBlock;

  @override
  void initState() {
    super.initState();
    _mediaPlayerBlock = Provider.of<ProjectBlock>(context, listen: false) as MediaPlayerBlock;
    pitch = _mediaPlayerBlock.pitchSemitones;
  }

  Future<void> _updatePitch(double newPitch) async {
    final success = await mediaPlayerSetPitchSemitones(pitchSemitones: newPitch);
    if (!success) {
      throw 'Setting pitch semitones in rust failed using value: $newPitch';
    }
  }

  Future<void> _handleChange(double newPitch) async {
    setState(() => pitch = newPitch.clamp(minPitch, maxPitch));
    await _updatePitch(pitch);
  }

  Future<void> _handleReset() async => _handleChange(MediaPlayerParams.defaultPitchSemitones);

  Future<void> _handleConfirm() async {
    _mediaPlayerBlock.pitchSemitones = pitch;
    await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _handleCancel() async {
    await _handleChange(_mediaPlayerBlock.pitchSemitones);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: context.l10n.mediaPlayerSetPitch,
      numberInput: NumberInputAndSliderDec(
        value: pitch,
        min: minPitch,
        max: maxPitch,
        step: 0.1,
        stepIntervalInMs: 200,
        label: context.l10n.mediaPlayerSemitonesLabel,
        textFieldWidth: TIOMusicParams.textFieldWidth4Digits,
        onChange: _handleChange,
      ),
      confirm: _handleConfirm,
      reset: _handleReset,
      cancel: _handleCancel,
    );
  }
}
