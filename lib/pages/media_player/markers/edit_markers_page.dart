import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/media_player/markers/media_time_text.dart';
import 'package:tiomusic/pages/media_player/markers/edit_markers_controls.dart';
import 'package:tiomusic/pages/media_player/markers/waveform.dart';
import 'package:tiomusic/pages/media_player/markers/zoom_rms_helper.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/domain/audio/player.dart';
import 'package:tiomusic/util/tutorial_util.dart';
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
  final List<double> _markerPositions = List.empty(growable: true);
  double _playbackPosition = 0;
  Duration _positionDuration = Duration.zero;
  double? _selectedMarkerPosition;
  bool get _hasSelectedMarker => _selectedMarkerPosition != null;

  late final OnPlaybackPositionChange _playbackListener;
  late bool _originalRepeat;
  late Float32List _rmsValues;
  late int _targetVisibleBins;
  late ProjectRepository _projectRepo;

  final Tutorial _tutorial = Tutorial();
  final GlobalKey _keyWaveform = GlobalKey();
  final GlobalKey _keyAddRemove = GlobalKey();

  @override
  void initState() {
    super.initState();

    _projectRepo = context.read<ProjectRepository>();
    _originalRepeat = player.repeat;
    player.setRepeat(false);

    block.markerPositions.forEach(_markerPositions.add);
    _positionDuration = player.fileDuration * _playbackPosition;
    player.markers.positions = _markerPositions;

    _rmsValues = widget.rmsValues;
    _targetVisibleBins = widget.rmsValues.length;

    _playbackListener = _handlePlaybackPositionChange;
    player.addOnPlaybackPositionChangeListener(_playbackListener);

    _showTutorial();
  }

  @override
  void dispose() {
    _tutorial.dispose();
    player.setRepeat(_originalRepeat);
    player.markers.positions = block.markerPositions;
    player.removeOnPlaybackPositionChangeListener(_playbackListener);
    super.dispose();
  }

  void _showTutorial() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final projectLibrary = context.read<ProjectLibrary>();

      if (projectLibrary.showMediaPlayerEditMarkersTutorial) {
        projectLibrary.showMediaPlayerEditMarkersTutorial = false;
        await context.read<ProjectRepository>().saveLibrary(projectLibrary);
        _createTutorial();
        if (!mounted) return;
        _tutorial.show(context);
      }
    });
  }

  void _createTutorial() {
    final l10n = context.l10n;
    var targets = <CustomTargetFocus>[
      CustomTargetFocus(
        _keyWaveform,
        l10n.mediaPlayerEditMarkersTutorialWaveform,
        alignText: ContentAlign.bottom,
        buttonsPosition: ButtonsPosition.bottom,
        pointingDirection: PointingDirection.up,
        shape: ShapeLightFocus.RRect,
      ),
      CustomTargetFocus(
        _keyAddRemove,
        l10n.mediaPlayerEditMarkersTutorialAddRemove,
        alignText: ContentAlign.top,
        buttonsPosition: ButtonsPosition.bottom,
        pointingDirection: PointingDirection.down,
        pointerOffset: 68,
        shape: ShapeLightFocus.Circle,
      ),
    ];

    _tutorial.create(targets.map((e) => e.targetFocus).toList(), () async {
      context.read<ProjectLibrary>().showMediaPlayerEditMarkersTutorial = false;
      await _projectRepo.saveLibrary(context.read<ProjectLibrary>());
    }, context);
  }

  void _updateUiForPlaybackPosition(double position) {
    final clamped = position.clamp(0.0, 1.0);
    _playbackPosition = clamped;
    _positionDuration = player.fileDuration * clamped;
  }

  void _handlePlaybackPositionChange(double position) {
    if (!mounted) return;
    setState(() => _updateUiForPlaybackPosition(position));
  }

  void _removeSelectedMarker() {
    if (_selectedMarkerPosition != null) {
      _markerPositions.removeWhere((pos) => pos == _selectedMarkerPosition);
      _selectedMarkerPosition = null;
    }
    player.markers.positions = _markerPositions;
    setState(() {});
  }

  void _removeAllMarkers() {
    _markerPositions.clear();
    _selectedMarkerPosition = null;
    player.markers.positions = _markerPositions;
    setState(() {});
  }

  void _handlePositionChange(double snappedRelativePosition) => _seekToPosition(
    snappedRelativePosition,
    updateMarker: true,
    markerPosition: _findMarkerNear(snappedRelativePosition),
  );

  Future<void> _handleZoomChanged(double viewStart, double viewEnd) async {
    final Float32List? newRms = await recalculateRmsForZoom(
      player: player,
      targetVisibleBins: _targetVisibleBins,
      viewStart: viewStart,
      viewEnd: viewEnd,
      currentBinCount: _rmsValues.length,
    );

    if (!mounted || newRms == null) return;
    setState(() => _rmsValues = newRms);
  }

  Future<void> _seekToPosition(double position, {bool updateMarker = false, double? markerPosition}) async {
    final clamped = position.clamp(0.0, 1.0);

    setState(() {
      _updateUiForPlaybackPosition(clamped);
      if (updateMarker) _selectedMarkerPosition = markerPosition;
    });

    await player.setPlaybackPosition(clamped);
  }

  Future<void> _togglePlaying() async {
    if (player.isPlaying) {
      await player.stop();
    } else {
      await player.setPlaybackPosition(_playbackPosition.clamp(0, 1));
      await player.start();
    }
    if (!mounted) return;
    setState(() {});
  }

  double? _findMarkerNear(double snappedRelativePosition) {
    final int binCount = _rmsValues.length;
    final double oneBinRelative = 1.0 / (binCount - 1);

    for (final pos in _markerPositions) {
      if ((snappedRelativePosition - pos).abs() <= oneBinRelative) return pos;
    }

    return null;
  }

  void _addNewMarker() {
    _markerPositions.add(_playbackPosition);
    player.markers.positions = _markerPositions;
    setState(() {});
  }

  Future<void> _onConfirm() async {
    block.markerPositions.clear();
    _markerPositions.forEach(block.markerPositions.add);

    await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ParentSettingPage(
      title: l10n.mediaPlayerEditMarkers,
      confirm: _onConfirm,
      reset: _removeAllMarkers,
      mustBeScrollable: true,
      customWidget: Column(
        children: [
          Waveform(
            key: _keyWaveform,
            rmsValues: _rmsValues,
            position: _playbackPosition,
            rangeStart: block.rangeStart,
            rangeEnd: block.rangeEnd,
            fileDuration: player.fileDuration,
            markerPositions: _markerPositions,
            selectedMarkerPosition: _selectedMarkerPosition,
            onPositionChange: _handlePositionChange,
            onZoomChanged: _handleZoomChanged,
          ),
          const SizedBox(height: 8),
          MediaTimeText(duration: _positionDuration),
          const SizedBox(height: 8),
          MarkerEditControls(
            keyAddRemove: _keyAddRemove,
            isPlaying: player.isPlaying,
            hasSelectedMarker: _hasSelectedMarker,
            onTogglePlaying: _togglePlaying,
            onRemoveSelectedMarker: _removeSelectedMarker,
            onAddMarker: _addNewMarker,
          ),
        ],
      ),
    );
  }
}
