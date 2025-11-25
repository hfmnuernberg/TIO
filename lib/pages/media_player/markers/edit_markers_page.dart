import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/media_player/markers/markers.dart';
import 'package:tiomusic/pages/media_player/markers/media_time_text.dart';
import 'package:tiomusic/pages/media_player/markers/waveform_window_labels.dart';
import 'package:tiomusic/pages/media_player/markers/edit_markers_controls.dart';
import 'package:tiomusic/pages/media_player/waveform/waveform.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/domain/audio/player.dart';

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
  final double _waveFormHeight = 200;
  double _playbackPosition = 0;
  double _viewStart = 0;
  double _viewEnd = 1;
  Duration _positionDuration = Duration.zero;
  double? _selectedMarkerPosition;
  bool get _hasSelectedMarker => _selectedMarkerPosition != null;
  double _paintedWaveWidth = 0;

  late final OnPlaybackPositionChange _playbackListener;
  late bool _originalRepeat;

  @override
  void initState() {
    super.initState();

    _originalRepeat = player.repeat;
    player.setRepeat(false);

    block.markerPositions.forEach(_markerPositions.add);

    _positionDuration = player.fileDuration * _playbackPosition;
    _syncPlayerMarkers();

    _playbackListener = _handlePlaybackPositionChange;
    player.addOnPlaybackPositionChangeListener(_playbackListener);
  }

  @override
  void dispose() {
    player.setRepeat(_originalRepeat);
    player.markers.positions = block.markerPositions;
    player.removeOnPlaybackPositionChangeListener(_playbackListener);
    super.dispose();
  }

  void _syncPlayerMarkers() => player.markers.positions = _markerPositions;

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
    _syncPlayerMarkers();
    setState(() {});
  }

  void _removeAllMarkers() {
    _markerPositions.clear();
    _selectedMarkerPosition = null;
    _syncPlayerMarkers();
    setState(() {});
  }

  void _handleWaveformPositionChange(double snappedRelativePosition) {
    final double? markerPosition = _findMarkerNear(snappedRelativePosition);
    _seekToPosition(snappedRelativePosition, updateSelectedMarker: true, selectedMarkerPosition: markerPosition);
  }

  Future<void> _seekToPosition(
    double position, {
    bool updateSelectedMarker = false,
    double? selectedMarkerPosition,
  }) async {
    final clamped = position.clamp(0.0, 1.0);

    setState(() {
      _updateUiForPlaybackPosition(clamped);
      if (updateSelectedMarker) _selectedMarkerPosition = selectedMarkerPosition;
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
    final int binCount = widget.rmsValues.length;
    final double oneBinRelative = 1.0 / (binCount - 1);

    for (final pos in _markerPositions) {
      if ((snappedRelativePosition - pos).abs() <= oneBinRelative) return pos;
    }

    return null;
  }

  void _addNewMarker() {
    _markerPositions.add(_playbackPosition);
    _syncPlayerMarkers();
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
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          WaveformWindowLabels(fileDuration: player.fileDuration, viewStart: _viewStart, viewEnd: _viewEnd),
          const SizedBox(height: 4),
          SizedBox(
            height: _waveFormHeight,
            child: Stack(
              children: [
                Waveform(
                  rmsValues: widget.rmsValues,
                  playbackPosition: _playbackPosition,
                  rangeStart: block.rangeStart,
                  rangeEnd: block.rangeEnd,
                  height: _waveFormHeight,
                  onPositionChange: _handleWaveformPositionChange,
                  onPaintedWidthChange: (width) {
                    if (width == _paintedWaveWidth) return;
                    setState(() => _paintedWaveWidth = width);
                  },
                  onViewWindowChange: (start, end) => setState(() {
                    _viewStart = start;
                    _viewEnd = end;
                  }),
                ),
                Markers(
                  rmsValues: widget.rmsValues,
                  paintedWidth: _paintedWaveWidth,
                  waveFormHeight: _waveFormHeight,
                  markerPositions: _markerPositions,
                  selectedMarkerPosition: _selectedMarkerPosition,
                  onTap: (position) =>
                      _seekToPosition(position, updateSelectedMarker: true, selectedMarkerPosition: position),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          MediaTimeText(duration: _positionDuration),
          const SizedBox(height: 8),
          MarkerEditControls(
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
