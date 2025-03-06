import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/media_player/media_player_functions.dart';
import 'package:tiomusic/pages/media_player/waveform_visualizer.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/zoomable.dart';

class SetTrim extends StatefulWidget {
  final Float32List rmsValues;
  final Duration fileDuration;

  const SetTrim({super.key, required this.rmsValues, required this.fileDuration});

  @override
  State<SetTrim> createState() => _SetTrimState();
}

class _SetTrimState extends State<SetTrim> {
  int _zoomLevel = 1;
  int _zoomWindowStartOffset = 0;

  late RangeValues _rangeValues;

  late MediaPlayerBlock _mediaPlayerBlock;

  late WaveformVisualizer _waveformVisualizer;
  int _numOfBins = 0;

  late Map<int, Float32List> _rmsValuesByZoomLevel = {};

  double _waveFormWidth = 0;

  Duration _rangeStartDuration = Duration.zero;
  Duration _rangeEndDuration = Duration.zero;

  Future<void> _queryAndUpdateStateFromRust() async {
    var mediaPlayerStateRust = await mediaPlayerGetState();
    if (!mounted || mediaPlayerStateRust == null) return;
    setState(() {
      _waveformVisualizer = WaveformVisualizer(
        mediaPlayerStateRust.playbackPositionFactor,
        _mediaPlayerBlock.rangeStart,
        _mediaPlayerBlock.rangeEnd,
        _rmsValuesByZoomLevel[_zoomLevel]!,
        _numOfBins,
      );
    });
  }

  Future<void> _refreshRmsValues() async {
    if (_rmsValuesByZoomLevel[_zoomLevel] != null) return;

    final newRmsValues = await MediaPlayerFunctions.openAudioFileInRustAndGetRMSValues(_mediaPlayerBlock, _numOfBins * _zoomLevel);
    if (newRmsValues == null) return;

    final newRmsValuesByZoomLevel = { ..._rmsValuesByZoomLevel };
    newRmsValuesByZoomLevel[_zoomLevel] = newRmsValues;

    setState(() => _rmsValuesByZoomLevel = newRmsValuesByZoomLevel);
  }

  void _refreshWaveform() {
    final zoomWindowEndOffset = _zoomWindowStartOffset + _numOfBins;

    final zoomWindowStart = _zoomWindowStartOffset / (_numOfBins * _zoomLevel);
    final zoomWindowEnd = zoomWindowEndOffset / (_numOfBins * _zoomLevel);

    final rangeStart = (_rangeValues.start.clamp(zoomWindowStart, zoomWindowEnd) - zoomWindowStart) * _zoomLevel;
    final rangeEnd = (_rangeValues.end.clamp(zoomWindowStart, zoomWindowEnd) - zoomWindowStart) * _zoomLevel;

    setState(() {
      _waveformVisualizer = WaveformVisualizer.setTrim(
        rangeStart,
        rangeEnd,
        _rmsValuesByZoomLevel[_zoomLevel]!.sublist(_zoomWindowStartOffset, zoomWindowEndOffset),
        _numOfBins,
      );
    });
  }

  void _onWaveformDoubleTap() async {
    setState(() => _zoomLevel = _zoomLevel == 1 ? 2 : _zoomLevel == 2 ? 3 : 1);
    await _refreshRmsValues();
    _refreshWaveform();
    _print();
  }

  void _onWaveformHorizontalDragUpdate(DragUpdateDetails details) async {
    final relativeDragPosition = details.primaryDelta! / _waveFormWidth;
    final relativeDragPositionInBins = -(relativeDragPosition * _numOfBins).round();
    int newZoomWindowStartOffset = _zoomWindowStartOffset + relativeDragPositionInBins;
    newZoomWindowStartOffset = newZoomWindowStartOffset.clamp(0, _numOfBins * _zoomLevel - _numOfBins);
    setState(() => _zoomWindowStartOffset = newZoomWindowStartOffset);
    _refreshWaveform();
  }

  void _onWaveTap(TapDownDetails details) async {
    double relativeTapPosition = details.localPosition.dx / _waveFormWidth;

    await mediaPlayerSetPlaybackPosFactor(posFactor: relativeTapPosition);
    await _queryAndUpdateStateFromRust();
  }

  @override
  void initState() {
    super.initState();

    _rmsValuesByZoomLevel[_zoomLevel] = widget.rmsValues;

    _mediaPlayerBlock = Provider.of<ProjectBlock>(context, listen: false) as MediaPlayerBlock;
    _rangeValues = RangeValues(_mediaPlayerBlock.rangeStart, _mediaPlayerBlock.rangeEnd);

    _waveformVisualizer = WaveformVisualizer.setTrim(0, 1, _rmsValuesByZoomLevel[_zoomLevel]!, 0);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _waveFormWidth = MediaQuery.of(context).size.width - (TIOMusicParams.edgeInset * 2);
      _numOfBins = (_waveFormWidth / MediaPlayerParams.binWidth).floor();

      _rangeStartDuration = widget.fileDuration * _rangeValues.start;
      _rangeEndDuration = widget.fileDuration * _rangeValues.end;

      _refreshWaveform();
    });
  }

  void _print() {
    print('=====================================');
    print('_zoomLevel: $_zoomLevel');
    print('_zoomWindowStartOffset: $_zoomWindowStartOffset');
    print('_zoomWindowEndOffset: ${_zoomWindowStartOffset + _numOfBins}');
    print('_waveFormWidth: $_waveFormWidth');
    print('_numOfBins: $_numOfBins');
    print('_rmsValues.length: ${_rmsValuesByZoomLevel[_zoomLevel]!.length}');
    print('_rangeValues.start: ${_rangeValues.start}');
    print('_rangeValues.end:   ${_rangeValues.end}');
    print('widget.fileDuration: ${widget.fileDuration}');
    print('_rangeStartDuration: $_rangeStartDuration');
    print('_rangeEndDuration:   $_rangeEndDuration');
  }

  @override
  Widget build(BuildContext context) {
    const double waveFormHeight = 200;

    return ParentSettingPage(
      title: 'Set Trim',
      confirm: _onConfirm,
      reset: _reset,
      cancel: _onCancel,
      customWidget: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(TIOMusicParams.edgeInset, 0, TIOMusicParams.edgeInset, 0),
            child: GestureDetector(
              // onTapDown: _onWaveTap,
              onHorizontalDragUpdate: _onWaveformHorizontalDragUpdate,
              onDoubleTap: _onWaveformDoubleTap,
            //   child: Zoomable(
            //     childWidgetHeight: waveFormHeight,
                child: CustomPaint(painter: _waveformVisualizer, size: Size(_waveFormWidth, waveFormHeight)),
              // ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(TIOMusicParams.edgeInset),
            child: Column(
              children: [
                Text('Zoom: $_zoomLevel'),
                RangeSlider(
                  values: _rangeValues,
                  inactiveColor: ColorTheme.primary80,
                  divisions: 1000, // how many individual values, only showing labels when division is not null
                  labels: RangeLabels(
                    getDurationFormatedWithMilliseconds(_rangeStartDuration),
                    getDurationFormatedWithMilliseconds(_rangeEndDuration),
                  ),
                  onChanged: (values) {
                    setState(() {
                      _rangeValues = values;
                      _rangeStartDuration = widget.fileDuration * _rangeValues.start;
                      _rangeEndDuration = widget.fileDuration * _rangeValues.end;

                      _onUserChangesTrim();
                    });
                    _refreshWaveform();
                  },
                  onChangeEnd: (values) {
                    var start = values.start;
                    var end = values.end;
                    if (start == end) {
                      end = end + 0.001;
                      if (end > 1.0) {
                        end = 1.0;
                        start = 0.999;
                      }
                    }
                    _rangeValues = RangeValues(start, end);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onConfirm() async {
    _mediaPlayerBlock.rangeStart = _rangeValues.start;
    _mediaPlayerBlock.rangeEnd = _rangeValues.end;
    FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());

    await mediaPlayerSetTrim(startFactor: _mediaPlayerBlock.rangeStart, endFactor: _mediaPlayerBlock.rangeEnd);

    if (mounted) Navigator.pop(context);
  }

  void _reset() {
    setState(() {
      _rangeValues = const RangeValues(MediaPlayerParams.defaultRangeStart, MediaPlayerParams.defaultRangeEnd);
    });
    _refreshWaveform();
  }

  void _onCancel() async {
    await mediaPlayerSetTrim(startFactor: _mediaPlayerBlock.rangeStart, endFactor: _mediaPlayerBlock.rangeEnd);
    if (mounted) Navigator.pop(context);
  }

  void _onUserChangesTrim() async {
    if (_rangeValues.start < _rangeValues.end) {
      await mediaPlayerSetTrim(startFactor: _rangeValues.start, endFactor: _rangeValues.end);
    }
  }
}
