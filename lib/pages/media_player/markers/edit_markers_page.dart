import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/media_player/markers/markers.dart';
import 'package:tiomusic/pages/media_player/markers/setting_button.dart';
import 'package:tiomusic/pages/media_player/waveform_visualizer.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';

class EditMarkersPage extends StatefulWidget {
  final MediaPlayerBlock mediaPlayerBlock;
  final Duration fileDuration;
  final Float32List rmsValues;

  const EditMarkersPage({
    super.key,
    required this.mediaPlayerBlock,
    required this.fileDuration,
    required this.rmsValues,
  });

  @override
  State<EditMarkersPage> createState() => _EditMarkersPageState();
}

class _EditMarkersPageState extends State<EditMarkersPage> {
  final GlobalKey _waveKey = GlobalKey();
  late WaveformVisualizer _waveformVisualizer;
  double _waveFormWidth = 0;
  final double _waveFormHeight = 200;
  double _sliderValue = 0;

  Duration _positionDuration = Duration.zero;

  double? _selectedMarkerPosition;

  final List<double> _markerPositions = List.empty(growable: true);

  double get _paintedWaveWidth {
    final buildContext = _waveKey.currentContext;
    if (buildContext == null) return _waveFormWidth;
    final renderObject = buildContext.findRenderObject();
    if (renderObject is RenderBox) return renderObject.size.width;
    return _waveFormWidth;
  }

  @override
  void initState() {
    super.initState();

    widget.mediaPlayerBlock.markerPositions.forEach(_markerPositions.add);

    _positionDuration = widget.fileDuration * _sliderValue;

    _waveformVisualizer = WaveformVisualizer.singleView(0, widget.rmsValues, true);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _waveFormWidth = MediaQuery.of(context).size.width - (TIOMusicParams.edgeInset * 2);

      setState(() => _waveformVisualizer = WaveformVisualizer.singleView(0, widget.rmsValues, true));
    });
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(TIOMusicParams.edgeInset, 0, TIOMusicParams.edgeInset, 0),
                  child: GestureDetector(
                    onTapDown: _onWaveTap,
                    child: SizedBox(
                      width: double.infinity,
                      height: _waveFormHeight,
                      child: CustomPaint(key: _waveKey, painter: _waveformVisualizer),
                    ),
                  ),
                ),

                Markers(
                  rmsValues: widget.rmsValues,
                  paintedWidth: _paintedWaveWidth,
                  waveFormHeight: _waveFormHeight,
                  markerPositions: _markerPositions,
                  selectedMarkerPosition: _selectedMarkerPosition,
                  onTap: (position) {
                    setState(() {
                      _sliderValue = position;
                      _waveformVisualizer = WaveformVisualizer.singleView(_sliderValue, widget.rmsValues, true);
                      _selectedMarkerPosition = position;
                    });
                  },
                ),
              ],
            ),
          ),
          Slider(
            value: _sliderValue,
            inactiveColor: ColorTheme.primary80,
            divisions: 1000, // how many individual values, only showing labels when division is not null
            label: l10n.formatDurationWithMillis(_positionDuration),
            onChanged: (newValue) {
              setState(() {
                _sliderValue = newValue;
                _waveformVisualizer = WaveformVisualizer.singleView(newValue, widget.rmsValues, true);
                _positionDuration = widget.fileDuration * _sliderValue;

                if (_selectedMarkerPosition != null) {
                  for (int i = 0; i < _markerPositions.length; i++) {
                    if (_markerPositions[i] == _selectedMarkerPosition) {
                      _markerPositions[i] = _sliderValue;
                      _selectedMarkerPosition = _sliderValue;
                    }
                  }
                }
              });
            },
            onChangeEnd: (newValue) => _sliderValue = newValue,
          ),
          const SizedBox(height: TIOMusicParams.edgeInset),
          SettingButton(icon: Icons.add, title: l10n.mediaPlayerAddMarker, onTap: _addNewMarker),
          SettingButton(icon: Icons.delete_outlined, title: l10n.mediaPlayerRemoveMarker, onTap: _removeSelectedMarker),
        ],
      ),
    );
  }

  void _removeSelectedMarker() {
    if (_selectedMarkerPosition != null) {
      _markerPositions.removeWhere((pos) => pos == _selectedMarkerPosition);
      _selectedMarkerPosition = null;
    }
    setState(() {});
  }

  void _removeAllMarkers() {
    _markerPositions.clear();
    _selectedMarkerPosition = null;
    setState(() {});
  }

  void _onWaveTap(TapDownDetails details) async {
    final double tapX = details.localPosition.dx;
    final double snappedRelativePosition = _calculateSnappedRelativePosition(tapX);

    setState(() {
      _sliderValue = snappedRelativePosition;
      _waveformVisualizer = WaveformVisualizer.singleView(_sliderValue, widget.rmsValues, true);
    });

    _selectedMarkerPosition = _findMarkerNear(snappedRelativePosition);
    setState(() {});
  }

  double _calculateSnappedRelativePosition(double tapX) {
    final int binCount = widget.rmsValues.length;
    final int tappedBinIndex = WaveformVisualizer.indexForX(tapX, _paintedWaveWidth, binCount);
    return tappedBinIndex / (binCount - 1);
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
    setState(() {});
  }

  Future<void> _onConfirm() async {
    widget.mediaPlayerBlock.markerPositions.clear();
    _markerPositions.forEach(widget.mediaPlayerBlock.markerPositions.add);

    await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
    if (!mounted) return;
    Navigator.pop(context);
  }
}
