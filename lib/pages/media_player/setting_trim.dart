import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/media_player/waveform_visualizer.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/src/rust/api/ffi.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';

class SetTrim extends StatefulWidget {
  final Float32List rmsValues;
  final Duration fileDuration;

  const SetTrim({super.key, required this.rmsValues, required this.fileDuration});

  @override
  State<SetTrim> createState() => _SetTrimState();
}

class _SetTrimState extends State<SetTrim> {
  late RangeValues _rangeValues;

  late MediaPlayerBlock _mediaPlayerBlock;

  late WaveformVisualizer _waveformVisualizer;

  Duration _rangeStartDuration = Duration.zero;
  Duration _rangeEndDuration = Duration.zero;

  @override
  void initState() {
    super.initState();

    _mediaPlayerBlock = Provider.of<ProjectBlock>(context, listen: false) as MediaPlayerBlock;
    _rangeValues = RangeValues(_mediaPlayerBlock.rangeStart, _mediaPlayerBlock.rangeEnd);

    _waveformVisualizer = WaveformVisualizer.setTrim(0, 1, widget.rmsValues);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _rangeStartDuration = widget.fileDuration * _rangeValues.start;
      _rangeEndDuration = widget.fileDuration * _rangeValues.end;

      setState(() {
        _waveformVisualizer = WaveformVisualizer.setTrim(_rangeValues.start, _rangeValues.end, widget.rmsValues);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ParentSettingPage(
      title: l10n.mediaPlayerSetTrim,
      confirm: _onConfirm,
      reset: _reset,
      cancel: _onCancel,
      customWidget: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(TIOMusicParams.edgeInset, 0, TIOMusicParams.edgeInset, 0),
            child: CustomPaint(painter: _waveformVisualizer, size: Size(MediaQuery.of(context).size.width, 200)),
          ),
          Padding(
            padding: const EdgeInsets.all(TIOMusicParams.edgeInset),
            child: Column(
              children: [
                RangeSlider(
                  values: _rangeValues,
                  inactiveColor: ColorTheme.primary80,
                  divisions: 1000, // how many individual values, only showing labels when division is not null
                  labels: RangeLabels(
                    l10n.formatDurationWithMillis(_rangeStartDuration),
                    l10n.formatDurationWithMillis(_rangeEndDuration),
                  ),
                  onChanged: (values) {
                    setState(() {
                      _rangeValues = values;
                      _waveformVisualizer = WaveformVisualizer.setTrim(values.start, values.end, widget.rmsValues);
                      _rangeStartDuration = widget.fileDuration * _rangeValues.start;
                      _rangeEndDuration = widget.fileDuration * _rangeValues.end;

                      _onUserChangesTrim();
                    });
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

  Future<void> _onConfirm() async {
    _mediaPlayerBlock.rangeStart = _rangeValues.start;
    _mediaPlayerBlock.rangeEnd = _rangeValues.end;
    await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());

    await mediaPlayerSetTrim(startFactor: _mediaPlayerBlock.rangeStart, endFactor: _mediaPlayerBlock.rangeEnd);

    if (mounted) Navigator.pop(context);
  }

  void _reset() {
    setState(() {
      _rangeValues = const RangeValues(MediaPlayerParams.defaultRangeStart, MediaPlayerParams.defaultRangeEnd);
      _waveformVisualizer = WaveformVisualizer.setTrim(0, 1, widget.rmsValues);
    });
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
