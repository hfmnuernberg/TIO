import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/rust_api/ffi.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/number_input_double.dart';

class SetSpeed extends StatefulWidget {
  const SetSpeed({super.key});

  @override
  State<SetSpeed> createState() => _SetSpeedState();
}

class _SetSpeedState extends State<SetSpeed> {
  late NumberInputDouble _speedInput;
  late MediaPlayerBlock _mediaPlayerBlock;

  @override
  void initState() {
    super.initState();

    _mediaPlayerBlock = Provider.of<ProjectBlock>(context, listen: false) as MediaPlayerBlock;

    _speedInput = NumberInputDouble(
      maxValue: 10.0,
      minValue: 0.1,
      defaultValue: _mediaPlayerBlock.speedFactor,
      countingValue: 0.1,
      countingIntervalMs: 200,
      displayText: TextEditingController(),
      descriptionText: "Speed Factor",
      textFieldWidth: TIOMusicParams.textFieldWidth3Digits,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speedInput.displayText.addListener(_onUserChangedSpeed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: "Set Speed",
      confirm: _onConfirm,
      reset: _reset,
      numberInput: _speedInput,
      cancel: _onCancel,
    );
  }

  void _onConfirm() async {
    if (_speedInput.displayText.value.text != '') {
      double newSpeedFactor = double.parse(_speedInput.displayText.value.text);

      _mediaPlayerBlock.speedFactor = newSpeedFactor;

      FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());

      rustApi.mediaPlayerSetSpeedFactor(speedFactor: newSpeedFactor).then((success) => {
            if (!success) {throw ("Setting speed factor in rust failed using this value: $newSpeedFactor")}
          });
    }

    Navigator.pop(context);
  }

  void _reset() {
    _speedInput.displayText.value =
        _speedInput.displayText.value.copyWith(text: MediaPlayerParams.defaultSpeedFactor.toString());
  }

  void _onCancel() {
    rustApi.mediaPlayerSetSpeedFactor(speedFactor: _mediaPlayerBlock.speedFactor).then((success) => {
          if (!success)
            {throw ("Setting speed factor in rust failed using this value: ${_mediaPlayerBlock.speedFactor}")}
        });

    Navigator.pop(context);
  }

  void _onUserChangedSpeed() async {
    if (_speedInput.displayText.value.text != '') {
      double newValue = double.parse(_speedInput.displayText.value.text);

      rustApi.mediaPlayerSetSpeedFactor(speedFactor: newValue).then((success) => {
            if (!success) {throw ("Setting speed factor in rust failed using this value: $newValue")}
          });
    }
  }
}
