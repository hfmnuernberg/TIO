import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/pages/parent_tool/volume.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/input/number_input_and_slider_dec.dart';
import 'package:volume_controller/volume_controller.dart';

const maxVolume = 1.0;
const minVolume = 0.0;

class SetVolume extends StatefulWidget {
  final double initialValue;
  final Function(double) onConfirm;
  final Function(double) onChange;
  final Function() onCancel;

  const SetVolume({
    super.key,
    required this.initialValue,
    required this.onConfirm,
    required this.onChange,
    required this.onCancel,
  });

  @override
  State<SetVolume> createState() => _SetVolumeState();
}

class _SetVolumeState extends State<SetVolume> {
  late double volume;
  VolumeLevel deviceVolumeLevel = VolumeLevel.normal;

  @override
  void initState() {
    super.initState();
    VolumeController.instance.addListener(_handleDeviceVolumeChange);
    volume = widget.initialValue;
  }

  @override
  void dispose() {
    VolumeController.instance.removeListener();
    super.dispose();
  }

  void _handleDeviceVolumeChange(double newVolume) => setState(() => deviceVolumeLevel = getVolumeLevel(newVolume));

  void _handleChange(double newVolume) {
    setState(() => volume = newVolume.clamp(minVolume, maxVolume));
    widget.onChange(volume);
  }

  void _handleReset() => _handleChange(widget.initialValue);

  void _handleConfirm() async {
    widget.onConfirm(volume);
    await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _handleCancel() {
    widget.onCancel();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: context.l10n.commonSetVolume,
      numberInput: NumberInputAndSliderDec(
        value: volume,
        onChange: _handleChange,
        min: minVolume,
        max: maxVolume,
        step: 0.1,
        stepIntervalInMs: 200,
        textFieldWidth: TIOMusicParams.textFieldWidth2Digits,
        label: context.l10n.commonVolume,
      ),
      infoWidget: Padding(
        padding: const EdgeInsets.all(TIOMusicParams.edgeInset),
        child: Row(
          children: [
            Icon(getVolumeInfoIconData(deviceVolumeLevel), color: ColorTheme.onSecondary),
            const SizedBox(width: TIOMusicParams.edgeInset),
            Expanded(
              child: Text(
                getVolumeInfoText(deviceVolumeLevel, context.l10n),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: ColorTheme.onSecondary),
              ),
            ),
          ],
        ),
      ),
      confirm: _handleConfirm,
      reset: _handleReset,
      cancel: _handleCancel,
    );
  }
}
