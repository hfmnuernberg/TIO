import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/input/app_slider_double.dart';
import 'package:tiomusic/widgets/input/number_input_double.dart';
import 'package:tiomusic/widgets/input/number_input_int.dart';
import 'package:tiomusic/widgets/tap_to_tempo.dart';

const minSpeedFactor = 0.1;
const maxSpeedFactor = 10.0;
const step = 0.1;

double getSpeedForBpm(bpm, baseBpm) => (bpm / baseBpm).clamp(minSpeedFactor, maxSpeedFactor);

int getBpmForSpeed(speedFactor, baseBpm) =>
    (speedFactor * baseBpm).clamp(minSpeedFactor * baseBpm, maxSpeedFactor * baseBpm).toInt();

class SetSpeed extends StatefulWidget {
  const SetSpeed({super.key});

  @override
  State<SetSpeed> createState() => _SetSpeedState();
}

class _SetSpeedState extends State<SetSpeed> {
  late NumberInputInt _bpmInput;
  late NumberInputDouble _speedInput;
  late AppSliderDouble _customSliderDouble;
  late MediaPlayerBlock _mediaPlayerBlock;
  bool _isUpdating = false;

  late final TextEditingController bpmController;
  late final TextEditingController speedController;

  @override
  void initState() {
    super.initState();

    _mediaPlayerBlock = Provider.of<ProjectBlock>(context, listen: false) as MediaPlayerBlock;

    bpmController = TextEditingController(
      text: getBpmForSpeed(_mediaPlayerBlock.speedFactor, _mediaPlayerBlock.bpm).toString(),
    );
    speedController = TextEditingController(text: _mediaPlayerBlock.speedFactor.toString());

    bpmController.addListener(() {
      if (_isUpdating) return;
      _isUpdating = true;

      double? bpmValue = double.tryParse(bpmController.text);
      if (bpmValue != null) {
        double newSpeed = getSpeedForBpm(bpmValue, _mediaPlayerBlock.bpm);
        speedController.text = newSpeed.toStringAsFixed(1);
      }

      _isUpdating = false;
    });

    speedController.addListener(() {
      if (_isUpdating) return;
      _isUpdating = true;

      double? speedValue = double.tryParse(speedController.text);
      if (speedValue != null) {
        int newBpm = getBpmForSpeed(speedValue, _mediaPlayerBlock.bpm);
        bpmController.text = newBpm.toString();
      }

      _isUpdating = false;
    });

    _bpmInput = NumberInputInt(
      max: getBpmForSpeed(maxSpeedFactor, _mediaPlayerBlock.bpm),
      min: getBpmForSpeed(minSpeedFactor, _mediaPlayerBlock.bpm),
      defaultValue: _mediaPlayerBlock.bpm,
      step: getBpmForSpeed(step, _mediaPlayerBlock.bpm),
      controller: bpmController,
      label: 'BPM',
      textFieldWidth: TIOMusicParams.textFieldWidth3Digits,
      buttonRadius: 20,
      textFontSize: 32,
    );

    _speedInput = NumberInputDouble(
      max: maxSpeedFactor,
      min: minSpeedFactor,
      defaultValue: _mediaPlayerBlock.speedFactor,
      step: step,
      stepIntervalInMs: 200,
      controller: speedController,
      label: 'Factor',
      textFieldWidth: TIOMusicParams.textFieldWidth3Digits,
      buttonRadius: 20,
      textFontSize: 32,
    );

    _customSliderDouble = AppSliderDouble(
      min: minSpeedFactor,
      max: maxSpeedFactor,
      defaultValue: _mediaPlayerBlock.speedFactor,
      step: step,
      controller: speedController,
      semanticLabel: 'Factor and BPM slider',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speedInput.controller.addListener(_onUserChangedSpeed);
    });
  }

  @override
  void dispose() {
    bpmController.dispose();
    speedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: 'Set Speed',
      displayResetAtTop: true,
      mustBeScrollable: true,
      confirm: _onConfirm,
      reset: _reset,
      numberInput: Column(
        children: [
          SizedBox(height: TIOMusicParams.edgeInset),
          _speedInput,
          SizedBox(height: TIOMusicParams.edgeInset * 2),
          _customSliderDouble,
          SizedBox(height: TIOMusicParams.edgeInset * 2),
          _bpmInput,
          SizedBox(height: TIOMusicParams.edgeInset * 2),
          Tap2Tempo(bpmHandle: _bpmInput.controller),
        ],
      ),
      cancel: _onCancel,
    );
  }

  void _onConfirm() async {
    if (_speedInput.controller.value.text != '') {
      double newSpeedFactor = double.parse(_speedInput.controller.value.text);

      _mediaPlayerBlock.speedFactor = newSpeedFactor;

      FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());

      mediaPlayerSetSpeedFactor(speedFactor: newSpeedFactor).then(
        (success) => {
          if (!success) {throw 'Setting speed factor in rust failed using this value: $newSpeedFactor'},
        },
      );
    }

    Navigator.pop(context);
  }

  void _reset() {
    _bpmInput.controller.value = _bpmInput.controller.value.copyWith(
      text: getBpmForSpeed(MediaPlayerParams.defaultSpeedFactor, _mediaPlayerBlock.bpm).toString(),
    );
    _speedInput.controller.value = _speedInput.controller.value.copyWith(
      text: MediaPlayerParams.defaultSpeedFactor.toString(),
    );
  }

  void _onCancel() {
    mediaPlayerSetSpeedFactor(speedFactor: _mediaPlayerBlock.speedFactor).then(
      (success) => {
        if (!success)
          {throw 'Setting speed factor in rust failed using this value: ${_mediaPlayerBlock.speedFactor}'},
      },
    );

    Navigator.pop(context);
  }

  void _onUserChangedSpeed() async {
    if (_speedInput.controller.value.text != '') {
      double newValue = double.parse(_speedInput.controller.value.text);

      mediaPlayerSetSpeedFactor(speedFactor: newValue).then(
        (success) => {
          if (!success) {throw 'Setting speed factor in rust failed using this value: $newValue'},
        },
      );
    }
  }
}
