import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/input/number_input_and_slider_dec.dart';

const minPitch = -24.0;
const maxPitch = 24.0;

class SetPitch extends StatefulWidget {
  final double initialValue;
  final Future<void> Function(double newPitch) onChange;
  final Future<void> Function(double newPitch) onConfirm;
  final Future<void> Function() onCancel;
  final Future<void> Function()? onReset;

  const SetPitch({
    super.key,
    required this.initialValue,
    required this.onChange,
    required this.onConfirm,
    required this.onCancel,
    this.onReset,
  });

  @override
  State<SetPitch> createState() => _SetPitchState();
}

class _SetPitchState extends State<SetPitch> {
  late double pitch;

  @override
  void initState() {
    super.initState();
    pitch = widget.initialValue;
  }

  Future<void> _handleChange(double newPitch) async {
    setState(() => pitch = newPitch.clamp(minPitch, maxPitch));
    await widget.onChange(pitch);
  }

  Future<void> _handleReset() async {
    const resetValue = MediaPlayerParams.defaultPitchSemitones;
    setState(() => pitch = resetValue);
    if (widget.onReset != null) {
      await widget.onReset!();
    } else {
      await widget.onChange(resetValue);
    }
  }

  Future<void> _handleConfirm() async {
    widget.onConfirm(pitch);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _handleCancel() async {
    widget.onCancel();
    if (mounted) Navigator.pop(context);
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
