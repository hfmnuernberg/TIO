import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/util/tutorial_util.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tiomusic/widgets/input/number_input_and_slider_int.dart';
import 'package:tiomusic/widgets/input/tap_to_tempo.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

const defaultBpm = 80;
const minBpm = 10;
const maxBpm = 500;

class SetBPM extends StatefulWidget {
  final Future<void> Function() onSave;

  const SetBPM({super.key, required this.onSave});

  @override
  State<SetBPM> createState() => _SetBPMState();
}

class _SetBPMState extends State<SetBPM> {
  late int value;
  late MediaPlayerBlock _mediaPlayerBlock;

  final Tutorial _tutorial = Tutorial();
  final GlobalKey _keyBasicBeat = GlobalKey();

  @override
  void initState() {
    super.initState();
    _mediaPlayerBlock = context.read<ProjectBlock>() as MediaPlayerBlock;
    value = _mediaPlayerBlock.bpm;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.read<ProjectLibrary>().showMediaPlayerBasicBeatTutorial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _createTutorial();
        _tutorial.show(context);
      });
    }
  }

  void _createTutorial() {
    final target = CustomTargetFocus(
      _keyBasicBeat,
      context.l10n.mediaPlayerTutorialBasicBeat,
      alignText: ContentAlign.bottom,
      pointingDirection: PointingDirection.up,
      buttonsPosition: ButtonsPosition.bottom,
      shape: ShapeLightFocus.RRect,
    );

    _tutorial.create([target.targetFocus], () async {
      context.read<ProjectLibrary>().showMediaPlayerTutorial = false;
      await widget.onSave();
    }, context);
  }

  void _handleChange(int newBpm) => setState(() => value = newBpm);

  void _handleReset() => _handleChange(defaultBpm);

  Future<void> _handleConfirm() async {
    _mediaPlayerBlock.bpm = value;
    await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: context.l10n.commonBasicBeatSetting,
      numberInput: NumberInputAndSliderInt(
        key: _keyBasicBeat,
        value: value,
        onChange: _handleChange,
        min: minBpm,
        max: maxBpm,
        step: 1,
        label: context.l10n.commonBpm,
        buttonRadius: 20,
        textFieldWidth: 100,
        textFontSize: 32,
      ),
      customWidget: Tap2Tempo(value: value, onChange: _handleChange),
      confirm: _handleConfirm,
      reset: _handleReset,
    );
  }
}
