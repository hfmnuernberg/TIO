import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/piano_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/models/sound_font.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/l10n/sound_font_extensions.dart';

class ChooseSound extends StatefulWidget {
  const ChooseSound({super.key});

  @override
  State<ChooseSound> createState() => _ChooseSoundState();
}

class _ChooseSoundState extends State<ChooseSound> {
  late PianoBlock _pianoBlock;

  final List<bool> _selectedSounds = List<bool>.filled(SoundFont.values.length, false);

  @override
  void initState() {
    super.initState();

    _pianoBlock = Provider.of<ProjectBlock>(context, listen: false) as PianoBlock;

    for (var i = 0; i < _selectedSounds.length; i++) {
      if (i == _pianoBlock.soundFontIndex) {
        _selectedSounds[i] = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: context.l10n.pianoSetSound,
      confirm: _onConfirm,
      reset: _reset,
      customWidget: ToggleButtons(
        direction: Axis.vertical,
        onPressed: (index) {
          setState(() {
            for (int i = 0; i < _selectedSounds.length; i++) {
              _selectedSounds[i] = i == index;
            }
          });
        },
        constraints: const BoxConstraints(minHeight: 30, minWidth: 200),
        isSelected: _selectedSounds,
        children: SoundFont.values
            .map(
              (soundFont) => Text(soundFont.getLabel(context.l10n), style: const TextStyle(color: ColorTheme.primary)),
            )
            .toList(),
      ),
    );
  }

  Future<void> _onConfirm() async {
    _pianoBlock.soundFontIndex = _selectedSounds.indexWhere((element) => element);
    await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _reset() {
    _selectedSounds.fillRange(0, SoundFont.values.length, false);
    _selectedSounds[PianoParams.defaultSoundFontIndex] = true;
    setState(() {});
  }
}
