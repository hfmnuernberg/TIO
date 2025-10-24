import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project_library.dart';
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
    final ctx = _waveKey.currentContext;
    if (ctx == null) return _waveFormWidth;
    final render = ctx.findRenderObject();
    if (render is RenderBox) return render.size.width;
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

      setState(() {
        _waveformVisualizer = WaveformVisualizer.singleView(0, widget.rmsValues, true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ParentSettingPage(
      title: l10n.mediaPlayerEditMarkers,
      confirm: _onConfirm,
      reset: _removeAllMarkers,
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

                // markers
                Stack(children: _buildMarkers()),
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
            onChangeEnd: (newValue) {
              _sliderValue = newValue;
            },
          ),
          const SizedBox(height: TIOMusicParams.edgeInset),
          _listButtons(Icons.add, l10n.mediaPlayerAddMarker, _addNewMarker),
          _listButtons(Icons.delete_outlined, l10n.mediaPlayerRemoveMarker, _removeSelectedMarker),
        ],
      ),
    );
  }

  Widget _listButtons(IconData icon, String title, Function onTapFunction) {
    return Padding(
      padding: const EdgeInsets.only(
        left: TIOMusicParams.edgeInset,
        right: TIOMusicParams.edgeInset,
        top: 4,
        bottom: 4,
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        tileColor: ColorTheme.surface,
        textColor: ColorTheme.surfaceTint,
        iconColor: ColorTheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () {
          onTapFunction();
        },
      ),
    );
  }

  List<Widget> _buildMarkers() {
    List<Widget> markers = List.empty(growable: true);

    for (final pos in _markerPositions) {
      bool selected = _selectedMarkerPosition != null && pos == _selectedMarkerPosition;

      final int rmsValuesLength = widget.rmsValues.isEmpty ? 1 : widget.rmsValues.length;
      final int idx = rmsValuesLength <= 1 ? 0 : (pos.clamp(0.0, 1.0) * (rmsValuesLength - 1)).round();
      final double xPainter = WaveformVisualizer.xForIndex(idx, _paintedWaveWidth, rmsValuesLength);
      final double leftPainter = TIOMusicParams.edgeInset + (xPainter - (MediaPlayerParams.markerButton / 2));

      final marker = Positioned(
        left: leftPainter,
        top: (_waveFormHeight / 2) - MediaPlayerParams.markerIconSize - 20,
        child: IconButton(
          onPressed: () {
            if (!selected) {
              setState(() {
                _sliderValue = pos;
                _waveformVisualizer = WaveformVisualizer.singleView(_sliderValue, widget.rmsValues, true);
                _selectedMarkerPosition = pos;
              });
            }
          },
          icon: Icon(
            selected ? Icons.arrow_drop_down_circle_outlined : Icons.arrow_drop_down,
            color: selected ? ColorTheme.tertiary60 : ColorTheme.primary,
            size: MediaPlayerParams.markerIconSize,
          ),
        ),
      );
      markers.add(marker);
    }

    return markers;
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

  // jump to position on wave tap
  // and select marker if there is one at this position
  void _onWaveTap(TapDownDetails details) async {
    final double localX = details.localPosition.dx;
    final int n = widget.rmsValues.isEmpty ? 1 : widget.rmsValues.length;
    final double width = _paintedWaveWidth;

    final int idx = WaveformVisualizer.indexForX(localX, width, n);
    final double snappedRel = n <= 1 ? 0.0 : idx / (n - 1);

    setState(() {
      _sliderValue = snappedRel;
      _waveformVisualizer = WaveformVisualizer.singleView(_sliderValue, widget.rmsValues, true);
    });

    final double tolerance = n <= 1 ? 1.0 : (1.0 / (n - 1));
    double? foundMarkerPosition;

    for (final pos in _markerPositions) {
      if ((snappedRel - pos).abs() <= tolerance) {
        foundMarkerPosition = pos;
        break;
      }
    }
    if (foundMarkerPosition != null) {
      _selectedMarkerPosition = foundMarkerPosition;
    } else {
      _selectedMarkerPosition = null;
    }

    setState(() {});
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
