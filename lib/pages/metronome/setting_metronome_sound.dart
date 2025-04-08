// Setting page for metronome sounds

import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/metronome/metronome_utils.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';

import 'package:tiomusic/models/file_io.dart';

enum SoundType { accented, unaccented, polyAccented, polyUnaccented }

class SetMetronomeSound extends StatefulWidget {
  final bool running;
  final bool forSecondMetronome;
  const SetMetronomeSound({super.key, required this.running, this.forSecondMetronome = false});

  @override
  State<SetMetronomeSound> createState() => _SetMetronomeSoundState();
}

class _SetMetronomeSoundState extends State<SetMetronomeSound> {
  late MetronomeBlock _metronomeBlock;

  final List<Widget> _sounds = List<Widget>.generate(
    MetronomeParams.metronomeSounds.length,
    (index) => Text(MetronomeParams.metronomeSounds[index], style: const TextStyle(color: ColorTheme.primary)),
    growable: false,
  );

  final List<bool> _selectedAccSound = List<bool>.filled(MetronomeParams.metronomeSounds.length, false);
  final List<bool> _selectedUnaccSound = List<bool>.filled(MetronomeParams.metronomeSounds.length, false);
  final List<bool> _selectedPolyAccSound = List<bool>.filled(MetronomeParams.metronomeSounds.length, false);
  final List<bool> _selectedPolyUnaccSound = List<bool>.filled(MetronomeParams.metronomeSounds.length, false);

  @override
  void initState() {
    super.initState();

    _metronomeBlock = Provider.of<ProjectBlock>(context, listen: false) as MetronomeBlock;

    if (widget.forSecondMetronome) {
      _selectedAccSound[max(MetronomeParams.metronomeSounds.indexOf(_metronomeBlock.accSound2), 0)] = true;
      _selectedUnaccSound[max(MetronomeParams.metronomeSounds.indexOf(_metronomeBlock.unaccSound2), 0)] = true;
      _selectedPolyAccSound[max(MetronomeParams.metronomeSounds.indexOf(_metronomeBlock.polyAccSound2), 0)] = true;
      _selectedPolyUnaccSound[max(MetronomeParams.metronomeSounds.indexOf(_metronomeBlock.polyUnaccSound2), 0)] = true;
    } else {
      _selectedAccSound[max(MetronomeParams.metronomeSounds.indexOf(_metronomeBlock.accSound), 0)] = true;
      _selectedUnaccSound[max(MetronomeParams.metronomeSounds.indexOf(_metronomeBlock.unaccSound), 0)] = true;
      _selectedPolyAccSound[max(MetronomeParams.metronomeSounds.indexOf(_metronomeBlock.polyAccSound), 0)] = true;
      _selectedPolyUnaccSound[max(MetronomeParams.metronomeSounds.indexOf(_metronomeBlock.polyUnaccSound), 0)] = true;
    }
  }

  // Play the sound if the corresponding field is tapped
  void _playSound(SoundType soundType) async {
    AudioPlayer player = AudioPlayer();
    String filepath = '${MetronomeParams.metronomeSoundsPath}/';

    switch (soundType) {
      case SoundType.accented:
        filepath = '$filepath${MetronomeParams.metronomeSounds[_selectedAccSound.indexOf(true)].toLowerCase()}_a.wav';
      case SoundType.unaccented:
        filepath = '$filepath${MetronomeParams.metronomeSounds[_selectedUnaccSound.indexOf(true)].toLowerCase()}.wav';
      case SoundType.polyAccented:
        filepath =
            '$filepath${MetronomeParams.metronomeSounds[_selectedPolyAccSound.indexOf(true)].toLowerCase()}_a.wav';
      case SoundType.polyUnaccented:
        filepath =
            '$filepath${MetronomeParams.metronomeSounds[_selectedPolyUnaccSound.indexOf(true)].toLowerCase()}.wav';
    }

    // not sure if the volume parameter has effect here
    await player.play(AssetSource(filepath.substring(7)), mode: PlayerMode.lowLatency, volume: 4);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ParentSettingPage(
      title: widget.forSecondMetronome ? l10n.metronomeSetSoundsSecondary : l10n.metronomeSetSoundsPrimary,
      confirm: _onConfirm,
      reset: _reset,
      cancel: _onCancel,
      mustBeScrollable: true,
      customWidget: Padding(
        padding: const EdgeInsets.all(TIOMusicParams.edgeInset),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(l10n.metronomeBeatMain, style: TextStyle(color: ColorTheme.primary)),
                const SizedBox(width: TIOMusicParams.edgeInset),
                _buildToggleTable(l10n.metronomeAccented, _selectedAccSound, SoundType.accented),
                _buildToggleTable(l10n.metronomeUnaccented, _selectedUnaccSound, SoundType.unaccented),
              ],
            ),
            const SizedBox(height: TIOMusicParams.edgeInset),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(l10n.metronomeBeatPoly, style: TextStyle(color: ColorTheme.primary)),
                const SizedBox(width: TIOMusicParams.edgeInset),
                _buildToggleTable(l10n.metronomeAccented, _selectedPolyAccSound, SoundType.polyAccented),
                _buildToggleTable(l10n.metronomeUnaccented, _selectedPolyUnaccSound, SoundType.polyUnaccented),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTable(String titel, List<bool> selectedSound, SoundType soundType) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(titel, style: const TextStyle(color: ColorTheme.primary)),
        const SizedBox(height: TIOMusicParams.edgeInset),
        ToggleButtons(
          direction: Axis.vertical,
          onPressed: (index) {
            setState(() {
              for (int i = 0; i < selectedSound.length; i++) {
                selectedSound[i] = (i == index);
              }

              if (!widget.running) {
                _playSound(soundType);
              } else {
                String file = MetronomeParams.metronomeSounds[index].toLowerCase();
                MetronomeUtils.loadSound(widget.forSecondMetronome, soundType, file);
              }
            });
          },
          constraints: const BoxConstraints(minHeight: 40, minWidth: 100),
          isSelected: selectedSound,
          children: _sounds,
        ),
      ],
    );
  }

  void _onConfirm() {
    if (widget.forSecondMetronome) {
      _metronomeBlock.accSound2 = MetronomeParams.metronomeSounds[_selectedAccSound.indexOf(true)];
      _metronomeBlock.unaccSound2 = MetronomeParams.metronomeSounds[_selectedUnaccSound.indexOf(true)];
      _metronomeBlock.polyAccSound2 = MetronomeParams.metronomeSounds[_selectedPolyAccSound.indexOf(true)];
      _metronomeBlock.polyUnaccSound2 = MetronomeParams.metronomeSounds[_selectedPolyUnaccSound.indexOf(true)];
    } else {
      _metronomeBlock.accSound = MetronomeParams.metronomeSounds[_selectedAccSound.indexOf(true)];
      _metronomeBlock.unaccSound = MetronomeParams.metronomeSounds[_selectedUnaccSound.indexOf(true)];
      _metronomeBlock.polyAccSound = MetronomeParams.metronomeSounds[_selectedPolyAccSound.indexOf(true)];
      _metronomeBlock.polyUnaccSound = MetronomeParams.metronomeSounds[_selectedPolyUnaccSound.indexOf(true)];
    }

    FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    MetronomeUtils.loadSounds(_metronomeBlock);

    Navigator.pop(context);
  }

  void _reset() {
    _selectedAccSound.fillRange(0, MetronomeParams.metronomeSounds.length, false);
    _selectedUnaccSound.fillRange(0, MetronomeParams.metronomeSounds.length, false);
    _selectedPolyAccSound.fillRange(0, MetronomeParams.metronomeSounds.length, false);
    _selectedPolyUnaccSound.fillRange(0, MetronomeParams.metronomeSounds.length, false);

    if (widget.forSecondMetronome) {
      _selectedAccSound[max(MetronomeParams.metronomeSounds.indexOf(MetronomeParams.defaultAccSound2), 0)] = true;
      _selectedUnaccSound[max(MetronomeParams.metronomeSounds.indexOf(MetronomeParams.defaultUnaccSound2), 0)] = true;
      _selectedPolyAccSound[max(MetronomeParams.metronomeSounds.indexOf(MetronomeParams.defaultPolyAccSound2), 0)] =
          true;
      _selectedPolyUnaccSound[max(MetronomeParams.metronomeSounds.indexOf(MetronomeParams.defaultPolyUnaccSound2), 0)] =
          true;
    } else {
      _selectedAccSound[max(MetronomeParams.metronomeSounds.indexOf(MetronomeParams.defaultAccSound), 0)] = true;
      _selectedUnaccSound[max(MetronomeParams.metronomeSounds.indexOf(MetronomeParams.defaultUnaccSound), 0)] = true;
      _selectedPolyAccSound[max(MetronomeParams.metronomeSounds.indexOf(MetronomeParams.defaultPolyAccSound), 0)] =
          true;
      _selectedPolyUnaccSound[max(MetronomeParams.metronomeSounds.indexOf(MetronomeParams.defaultPolyUnaccSound), 0)] =
          true;
    }

    MetronomeUtils.loadSound(widget.forSecondMetronome, SoundType.accented, MetronomeParams.defaultAccSound);
    MetronomeUtils.loadSound(widget.forSecondMetronome, SoundType.unaccented, MetronomeParams.defaultUnaccSound);
    MetronomeUtils.loadSound(widget.forSecondMetronome, SoundType.polyAccented, MetronomeParams.defaultPolyAccSound);
    MetronomeUtils.loadSound(
      widget.forSecondMetronome,
      SoundType.polyUnaccented,
      MetronomeParams.defaultPolyUnaccSound,
    );

    setState(() {});
  }

  void _onCancel() {
    MetronomeUtils.loadSounds(_metronomeBlock);
    Navigator.pop(context);
  }
}
