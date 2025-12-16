import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/media_player/markers/edit_markers_controls.dart';
import 'package:tiomusic/pages/media_player/markers/waveform.dart';
import 'package:tiomusic/pages/media_player/markers/zoom_rms_helper.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/domain/audio/player.dart';
import 'package:tiomusic/util/tutorial/tutorial_util.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class EditMarkersPage extends StatefulWidget {
  final MediaPlayerBlock mediaPlayerBlock;
  final Float32List rmsValues;
  final Player player;

  const EditMarkersPage({super.key, required this.mediaPlayerBlock, required this.rmsValues, required this.player});

  @override
  State<EditMarkersPage> createState() => _EditMarkersPageState();
}

class _EditMarkersPageState extends State<EditMarkersPage> {
  MediaPlayerBlock get block => widget.mediaPlayerBlock;
  Player get player => widget.player;
  final List<double> markerPositions = List.empty(growable: true);
  double playbackPosition = 0;
  double? selectedMarkerPosition;
  bool get hasSelectedMarker => selectedMarkerPosition != null;

  late final OnPlaybackPositionChange playbackListener;
  late bool originalRepeat;
  late Float32List rmsValues;
  late int targetVisibleBins;
  late ProjectRepository projectRepo;

  final Tutorial tutorial = Tutorial();
  final GlobalKey keyWaveform = GlobalKey();
  final GlobalKey keyAddRemove = GlobalKey();

  @override
  void initState() {
    super.initState();

    projectRepo = context.read<ProjectRepository>();
    originalRepeat = player.repeat;
    player.setRepeat(false);

    block.markerPositions.forEach(markerPositions.add);
    player.markers.positions = markerPositions;

    rmsValues = widget.rmsValues;
    targetVisibleBins = widget.rmsValues.length;

    playbackListener = handlePlaybackPositionChange;
    player.addOnPlaybackPositionChangeListener(playbackListener);

    showTutorial();
  }

  @override
  void dispose() {
    tutorial.dispose();
    player.setRepeat(originalRepeat);
    player.markers.positions = block.markerPositions;
    player.removeOnPlaybackPositionChangeListener(playbackListener);
    super.dispose();
  }

  void showTutorial() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final projectLibrary = context.read<ProjectLibrary>();

      if (projectLibrary.showMediaPlayerEditMarkersTutorial) {
        projectLibrary.showMediaPlayerEditMarkersTutorial = false;
        await context.read<ProjectRepository>().saveLibrary(projectLibrary);
        createTutorial();
        if (!mounted) return;
        tutorial.show(context);
      }
    });
  }

  void createTutorial() {
    final l10n = context.l10n;
    var targets = <CustomTargetFocus>[
      CustomTargetFocus(
        keyWaveform,
        l10n.mediaPlayerEditMarkersTutorialWaveform,
        alignText: ContentAlign.bottom,
        pointingDirection: PointingDirection.up,
        shape: ShapeLightFocus.RRect,
      ),
      CustomTargetFocus(
        keyAddRemove,
        l10n.mediaPlayerEditMarkersTutorialAddRemove,
        alignText: ContentAlign.top,
        pointingDirection: PointingDirection.down,
        pointerOffset: 68,
        shape: ShapeLightFocus.Circle,
      ),
    ];

    tutorial.create(targets.map((e) => e.targetFocus).toList(), () async {
      context.read<ProjectLibrary>().showMediaPlayerEditMarkersTutorial = false;
      await projectRepo.saveLibrary(context.read<ProjectLibrary>());
    }, context);
  }

  void updateUiForPlaybackPosition(double position) {
    final clamped = position.clamp(0.0, 1.0);
    playbackPosition = clamped;
  }

  void handlePlaybackPositionChange(double position) {
    if (!mounted) return;
    setState(() => updateUiForPlaybackPosition(position));
  }

  void removeSelectedMarker() {
    if (selectedMarkerPosition != null) {
      markerPositions.removeWhere((pos) => pos == selectedMarkerPosition);
      selectedMarkerPosition = null;
    }
    player.markers.positions = markerPositions;
    setState(() {});
  }

  void removeAllMarkers() {
    markerPositions.clear();
    selectedMarkerPosition = null;
    player.markers.positions = markerPositions;
    setState(() {});
  }

  void handlePositionChange(double snappedRelativePosition) => seekToPosition(
    snappedRelativePosition,
    updateMarker: true,
    markerPosition: findMarkerNear(snappedRelativePosition),
  );

  Future<void> handleZoomChanged(double viewStart, double viewEnd) async {
    final Float32List? newRms = await recalculateRmsForZoom(
      player: player,
      targetVisibleBins: targetVisibleBins,
      viewStart: viewStart,
      viewEnd: viewEnd,
      currentBinCount: rmsValues.length,
    );

    if (!mounted || newRms == null) return;
    setState(() => rmsValues = newRms);
  }

  Future<void> seekToPosition(double position, {bool updateMarker = false, double? markerPosition}) async {
    final clamped = position.clamp(0.0, 1.0);

    setState(() {
      updateUiForPlaybackPosition(clamped);
      if (updateMarker) selectedMarkerPosition = markerPosition;
    });

    await player.setPlaybackPosition(clamped);
  }

  Future<void> togglePlaying() async {
    if (player.isPlaying) {
      await player.stop();
    } else {
      await player.setPlaybackPosition(playbackPosition.clamp(0, 1));
      await player.start();
    }
    if (!mounted) return;
    setState(() {});
  }

  double? findMarkerNear(double snappedRelativePosition) {
    final int binCount = rmsValues.length;
    final double oneBinRelative = 1.0 / (binCount - 1);

    for (final pos in markerPositions) {
      if ((snappedRelativePosition - pos).abs() <= oneBinRelative) return pos;
    }

    return null;
  }

  void addNewMarker() {
    markerPositions.add(playbackPosition);
    player.markers.positions = markerPositions;
    setState(() {});
  }

  Future<void> onConfirm() async {
    block.markerPositions.clear();
    markerPositions.forEach(block.markerPositions.add);

    await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ParentSettingPage(
      title: l10n.mediaPlayerEditMarkers,
      confirm: onConfirm,
      reset: removeAllMarkers,
      customWidget: Column(
        children: [
          Waveform(
            key: keyWaveform,
            rmsValues: rmsValues,
            position: playbackPosition,
            rangeStart: block.rangeStart,
            rangeEnd: block.rangeEnd,
            fileDuration: player.fileDuration,
            markerPositions: markerPositions,
            selectedMarkerPosition: selectedMarkerPosition,
            onPositionChange: handlePositionChange,
            onZoomChanged: handleZoomChanged,
          ),
          MarkerEditControls(
            keyAddRemove: keyAddRemove,
            isPlaying: player.isPlaying,
            hasSelectedMarker: hasSelectedMarker,
            onTogglePlaying: togglePlaying,
            onRemoveSelectedMarker: removeSelectedMarker,
            onAddMarker: addNewMarker,
          ),
        ],
      ),
    );
  }
}
