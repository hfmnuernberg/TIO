import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/blocks/piano_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';

class ChooseSound extends StatefulWidget {
  const ChooseSound({super.key});

  @override
  State<ChooseSound> createState() => _ChooseSoundState();
}

class _ChooseSoundState extends State<ChooseSound> {
  late PianoBlock _pianoBlock;

  final List<Widget> _sounds = <Widget>[
    ...PianoParams.soundFontNames
        .map((String soundFontName) => Text(soundFontName, style: const TextStyle(color: ColorTheme.primary)))
  ];

  final List<bool> _selectedSounds = List<bool>.filled(PianoParams.soundFontNames.length, false);

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
      title: "Set Piano Sound",
      confirm: _onConfirm,
      reset: _reset,
      customWidget: ToggleButtons(
        direction: Axis.vertical,
        onPressed: (int index) {
          setState(() {
            for (int i = 0; i < _selectedSounds.length; i++) {
              _selectedSounds[i] = i == index;
            }
          });
        },
        constraints: const BoxConstraints(
          minHeight: 40.0,
          minWidth: 200.0,
        ),
        isSelected: _selectedSounds,
        children: _sounds,
      ),
    );
  }

  void _onConfirm() {
    _pianoBlock.soundFontIndex = _selectedSounds.indexWhere((element) => element);
    FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    Navigator.pop(context);
  }

  void _reset() {
    _selectedSounds.fillRange(0, _sounds.length, false);
    _selectedSounds[PianoParams.defaultSoundFontIndex] = true;
    setState(() {});
  }
}
