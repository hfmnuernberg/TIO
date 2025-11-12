import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/domain/audio/player.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/media_player/markers/edit_markers_page.dart';
import 'package:tiomusic/pages/media_player/set_bpm.dart';
import 'package:tiomusic/pages/media_player/set_pitch.dart';
import 'package:tiomusic/pages/media_player/set_speed.dart';
import 'package:tiomusic/pages/media_player/set_trim.dart';
import 'package:tiomusic/pages/parent_tool/setting_volume_page.dart';
import 'package:tiomusic/pages/parent_tool/settings_tile.dart';
import 'package:tiomusic/services/project_repository.dart';

List<SettingsTile> buildMediaPlayerSettingsTiles({
  required BuildContext context,
  required MediaPlayerBlock block,
  required Player player,
  required Float32List rmsValues,
  required bool isLoading,
  required Future<void> Function() updateState,
  required VoidCallback requestRebuild,
}) {
  final l10n = context.l10n;

  String pitchSemitonesString(double semitones, String label) {
    if (semitones.abs() < 0.001) return '';
    return semitones > 0 ? '↑ $label' : '↓ $label';
  }

  return [
    SettingsTile(
      title: l10n.commonVolume,
      subtitle: l10n.formatNumber(block.volume),
      leadingIcon: Icons.volume_up,
      settingPage: SetVolume(
        initialVolume: block.volume,
        onConfirm: (vol) {
          block.volume = vol;
          player.setVolume(vol);
        },
        onChange: player.setVolume,
        onCancel: () => player.setVolume(block.volume),
      ),
      block: block,
      callOnReturn: (_) => requestRebuild(),
      inactive: isLoading,
    ),
    SettingsTile(
      title: l10n.commonBasicBeat,
      subtitle: '${block.bpm} ${l10n.commonBpm}',
      leadingIcon: Icons.touch_app_outlined,
      settingPage: const SetBPM(),
      block: block,
      callOnReturn: (_) => requestRebuild(),
    ),
    SettingsTile(
      title: l10n.mediaPlayerTrim,
      subtitle: '${(block.rangeStart * 100).round()}% → ${(block.rangeEnd * 100).round()}%',
      leadingIcon: 'assets/icons/arrow_range.svg',
      settingPage: SetTrim(
        initialStart: block.rangeStart,
        initialEnd: block.rangeEnd,
        rmsValues: rmsValues,
        fileDuration: player.fileDuration,
        onChange: player.setTrim,
        onConfirm: (start, end) async {
          block.rangeStart = start;
          block.rangeEnd = end;
          await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
          await player.setTrim(start, end);
        },
        onCancel: () async => player.setTrim(block.rangeStart, block.rangeEnd),
      ),
      block: block,
      callOnReturn: (_) => updateState(),
      inactive: isLoading,
    ),
    SettingsTile(
      title: l10n.mediaPlayerMarkers,
      subtitle: block.markerPositions.length.toString(),
      leadingIcon: Icons.arrow_drop_down,
      settingPage: EditMarkersPage(mediaPlayerBlock: block, rmsValues: rmsValues, player: player),
      block: block,
      callOnReturn: (_) {
        player.markers.positions = block.markerPositions;
        requestRebuild();
      },
      inactive: isLoading,
    ),
    SettingsTile(
      title: l10n.mediaPlayerPitch,
      subtitle: pitchSemitonesString(block.pitchSemitones, l10n.mediaPlayerSemitones(block.pitchSemitones.round())),
      leadingIcon: Icons.height,
      settingPage: SetPitch(
        initialPitch: block.pitchSemitones,
        onChange: player.setPitch,
        onConfirm: (pitch) async {
          block.pitchSemitones = pitch;
          await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
          await player.setPitch(pitch);
        },
        onCancel: () async => player.setPitch(block.pitchSemitones),
      ),
      block: block,
      callOnReturn: (_) => requestRebuild(),
      inactive: isLoading,
    ),
    SettingsTile(
      title: l10n.mediaPlayerSpeed,
      subtitle:
          '${l10n.formatNumber(block.speedFactor)}x / ${getBpmForSpeed(block.speedFactor, block.bpm)} ${l10n.commonBpm}',
      leadingIcon: Icons.speed,
      settingPage: SetSpeed(
        initialSpeed: block.speedFactor,
        baseBpm: block.bpm,
        onChangeSpeed: player.setSpeed,
        onChangeBpm: (bpm) async => player.setSpeed(getSpeedForBpm(bpm, block.bpm)),
        onConfirm: (speed) async {
          block.speedFactor = speed;
          await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
          await player.setSpeed(speed);
        },
        onCancel: () async => player.setSpeed(block.speedFactor),
      ),
      block: block,
      callOnReturn: (_) => requestRebuild(),
      inactive: isLoading,
    ),
  ];
}
