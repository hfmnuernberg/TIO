import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/util/constants/constants.dart';
import 'package:tiomusic/widgets/input/number_input_dec.dart';
import 'package:tiomusic/widgets/input/number_input_int.dart';
import 'package:tiomusic/widgets/input/slider_dec.dart';
import 'package:tiomusic/widgets/input/tap_to_tempo.dart';

const defaultSpeed = 1.0;
const minSpeedFactor = 0.1;
const maxSpeedFactor = 10.0;
const step = 0.1;

double getSpeedForBpm(int bpm, int baseBpm) =>
    ((bpm / baseBpm).clamp(minSpeedFactor, maxSpeedFactor) * 10).roundToDouble() / 10;

int getBpmForSpeed(double speedFactor, int baseBpm) =>
    (speedFactor * baseBpm).clamp(minSpeedFactor * baseBpm, maxSpeedFactor * baseBpm).toInt();

class SetSpeed extends StatefulWidget {
  final int baseBpm;
  final Future<void> Function(double newSpeed) onChangeSpeed;
  final Future<void> Function(int newBpm) onChangeBpm;
  final Future<void> Function(double speed) onConfirm;
  final Future<void> Function() onCancel;
  final double initialSpeed;

  const SetSpeed({
    super.key,
    required this.baseBpm,
    required this.onChangeSpeed,
    required this.onChangeBpm,
    required this.onConfirm,
    required this.onCancel,
    required this.initialSpeed,
  });

  @override
  State<SetSpeed> createState() => _SetSpeedState();
}

class _SetSpeedState extends State<SetSpeed> {
  late double speed;

  @override
  void initState() {
    super.initState();
    speed = widget.initialSpeed;
  }

  Future<void> _handleBpmChange(int newBpm) async {
    final newSpeed = getSpeedForBpm(newBpm, widget.baseBpm);
    setState(() => speed = newSpeed);
    await widget.onChangeBpm(newBpm);
  }

  Future<void> _handleSpeedChange(double newSpeed) async {
    setState(() => speed = newSpeed.clamp(minSpeedFactor, maxSpeedFactor));
    await widget.onChangeSpeed(speed);
  }

  Future<void> _handleConfirm() async {
    await widget.onConfirm(speed);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _handleReset() async => _handleSpeedChange(defaultSpeed);

  Future<void> _handleCancel() async {
    await widget.onCancel();
    if (mounted) Navigator.pop(context);
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
            onChange: _handleSpeedChange,
            min: minSpeedFactor,
            max: maxSpeedFactor,
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
            onChange: _handleSpeedChange,
            min: minSpeedFactor,
            max: maxSpeedFactor,
            step: step,
            semanticLabel: l10n.mediaPlayerFactorAndBpm,
          ),
          SizedBox(height: TIOMusicParams.edgeInset * 2),
          NumberInputInt(
            value: getBpmForSpeed(speed, widget.baseBpm),
            onChange: _handleBpmChange,
            min: getBpmForSpeed(minSpeedFactor, widget.baseBpm),
            max: getBpmForSpeed(maxSpeedFactor, widget.baseBpm),
            step: getBpmForSpeed(step, widget.baseBpm),
            label: l10n.commonBpm,
            textFieldWidth: TIOMusicParams.textFieldWidth3Digits,
            buttonRadius: 20,
            textFontSize: 32,
          ),
          SizedBox(height: TIOMusicParams.edgeInset * 2),
          Tap2Tempo(value: getBpmForSpeed(speed, widget.baseBpm), onChange: _handleBpmChange),
        ],
      ),
      confirm: _handleConfirm,
      reset: _handleReset,
      cancel: _handleCancel,
    );
  }
}
