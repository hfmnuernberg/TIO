import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/pages/parent_tool/volume.dart';
import 'package:tiomusic/services/project_library_repository.dart';
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
  VolumeLevel _deviceVolumeLevel = VolumeLevel.normal;
  final TextEditingController _volumeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    VolumeController.instance.addListener(handleVolumeChange);

    _volumeController.text = widget.initialValue.toString();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _volumeController.addListener(_onUserChangedVolume);
    });
  }

  @override
  void dispose() {
    VolumeController.instance.removeListener();
    _volumeController.removeListener(_onUserChangedVolume);
    _volumeController.dispose();
    super.dispose();
  }

  void handleVolumeChange(double newVolume) => setState(() => _deviceVolumeLevel = getVolumeLevel(newVolume));

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: context.l10n.commonSetVolume,
      numberInput: NumberInputDoubleWithSlider(
        max: 1,
        min: 0,
        defaultValue: widget.initialValue,
        step: 0.1,
        stepIntervalInMs: 200,
        controller: _volumeController,
        textFieldWidth: TIOMusicParams.textFieldWidth2Digits,
        label: context.l10n.commonVolume,
      ),
      infoWidget: Padding(
        padding: const EdgeInsets.all(TIOMusicParams.edgeInset),
        child: Row(
          children: [
            Icon(getVolumeInfoIconData(_deviceVolumeLevel), color: ColorTheme.onSecondary),
            const SizedBox(width: TIOMusicParams.edgeInset),
            Expanded(
              child: Text(
                getVolumeInfoText(_deviceVolumeLevel, context.l10n),
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
    if (_volumeController.text != '') {
      final newVolumeValue = double.parse(_volumeController.text);
      widget.onConfirm(newVolumeValue.clamp(0.0, 1.0));

      await context.read<ProjectLibraryRepository>().save(context.read<ProjectLibrary>());
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _reset() {
    _volumeController.value = _volumeController.value.copyWith(text: TIOMusicParams.defaultVolume.toString());
  }

  void _onCancel() {
    widget.onCancel();
    Navigator.pop(context);
  }

  void _onUserChangedVolume() async {
    if (_volumeController.text != '') {
      final newVolumeValue = double.parse(_volumeController.text);
      widget.onUserChangedVolume(newVolumeValue.clamp(0.0, 1.0));
    }
  }
}
