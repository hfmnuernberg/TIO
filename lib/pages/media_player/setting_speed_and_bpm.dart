import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/metronome/tap_to_tempo.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/number_input_double.dart';
import 'package:tiomusic/widgets/number_input_int.dart';

final defaultBPM = 80;
final minBPM = 10;
final maxBPM = 500;

class SetSpeedAndBPM extends StatefulWidget {
  const SetSpeedAndBPM({super.key});

  @override
  State<SetSpeedAndBPM> createState() => _SetSpeedAndBPMState();
}

class _SetSpeedAndBPMState extends State<SetSpeedAndBPM> {
  late NumberInputInt _bpmInput;
  late NumberInputDouble _speedInput;
  late MediaPlayerBlock _mediaPlayerBlock;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();

    _mediaPlayerBlock = Provider.of<ProjectBlock>(context, listen: false) as MediaPlayerBlock;

    _bpmInput = NumberInputInt(
      maxValue: maxBPM,
      minValue: minBPM,
      defaultValue: _mediaPlayerBlock.bpm,
      countingValue: 1,
      displayText: TextEditingController(),
      descriptionText: 'BPM',
      buttonRadius: 20,
      textFieldWidth: 100,
      textFontSize: 32,
    );

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
      title: "Set Speed/BPM",
      confirm: _onConfirm,
      reset: _reset,
      numberInput: Column(
        children: [
          _bpmInput,
          Tap2Tempo(bpmHandle: _bpmInput.displayText),
          SizedBox(height: TIOMusicParams.edgeInset * 2),
          InkWell(
            child: Row(
              children: [
                Expanded(child: Divider(color: ColorTheme.primary80, thickness: 2)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(_isConnected ? Icons.link : Icons.link_off, size: 24, color: ColorTheme.primary),
                ),
                Expanded(child: Divider(color: ColorTheme.primary80, thickness: 2)),
              ],
            ),
            onTap: () {
              setState(() {
                _isConnected = !_isConnected;
              });
            },
          ),
          SizedBox(height: TIOMusicParams.edgeInset * 3),
          _speedInput,
        ],
      ),
      cancel: _onCancel,
    );
  }

  void _onConfirm() async {
    if (_speedInput.displayText.value.text != '') {
      double newSpeedFactor = double.parse(_speedInput.displayText.value.text);

      _mediaPlayerBlock.speedFactor = newSpeedFactor;

      FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());

      mediaPlayerSetSpeedFactor(speedFactor: newSpeedFactor).then((success) => {
            if (!success) {throw ("Setting speed factor in rust failed using this value: $newSpeedFactor")}
          });
    }

    Navigator.pop(context);
  }

  void _reset() {
    _bpmInput.displayText.value = _bpmInput.displayText.value.copyWith(text: defaultBPM.toString());
    _speedInput.displayText.value =
        _speedInput.displayText.value.copyWith(text: MediaPlayerParams.defaultSpeedFactor.toString());
  }

  void _onCancel() {
    mediaPlayerSetSpeedFactor(speedFactor: _mediaPlayerBlock.speedFactor).then((success) => {
          if (!success)
            {throw ("Setting speed factor in rust failed using this value: ${_mediaPlayerBlock.speedFactor}")}
        });

    Navigator.pop(context);
  }

  void _onUserChangedSpeed() async {
    if (_speedInput.displayText.value.text != '') {
      double newValue = double.parse(_speedInput.displayText.value.text);

      mediaPlayerSetSpeedFactor(speedFactor: newValue).then((success) => {
            if (!success) {throw ("Setting speed factor in rust failed using this value: $newValue")}
          });
    }
  }
}
