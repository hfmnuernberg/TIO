import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/input/number_input_dec.dart';
import 'package:tiomusic/widgets/input/number_input_int.dart';
import 'package:tiomusic/widgets/input/slider_dec.dart';
import 'package:tiomusic/widgets/tap_to_tempo.dart';

const minSpeedFactor = 0.1;
const maxSpeedFactor = 10.0;
const step = 0.1;

double getSpeedForBpm(bpm, baseBpm) =>
    ((bpm / baseBpm).clamp(minSpeedFactor, maxSpeedFactor) * 10).roundToDouble() / 10;

int getBpmForSpeed(double speedFactor, int baseBpm) =>
    (speedFactor * baseBpm).clamp(minSpeedFactor * baseBpm, maxSpeedFactor * baseBpm).toInt();

class SetSpeed extends StatefulWidget {
  const SetSpeed({super.key});

  @override
  State<SetSpeed> createState() => _SetSpeedState();
}

class _SetSpeedState extends State<SetSpeed> {
  late double speed;
  late MediaPlayerBlock _mediaPlayerBlock;

  @override
  void initState() {
    super.initState();

    _mediaPlayerBlock = Provider.of<ProjectBlock>(context, listen: false) as MediaPlayerBlock;
    speed = _mediaPlayerBlock.speedFactor;
  }

  Future<void> _updateSpeed(double newSpeed) async {
    final success = await mediaPlayerSetSpeedFactor(speedFactor: newSpeed);
    if (!mounted) return;
    if (!success) {
      throw 'Setting speed factor in rust failed using value: $newSpeed';
    }
  }

  Future<void> _handleBpmChange(int newBpm) async {
    setState(() => speed = getSpeedForBpm(newBpm, _mediaPlayerBlock.bpm));
    await _updateSpeed(speed);
  }

  Future<void> _handleSpeedChange(double newSpeed) async {
    setState(() => speed = newSpeed);
    await _updateSpeed(speed);
  }

  void _handleConfirm() async {
    _mediaPlayerBlock.speedFactor = speed;
    FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    Navigator.pop(context);
  }

  Future<void> _handleReset() async {
    setState(() => speed = MediaPlayerParams.defaultSpeedFactor);
    await _updateSpeed(_mediaPlayerBlock.speedFactor);
  }

  void _handleCancel() async {
    await _updateSpeed(_mediaPlayerBlock.speedFactor);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ParentSettingPage(
      title: l10n.mediaPlayerSetSpeed,
      displayResetAtTop: true,
      mustBeScrollable: true,
      numberInput: Column(
        children: [
          SizedBox(height: TIOMusicParams.edgeInset),
          NumberInputDec(
            value: speed,
            onChanged: _handleSpeedChange,
            min: minSpeedFactor,
            max: maxSpeedFactor,
            defaultValue: _mediaPlayerBlock.speedFactor,
            step: step,
            stepIntervalInMs: 200,
            label: l10n.mediaPlayerFactor,
            textFieldWidth: TIOMusicParams.textFieldWidth3Digits,
            buttonRadius: 20,
            textFontSize: 32,
          ),

          SizedBox(height: TIOMusicParams.edgeInset * 2),
          SliderDec(
            value: speed,
            onChanged: _handleSpeedChange,
            min: minSpeedFactor,
            max: maxSpeedFactor,
            step: step,
            semanticLabel: l10n.mediaPlayerFactorAndBpm,
          ),

          SizedBox(height: TIOMusicParams.edgeInset * 2),
          NumberInputInt(
            value: getBpmForSpeed(speed, _mediaPlayerBlock.bpm),
            onChanged: _handleBpmChange,
            min: getBpmForSpeed(minSpeedFactor, _mediaPlayerBlock.bpm),
            max: getBpmForSpeed(maxSpeedFactor, _mediaPlayerBlock.bpm),
            defaultValue: _mediaPlayerBlock.bpm,
            step: getBpmForSpeed(step, _mediaPlayerBlock.bpm),
            label: l10n.commonBpm,
            textFieldWidth: TIOMusicParams.textFieldWidth3Digits,
            buttonRadius: 20,
            textFontSize: 32,
          ),

          SizedBox(height: TIOMusicParams.edgeInset * 2),
          Tap2Tempo(value: getBpmForSpeed(speed, _mediaPlayerBlock.bpm), onChanged: _handleBpmChange),
        ],
      ),
      confirm: _handleConfirm,
      reset: _handleReset,
      cancel: _handleCancel,
    );
  }
}
