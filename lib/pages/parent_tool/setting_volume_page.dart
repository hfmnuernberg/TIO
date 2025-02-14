import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/pages/parent_tool/volume.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/number_input_double_with_slider.dart';
import 'package:volume_controller/volume_controller.dart';

class SetVolume extends StatefulWidget {
  final Function(double) onConfirm;
  final Function(double) onUserChangedVolume;
  final Function() onCancel;

  final double initialValue;

  const SetVolume({
    super.key,
    required this.initialValue,
    required this.onConfirm,
    required this.onUserChangedVolume,
    required this.onCancel,
  });

  @override
  State<SetVolume> createState() => _SetVolumeState();
}

class _SetVolumeState extends State<SetVolume> {
  late NumberInputDoubleWithSlider _volumeInput;
  VolumeLevel _deviceVolumeLevel = VolumeLevel.normal;

  @override
  void initState() {
    super.initState();

    VolumeController.instance.addListener(handleVolumeChange);

    _volumeInput = NumberInputDoubleWithSlider(
      max: 1.0,
      min: 0.0,
      defaultValue: widget.initialValue,
      step: 0.1,
      stepIntervalInMs: 200,
      controller: TextEditingController(),
      textFieldWidth: TIOMusicParams.textFieldWidth2Digits,
      label: "Volume",
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _volumeInput.controller.addListener(_onUserChangedVolume);
    });
  }

  void handleVolumeChange(double newVolume) => setState(() => _deviceVolumeLevel = getVolumeLevel(newVolume));

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: "Set Volume",
      numberInput: _volumeInput,
      infoWidget: Padding(
        padding: const EdgeInsets.all(TIOMusicParams.edgeInset),
        child: Row(
          children: [
            Icon(getVolumeInfoIconData(_deviceVolumeLevel), color: ColorTheme.onSecondary),
            const SizedBox(width: TIOMusicParams.edgeInset),
            Expanded(
              child: Text(
                getVolumeInfoText(_deviceVolumeLevel),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: ColorTheme.onSecondary),
              ),
            ),
          ],
        ),
      ),
      confirm: _onConfirm,
      reset: _reset,
      cancel: _onCancel,
    );
  }

  void _onConfirm() async {
    if (_volumeInput.controller.value.text != '') {
      final newVolumeValue = double.parse(_volumeInput.controller.value.text);
      widget.onConfirm(newVolumeValue.clamp(0.0, 1.0));

      FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    }

    Navigator.pop(context);
  }

  void _reset() {
    _volumeInput.controller.value =
        _volumeInput.controller.value.copyWith(text: TIOMusicParams.defaultVolume.toString());
  }

  void _onCancel() {
    widget.onCancel();
    Navigator.pop(context);
  }

  void _onUserChangedVolume() async {
    if (_volumeInput.controller.value.text != '') {
      final newVolumeValue = double.parse(_volumeInput.controller.value.text);
      widget.onUserChangedVolume(newVolumeValue.clamp(0.0, 1.0));
    }
  }
}
