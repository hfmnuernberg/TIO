import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/number_input_double.dart';

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
  late NumberInputDouble _volumeInput;

  @override
  void initState() {
    super.initState();

    _volumeInput = NumberInputDouble(
      maxValue: 1.0,
      minValue: 0.0,
      defaultValue: widget.initialValue,
      countingValue: 0.1,
      countingIntervalMs: 200,
      displayText: TextEditingController(),
      textFieldWidth: TIOMusicParams.textFieldWidth2Digits,
      descriptionText: "Volume",
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _volumeInput.displayText.addListener(_onUserChangedVolume);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: "Set Volume",
      numberInput: _volumeInput,
      confirm: _onConfirm,
      reset: _reset,
      cancel: _onCancel,
    );
  }

  void _onConfirm() async {
    if (_volumeInput.displayText.value.text != '') {
      final newVolumeValue = double.parse(_volumeInput.displayText.value.text);
      widget.onConfirm(newVolumeValue.clamp(0.0, 1.0));

      FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    }

    Navigator.pop(context);
  }

  void _reset() {
    _volumeInput.displayText.value = _volumeInput.displayText.value
        .copyWith(text: TIOMusicParams.defaultVolume.toString());
  }

  void _onCancel() {
    widget.onCancel();
    Navigator.pop(context);
  }

  void _onUserChangedVolume() async {
    if (_volumeInput.displayText.value.text != '') {
      final newVolumeValue = double.parse(_volumeInput.displayText.value.text);
      widget.onUserChangedVolume(newVolumeValue.clamp(0.0, 1.0));
    }
  }
}
