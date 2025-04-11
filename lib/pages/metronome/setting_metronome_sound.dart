// Setting page for metronome sounds

import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/metronome_sound.dart';
import 'package:tiomusic/models/metronome_sound_extension.dart';
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

  final List<bool> _selectedAccSound = List<bool>.filled(MetronomeSound.values.length, false);
  final List<bool> _selectedUnaccSound = List<bool>.filled(MetronomeSound.values.length, false);
  final List<bool> _selectedPolyAccSound = List<bool>.filled(MetronomeSound.values.length, false);
  final List<bool> _selectedPolyUnaccSound = List<bool>.filled(MetronomeSound.values.length, false);

  @override
  void initState() {
    super.initState();

    _metronomeBlock = Provider.of<ProjectBlock>(context, listen: false) as MetronomeBlock;

    if (widget.forSecondMetronome) {
      _selectedAccSound[max(MetronomeSound.values.indexOf(MetronomeSound.fromFilename(_metronomeBlock.accSound2)), 0)] =
          true;
      _selectedUnaccSound[max(
            MetronomeSound.values.indexOf(MetronomeSound.fromFilename(_metronomeBlock.unaccSound2)),
            0,
          )] =
          true;
      _selectedPolyAccSound[max(
            MetronomeSound.values.indexOf(MetronomeSound.fromFilename(_metronomeBlock.polyAccSound2)),
            0,
          )] =
          true;
      _selectedPolyUnaccSound[max(
            MetronomeSound.values.indexOf(MetronomeSound.fromFilename(_metronomeBlock.polyUnaccSound2)),
            0,
          )] =
          true;
    } else {
      _selectedAccSound[max(MetronomeSound.values.indexOf(MetronomeSound.fromFilename(_metronomeBlock.accSound)), 0)] =
          true;
      _selectedUnaccSound[max(
            MetronomeSound.values.indexOf(MetronomeSound.fromFilename(_metronomeBlock.unaccSound)),
            0,
          )] =
          true;
      _selectedPolyAccSound[max(
            MetronomeSound.values.indexOf(MetronomeSound.fromFilename(_metronomeBlock.polyAccSound)),
            0,
          )] =
          true;
      _selectedPolyUnaccSound[max(
            MetronomeSound.values.indexOf(MetronomeSound.fromFilename(_metronomeBlock.polyUnaccSound)),
            0,
          )] =
          true;
    }
  }

  // Play the sound if the corresponding field is tapped
  void _playSound(SoundType soundType) async {
    AudioPlayer player = AudioPlayer();

    String getFilename(int sound) => MetronomeSound.values[sound].filename;

    String filepath = switch (soundType) {
      SoundType.accented => '${MetronomeSound.fromFilename(getFilename(_selectedAccSound.indexOf(true))).file}_a.wav',
      SoundType.unaccented => '${MetronomeSound.fromFilename(getFilename(_selectedUnaccSound.indexOf(true))).file}.wav',
      SoundType.polyAccented =>
        '${MetronomeSound.fromFilename(getFilename(_selectedPolyAccSound.indexOf(true))).file}_a.wav',
      SoundType.polyUnaccented =>
        '${MetronomeSound.fromFilename(getFilename(_selectedPolyUnaccSound.indexOf(true))).file}.wav',
    };

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
                String file = MetronomeSound.values[index].file;
                MetronomeUtils.loadSound(widget.forSecondMetronome, soundType, file);
              }
            });
          },
          constraints: const BoxConstraints(minHeight: 40, minWidth: 100),
          isSelected: selectedSound,
          children: List<Widget>.generate(
            MetronomeSound.values.length,
            (index) => Text(
              MetronomeSound.values[index].getLabel(context.l10n),
              style: const TextStyle(color: ColorTheme.primary),
            ),
            growable: false,
          ),
        ),
      ],
    );
  }

  void _onConfirm() {
    if (widget.forSecondMetronome) {
      _metronomeBlock.accSound2 = MetronomeSound.values[_selectedAccSound.indexOf(true)].filename;
      _metronomeBlock.unaccSound2 = MetronomeSound.values[_selectedUnaccSound.indexOf(true)].filename;
      _metronomeBlock.polyAccSound2 = MetronomeSound.values[_selectedPolyAccSound.indexOf(true)].filename;
      _metronomeBlock.polyUnaccSound2 = MetronomeSound.values[_selectedPolyUnaccSound.indexOf(true)].filename;
    } else {
      _metronomeBlock.accSound = MetronomeSound.values[_selectedAccSound.indexOf(true)].filename;
      _metronomeBlock.unaccSound = MetronomeSound.values[_selectedUnaccSound.indexOf(true)].filename;
      _metronomeBlock.polyAccSound = MetronomeSound.values[_selectedPolyAccSound.indexOf(true)].filename;
      _metronomeBlock.polyUnaccSound = MetronomeSound.values[_selectedPolyUnaccSound.indexOf(true)].filename;
    }

    FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    MetronomeUtils.loadSounds(_metronomeBlock);

    Navigator.pop(context);
  }

  void _reset() {
    _selectedAccSound.fillRange(0, MetronomeSound.values.length, false);
    _selectedUnaccSound.fillRange(0, MetronomeSound.values.length, false);
    _selectedPolyAccSound.fillRange(0, MetronomeSound.values.length, false);
    _selectedPolyUnaccSound.fillRange(0, MetronomeSound.values.length, false);

    if (widget.forSecondMetronome) {
      _selectedAccSound[max(MetronomeSound.values.indexOf(MetronomeSound.fromFilename(defaultMetronomeAccSound2)), 0)] =
          true;
      _selectedUnaccSound[max(
            MetronomeSound.values.indexOf(MetronomeSound.fromFilename(defaultMetronomeUnaccSound2)),
            0,
          )] =
          true;
      _selectedPolyAccSound[max(
            MetronomeSound.values.indexOf(MetronomeSound.fromFilename(defaultMetronomePolyAccSound2)),
            0,
          )] =
          true;
      _selectedPolyUnaccSound[max(
            MetronomeSound.values.indexOf(MetronomeSound.fromFilename(defaultMetronomePolyUnaccSound2)),
            0,
          )] =
          true;
    } else {
      _selectedAccSound[max(MetronomeSound.values.indexOf(MetronomeSound.fromFilename(defaultMetronomeAccSound)), 0)] =
          true;
      _selectedUnaccSound[max(
            MetronomeSound.values.indexOf(MetronomeSound.fromFilename(defaultMetronomeUnaccSound)),
            0,
          )] =
          true;
      _selectedPolyAccSound[max(
            MetronomeSound.values.indexOf(MetronomeSound.fromFilename(defaultMetronomePolyAccSound)),
            0,
          )] =
          true;
      _selectedPolyUnaccSound[max(
            MetronomeSound.values.indexOf(MetronomeSound.fromFilename(defaultMetronomePolyUnaccSound)),
            0,
          )] =
          true;
    }

    MetronomeUtils.loadSound(widget.forSecondMetronome, SoundType.accented, defaultMetronomeAccSound);
    MetronomeUtils.loadSound(widget.forSecondMetronome, SoundType.unaccented, defaultMetronomeUnaccSound);
    MetronomeUtils.loadSound(widget.forSecondMetronome, SoundType.polyAccented, defaultMetronomePolyAccSound);
    MetronomeUtils.loadSound(widget.forSecondMetronome, SoundType.polyUnaccented, defaultMetronomePolyUnaccSound);

    setState(() {});
  }

  void _onCancel() {
    MetronomeUtils.loadSounds(_metronomeBlock);
    Navigator.pop(context);
  }
}
