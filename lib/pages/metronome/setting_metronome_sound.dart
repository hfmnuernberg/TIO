import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/metronome_sound.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/util/l10n/metronome_sound_extension.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/metronome/metronome_utils.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';

enum SoundType { accented, unaccented, polyAccented, polyUnaccented }

class SetMetronomeSound extends StatefulWidget {
  final bool running;
  final bool forSecondMetronome;
  const SetMetronomeSound({super.key, required this.running, this.forSecondMetronome = false});

  @override
  State<SetMetronomeSound> createState() => _SetMetronomeSoundState();
}

class _SetMetronomeSoundState extends State<SetMetronomeSound> {
  late AudioSystem as;
  late FileSystem fs;

  late MetronomeBlock metronomeBlock;

  final List<bool> selectedAccSound = List<bool>.filled(MetronomeSound.values.length, false);
  final List<bool> selectedUnaccSound = List<bool>.filled(MetronomeSound.values.length, false);
  final List<bool> selectedPolyAccSound = List<bool>.filled(MetronomeSound.values.length, false);
  final List<bool> selectedPolyUnaccSound = List<bool>.filled(MetronomeSound.values.length, false);

  @override
  void initState() {
    super.initState();

    as = context.read<AudioSystem>();
    fs = context.read<FileSystem>();

    metronomeBlock = Provider.of<ProjectBlock>(context, listen: false) as MetronomeBlock;

    if (widget.forSecondMetronome) {
      selectedAccSound[max(MetronomeSound.values.indexOf(MetronomeSound.fromFilename(metronomeBlock.accSound2)), 0)] =
          true;
      selectedUnaccSound[max(
            MetronomeSound.values.indexOf(MetronomeSound.fromFilename(metronomeBlock.unaccSound2)),
            0,
          )] =
          true;
      selectedPolyAccSound[max(
            MetronomeSound.values.indexOf(MetronomeSound.fromFilename(metronomeBlock.polyAccSound2)),
            0,
          )] =
          true;
      selectedPolyUnaccSound[max(
            MetronomeSound.values.indexOf(MetronomeSound.fromFilename(metronomeBlock.polyUnaccSound2)),
            0,
          )] =
          true;
    } else {
      selectedAccSound[max(MetronomeSound.values.indexOf(MetronomeSound.fromFilename(metronomeBlock.accSound)), 0)] =
          true;
      selectedUnaccSound[max(
            MetronomeSound.values.indexOf(MetronomeSound.fromFilename(metronomeBlock.unaccSound)),
            0,
          )] =
          true;
      selectedPolyAccSound[max(
            MetronomeSound.values.indexOf(MetronomeSound.fromFilename(metronomeBlock.polyAccSound)),
            0,
          )] =
          true;
      selectedPolyUnaccSound[max(
            MetronomeSound.values.indexOf(MetronomeSound.fromFilename(metronomeBlock.polyUnaccSound)),
            0,
          )] =
          true;
    }
  }

  // Play the sound if the corresponding field is tapped
  void playSound(SoundType soundType) async {
    AudioPlayer player = AudioPlayer();

    String getFilename(int sound) => MetronomeSound.values[sound].filename;

    String filepath = switch (soundType) {
      SoundType.accented => '${MetronomeSound.fromFilename(getFilename(selectedAccSound.indexOf(true))).file}_a.wav',
      SoundType.unaccented => '${MetronomeSound.fromFilename(getFilename(selectedUnaccSound.indexOf(true))).file}.wav',
      SoundType.polyAccented =>
        '${MetronomeSound.fromFilename(getFilename(selectedPolyAccSound.indexOf(true))).file}_a.wav',
      SoundType.polyUnaccented =>
        '${MetronomeSound.fromFilename(getFilename(selectedPolyUnaccSound.indexOf(true))).file}.wav',
    };

    // not sure if the volume parameter has effect here
    await player.play(AssetSource(filepath.substring(7)), mode: PlayerMode.lowLatency, volume: 4);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ParentSettingPage(
      title: widget.forSecondMetronome ? l10n.metronomeSetSoundsSecondary : l10n.metronomeSetSoundsPrimary,
      confirm: handleConfirm,
      reset: handleReset,
      cancel: handleCancel,
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
                buildToggleTable(l10n.metronomeAccented, selectedAccSound, SoundType.accented),
                buildToggleTable(l10n.metronomeUnaccented, selectedUnaccSound, SoundType.unaccented),
              ],
            ),
            const SizedBox(height: TIOMusicParams.edgeInset),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(l10n.metronomeBeatPoly, style: TextStyle(color: ColorTheme.primary)),
                const SizedBox(width: TIOMusicParams.edgeInset),
                buildToggleTable(l10n.metronomeAccented, selectedPolyAccSound, SoundType.polyAccented),
                buildToggleTable(l10n.metronomeUnaccented, selectedPolyUnaccSound, SoundType.polyUnaccented),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildToggleTable(String titel, List<bool> selectedSound, SoundType soundType) {
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
                playSound(soundType);
              } else {
                String file = MetronomeSound.values[index].file;
                MetronomeUtils.loadSound(as, fs, widget.forSecondMetronome, soundType, file);
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

  Future<void> handleConfirm() async {
    if (widget.forSecondMetronome) {
      metronomeBlock.accSound2 = MetronomeSound.values[selectedAccSound.indexOf(true)].filename;
      metronomeBlock.unaccSound2 = MetronomeSound.values[selectedUnaccSound.indexOf(true)].filename;
      metronomeBlock.polyAccSound2 = MetronomeSound.values[selectedPolyAccSound.indexOf(true)].filename;
      metronomeBlock.polyUnaccSound2 = MetronomeSound.values[selectedPolyUnaccSound.indexOf(true)].filename;
    } else {
      metronomeBlock.accSound = MetronomeSound.values[selectedAccSound.indexOf(true)].filename;
      metronomeBlock.unaccSound = MetronomeSound.values[selectedUnaccSound.indexOf(true)].filename;
      metronomeBlock.polyAccSound = MetronomeSound.values[selectedPolyAccSound.indexOf(true)].filename;
      metronomeBlock.polyUnaccSound = MetronomeSound.values[selectedPolyUnaccSound.indexOf(true)].filename;
    }

    await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
    MetronomeUtils.loadSounds(as, fs, metronomeBlock);

    if (!mounted) return;
    Navigator.pop(context);
  }

  void handleReset() {
    selectedAccSound.fillRange(0, MetronomeSound.values.length, false);
    selectedUnaccSound.fillRange(0, MetronomeSound.values.length, false);
    selectedPolyAccSound.fillRange(0, MetronomeSound.values.length, false);
    selectedPolyUnaccSound.fillRange(0, MetronomeSound.values.length, false);

    if (widget.forSecondMetronome) {
      selectedAccSound[max(MetronomeSound.values.indexOf(MetronomeSound.fromFilename(defaultMetronomeAccSound2)), 0)] =
          true;
      selectedUnaccSound[max(
            MetronomeSound.values.indexOf(MetronomeSound.fromFilename(defaultMetronomeUnaccSound2)),
            0,
          )] =
          true;
      selectedPolyAccSound[max(
            MetronomeSound.values.indexOf(MetronomeSound.fromFilename(defaultMetronomePolyAccSound2)),
            0,
          )] =
          true;
      selectedPolyUnaccSound[max(
            MetronomeSound.values.indexOf(MetronomeSound.fromFilename(defaultMetronomePolyUnaccSound2)),
            0,
          )] =
          true;
    } else {
      selectedAccSound[max(MetronomeSound.values.indexOf(MetronomeSound.fromFilename(defaultMetronomeAccSound)), 0)] =
          true;
      selectedUnaccSound[max(
            MetronomeSound.values.indexOf(MetronomeSound.fromFilename(defaultMetronomeUnaccSound)),
            0,
          )] =
          true;
      selectedPolyAccSound[max(
            MetronomeSound.values.indexOf(MetronomeSound.fromFilename(defaultMetronomePolyAccSound)),
            0,
          )] =
          true;
      selectedPolyUnaccSound[max(
            MetronomeSound.values.indexOf(MetronomeSound.fromFilename(defaultMetronomePolyUnaccSound)),
            0,
          )] =
          true;
    }

    MetronomeUtils.loadSound(as, fs, widget.forSecondMetronome, SoundType.accented, defaultMetronomeAccSound);
    MetronomeUtils.loadSound(as, fs, widget.forSecondMetronome, SoundType.unaccented, defaultMetronomeUnaccSound);
    MetronomeUtils.loadSound(as, fs, widget.forSecondMetronome, SoundType.polyAccented, defaultMetronomePolyAccSound);
    MetronomeUtils.loadSound(
      as,
      fs,
      widget.forSecondMetronome,
      SoundType.polyUnaccented,
      defaultMetronomePolyUnaccSound,
    );

    setState(() {});
  }

  void handleCancel() {
    MetronomeUtils.loadSounds(as, fs, metronomeBlock);
    Navigator.pop(context);
  }
}
