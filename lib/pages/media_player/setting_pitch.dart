import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/number_input_double.dart';

class SetPitch extends StatefulWidget {
  const SetPitch({super.key});

  @override
  State<SetPitch> createState() => _SetPitchState();
}

class _SetPitchState extends State<SetPitch> {
  late MediaPlayerBlock _mediaPlayerBlock;
  late NumberInputDouble _pitchInput;

  @override
  void initState() {
    super.initState();

    _mediaPlayerBlock = Provider.of<ProjectBlock>(context, listen: false) as MediaPlayerBlock;

    _pitchInput = NumberInputDouble(
      max: 24.0,
      min: -24.0,
      defaultValue: _mediaPlayerBlock.pitchSemitones,
      step: 0.1,
      countingIntervalMs: 200,
      controller: TextEditingController(),
      descriptionText: "Semitones",
      textFieldWidth: TIOMusicParams.textFieldWidth4Digits,
      allowNegativeNumbers: true,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pitchInput.controller.addListener(_onUserChangedPitch);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: "Set Pitch",
      confirm: _onConfirm,
      reset: _reset,
      numberInput: _pitchInput,
      cancel: _onCancel,
    );
  }

  void _onConfirm() async {
    if (_pitchInput.controller.value.text != '') {
      double newPitchValue = double.parse(_pitchInput.controller.value.text);

      _mediaPlayerBlock.pitchSemitones = newPitchValue;

      FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());

      mediaPlayerSetPitchSemitones(pitchSemitones: newPitchValue).then((success) => {
            if (!success) {throw ("Setting pitch semitones in rust failed using this value: $newPitchValue")}
          });
    }

    Navigator.pop(context);
  }

  void _reset() {
    _pitchInput.controller.value =
        _pitchInput.controller.value.copyWith(text: MediaPlayerParams.defaultPitchSemitones.toString());
  }

  void _onCancel() {
    mediaPlayerSetPitchSemitones(pitchSemitones: _mediaPlayerBlock.pitchSemitones).then((success) => {
          if (!success)
            {throw ("Setting pitch semitones in rust failed using this value: ${_mediaPlayerBlock.pitchSemitones}")}
        });

    Navigator.pop(context);
  }

  void _onUserChangedPitch() async {
    if (_pitchInput.controller.value.text != '') {
      double newPitchValue = double.parse(_pitchInput.controller.value.text);

      mediaPlayerSetPitchSemitones(pitchSemitones: newPitchValue).then((success) => {
            if (!success) {throw ("Setting pitch semitones in rust failed using this value: $newPitchValue")}
          });
    }
  }
}
