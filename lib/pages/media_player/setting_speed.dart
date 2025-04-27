import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/services/project_repository.dart';
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

      final bpmValue = double.tryParse(bpmController.text);
      if (bpmValue != null) {
        final newSpeed = getSpeedForBpm(bpmValue, _mediaPlayerBlock.bpm);
        speedController.text = newSpeed.toStringAsFixed(1);
      }

      _isUpdating = false;
    });

    speedController.addListener(() {
      if (_isUpdating) return;
      _isUpdating = true;

      final speedValue = double.tryParse(speedController.text);
      if (speedValue != null) {
        final newBpm = getBpmForSpeed(speedValue, _mediaPlayerBlock.bpm);
        bpmController.text = newBpm.toString();
      }

      _isUpdating = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      speedController.addListener(_onUserChangedSpeed);
    });
  }

  @override
  void dispose() {
    bpmController.removeListener(() {});
    speedController.removeListener(() {});
    speedController.removeListener(_onUserChangedSpeed);
    bpmController.dispose();
    speedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ParentSettingPage(
      title: l10n.mediaPlayerSetSpeed,
      displayResetAtTop: true,
      mustBeScrollable: true,
      confirm: _onConfirm,
      reset: _reset,
      numberInput: Column(
        children: [
          SizedBox(height: TIOMusicParams.edgeInset),
          NumberInputDouble(
            max: maxSpeedFactor,
            min: minSpeedFactor,
            defaultValue: _mediaPlayerBlock.speedFactor,
            step: step,
            stepIntervalInMs: 200,
            controller: speedController,
            label: l10n.mediaPlayerFactor,
            textFieldWidth: TIOMusicParams.textFieldWidth3Digits,
            buttonRadius: 20,
            textFontSize: 32,
          ),

          SizedBox(height: TIOMusicParams.edgeInset * 2),
          AppSliderDouble(
            min: minSpeedFactor,
            max: maxSpeedFactor,
            defaultValue: _mediaPlayerBlock.speedFactor,
            step: step,
            controller: speedController,
            semanticLabel: l10n.mediaPlayerFactorAndBpm,
          ),

          SizedBox(height: TIOMusicParams.edgeInset * 2),
          NumberInputInt(
            max: getBpmForSpeed(maxSpeedFactor, _mediaPlayerBlock.bpm),
            min: getBpmForSpeed(minSpeedFactor, _mediaPlayerBlock.bpm),
            defaultValue: _mediaPlayerBlock.bpm,
            step: getBpmForSpeed(step, _mediaPlayerBlock.bpm),
            controller: bpmController,
            label: l10n.commonBpm,
            textFieldWidth: TIOMusicParams.textFieldWidth3Digits,
            buttonRadius: 20,
            textFontSize: 32,
          ),

          SizedBox(height: TIOMusicParams.edgeInset * 2),
          Tap2Tempo(bpmHandle: bpmController),
        ],
      ),
      cancel: _onCancel,
    );
  }

  void _onConfirm() async {
    if (speedController.text.isNotEmpty) {
      final newSpeedFactor = double.parse(speedController.text);

      _mediaPlayerBlock.speedFactor = newSpeedFactor;

      context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());

      final success = await mediaPlayerSetSpeedFactor(speedFactor: newSpeedFactor);
      if (!mounted) return;
      if (!success) {
        throw 'Setting speed factor in rust failed using value: $newSpeedFactor';
      }
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _reset() {
    bpmController.value = bpmController.value.copyWith(
      text: getBpmForSpeed(MediaPlayerParams.defaultSpeedFactor, _mediaPlayerBlock.bpm).toString(),
    );
    speedController.value = speedController.value.copyWith(text: MediaPlayerParams.defaultSpeedFactor.toString());
  }

  void _onCancel() async {
    final success = await mediaPlayerSetSpeedFactor(speedFactor: _mediaPlayerBlock.speedFactor);
    if (!mounted) return;
    if (!success) {
      throw 'Setting speed factor in rust failed using value: ${_mediaPlayerBlock.speedFactor}';
    }

    Navigator.pop(context);
  }

  void _onUserChangedSpeed() async {
    if (speedController.text.isNotEmpty) {
      final newValue = double.parse(speedController.text);
      final success = await mediaPlayerSetSpeedFactor(speedFactor: newValue);
      if (!mounted) return;
      if (!success) {
        throw 'Setting speed factor in rust failed using this value: $newValue';
      }
    }
  }
}
