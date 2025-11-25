import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/media_player/markers/markers.dart';
import 'package:tiomusic/pages/media_player/waveform/waveform.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/domain/audio/player.dart';
import 'package:tiomusic/widgets/on_off_button.dart';

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
  double _sliderValue = 0;
  Duration _positionDuration = Duration.zero;
  double? _selectedMarkerPosition;
  bool get _hasSelectedMarker => _selectedMarkerPosition != null;
  bool _wasPlayingBeforeSliderDrag = false;
  double _paintedWaveWidth = 0;

  late final OnPlaybackPositionChange _playbackListener;
  late bool _originalRepeat;

  @override
  void initState() {
    super.initState();

    _originalRepeat = player.repeat;
    player.setRepeat(false);

    block.markerPositions.forEach(_markerPositions.add);

    _positionDuration = player.fileDuration * _sliderValue;
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

  void _updateUiForPosition(double position) {
    final clamped = position.clamp(0.0, 1.0);
    _sliderValue = clamped;
    _positionDuration = player.fileDuration * clamped;
  }

  void _handlePlaybackPositionChange(double position) {
    if (!mounted) return;
    setState(() => _updateUiForPosition(position));
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
      _updateUiForPosition(clamped);
      if (updateSelectedMarker) _selectedMarkerPosition = selectedMarkerPosition;
    });

    await player.setPlaybackPosition(clamped);
  }

  Future<void> _togglePlaying() async {
    if (player.isPlaying) {
      await player.stop();
    } else {
      await player.setPlaybackPosition(_sliderValue.clamp(0, 1));
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
    _markerPositions.add(_sliderValue);
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
          const SizedBox(height: TIOMusicParams.edgeInset),
          SizedBox(
            height: _waveFormHeight,
            child: Stack(
              children: [
                Waveform(
                  rmsValues: widget.rmsValues,
                  playbackPosition: _sliderValue,
                  rangeStart: block.rangeStart,
                  rangeEnd: block.rangeEnd,
                  height: _waveFormHeight,
                  onPositionChange: _handleWaveformPositionChange,
                  onPaintedWidthChange: (width) {
                    if (width == _paintedWaveWidth) return;
                    setState(() => _paintedWaveWidth = width);
                  },
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
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 6),
            child: Text(
              l10n.formatDurationWithMillis(_positionDuration),
              style: const TextStyle(color: ColorTheme.primary),
            ),
          ),
          Slider(
            value: _sliderValue,
            inactiveColor: ColorTheme.primary80,
            divisions: 1000,
            onChangeStart: (startValue) async {
              _wasPlayingBeforeSliderDrag = player.isPlaying;
              if (_wasPlayingBeforeSliderDrag) {
                await player.stop();
                if (!mounted) return;
                setState(() {});
              }
            },
            onChanged: (newValue) => setState(() => _updateUiForPosition(newValue)),
            onChangeEnd: (newValue) async {
              await _seekToPosition(newValue);
              if (_wasPlayingBeforeSliderDrag) {
                await player.start();
                if (!mounted) return;
                setState(() {});
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const PlaceholderButton(buttonSize: TIOMusicParams.sizeSmallButtons),
                OnOffButton(
                  isActive: player.isPlaying,
                  onTap: _togglePlaying,
                  buttonSize: TIOMusicParams.sizeBigButtons,
                  iconOff: Icons.play_arrow,
                  iconOn: TIOMusicParams.pauseIcon,
                  tooltipOff: context.l10n.mediaPlayerPause,
                  tooltipOn: context.l10n.mediaPlayerPlay,
                ),
                OnOffButton(
                  isActive: _hasSelectedMarker,
                  onTap: _hasSelectedMarker ? _removeSelectedMarker : _addNewMarker,
                  buttonSize: TIOMusicParams.sizeSmallButtons,
                  iconOff: _hasSelectedMarker ? Icons.delete_outlined : Icons.add,
                  iconOn: _hasSelectedMarker ? Icons.delete_outlined : Icons.add,
                  tooltipOff: _hasSelectedMarker ? l10n.mediaPlayerRemoveMarker : l10n.mediaPlayerAddMarker,
                  tooltipOn: _hasSelectedMarker ? l10n.mediaPlayerRemoveMarker : l10n.mediaPlayerAddMarker,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
