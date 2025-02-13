import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/number_input_double_with_slider.dart';
import 'package:tiomusic/widgets/number_input_int_with_slider.dart';
import 'package:tiomusic/widgets/tap_to_tempo.dart';

const MIN_SPEED_FACTOR = 0.1;
const MAX_SPEED_FACTOR = 10.0;
const COUNTING_VALUE = 0.1;

double getSpeedForBpm(bpm, baseBpm) => (bpm / baseBpm)
    .clamp(MIN_SPEED_FACTOR, MAX_SPEED_FACTOR);

int getBpmForSpeed(speedFactor, baseBpm) => (speedFactor * baseBpm)
    .clamp(MIN_SPEED_FACTOR * baseBpm, MAX_SPEED_FACTOR * baseBpm)
    .toInt();

class SetSpeedAndBPM extends StatefulWidget {
  const SetSpeedAndBPM({super.key});

  @override
  State<SetSpeedAndBPM> createState() => _SetSpeedAndBPMState();
}

class _SetSpeedAndBPMState extends State<SetSpeedAndBPM> {
  late NumberInputIntWithSlider _bpmInput;
  late NumberInputDoubleWithSlider _speedInput;
  late MediaPlayerBlock _mediaPlayerBlock;
  bool _isUpdating = false;

  late final TextEditingController bpmController;
  late final TextEditingController speedController;

  @override
  void initState() {
    super.initState();

    _mediaPlayerBlock = Provider.of<ProjectBlock>(context, listen: false) as MediaPlayerBlock;

    bpmController = TextEditingController(text: getBpmForSpeed(_mediaPlayerBlock.speedFactor, _mediaPlayerBlock.bpm).toString());
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

    _bpmInput = NumberInputIntWithSlider(
      max: getBpmForSpeed(MAX_SPEED_FACTOR, _mediaPlayerBlock.bpm),
      min: getBpmForSpeed(MIN_SPEED_FACTOR, _mediaPlayerBlock.bpm),
      defaultValue: _mediaPlayerBlock.bpm,
      step: getBpmForSpeed(COUNTING_VALUE, _mediaPlayerBlock.bpm),
      controller: bpmController,
      descriptionText: 'BPM',
      textFieldWidth: TIOMusicParams.textFieldWidth3Digits,
    );

    _speedInput = NumberInputDoubleWithSlider(
      max: MAX_SPEED_FACTOR,
      min: MIN_SPEED_FACTOR,
      defaultValue: _mediaPlayerBlock.speedFactor,
      step: COUNTING_VALUE,
      stepIntervalInMs: 200,
      controller: speedController,
      descriptionText: "Factor",
      textFieldWidth: TIOMusicParams.textFieldWidth3Digits,
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
      title: "Set Speed",
      confirm: _onConfirm,
      reset: _reset,
      numberInput: Column(
        children: [
          _bpmInput,
          Tap2Tempo(bpmHandle: _bpmInput.controller),
          SizedBox(height: TIOMusicParams.edgeInset * 2),
          Divider(color: ColorTheme.primary80, thickness: 2, indent: 20, endIndent: 20,),
          SizedBox(height: TIOMusicParams.edgeInset * 3),
          _speedInput,
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

      mediaPlayerSetSpeedFactor(speedFactor: newSpeedFactor).then((success) => {
            if (!success) {throw ("Setting speed factor in rust failed using this value: $newSpeedFactor")}
          });
    }

    Navigator.pop(context);
  }
  void _reset() {
    _bpmInput.controller.value = _bpmInput.controller.value.copyWith(text: getBpmForSpeed(MediaPlayerParams.defaultSpeedFactor, _mediaPlayerBlock.bpm).toString());
    _speedInput.controller.value =
        _speedInput.controller.value.copyWith(text: MediaPlayerParams.defaultSpeedFactor.toString());
  }

  void _onCancel() {
    mediaPlayerSetSpeedFactor(speedFactor: _mediaPlayerBlock.speedFactor).then((success) => {
          if (!success)
            {throw ("Setting speed factor in rust failed using this value: ${_mediaPlayerBlock.speedFactor}")}
        });

    Navigator.pop(context);
  }

  void _onUserChangedSpeed() async {
    if (_speedInput.controller.value.text != '') {
      double newValue = double.parse(_speedInput.controller.value.text);

      mediaPlayerSetSpeedFactor(speedFactor: newValue).then((success) => {
            if (!success) {throw ("Setting speed factor in rust failed using this value: $newValue")}
          });
    }
  }
}
