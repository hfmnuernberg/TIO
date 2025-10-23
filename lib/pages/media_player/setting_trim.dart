import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/pages/media_player/waveform_visualizer.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';

class SetTrim extends StatefulWidget {
  final Float32List rmsValues;
  final Duration fileDuration;

  final double initialStart;
  final double initialEnd;

  final Future<void> Function(double start, double end) onChange;

  final Future<void> Function(double start, double end) onConfirm;

  final Future<void> Function() onCancel;

  final Future<void> Function()? onReset;

  const SetTrim({
    super.key,
    required this.rmsValues,
    required this.fileDuration,
    required this.initialStart,
    required this.initialEnd,
    required this.onChange,
    required this.onConfirm,
    required this.onCancel,
    this.onReset,
  });

  @override
  State<SetTrim> createState() => _SetTrimState();
}

class _SetTrimState extends State<SetTrim> {
  late RangeValues _rangeValues;
  late WaveformVisualizer _waveformVisualizer;

  Duration _rangeStartDuration = Duration.zero;
  Duration _rangeEndDuration = Duration.zero;

  @override
  void initState() {
    super.initState();

    _rangeValues = RangeValues(widget.initialStart, widget.initialEnd);
    _waveformVisualizer = WaveformVisualizer.setTrim(0, 1, widget.rmsValues);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _rangeStartDuration = widget.fileDuration * _rangeValues.start;
      _rangeEndDuration = widget.fileDuration * _rangeValues.end;

      setState(() {
        _waveformVisualizer = WaveformVisualizer.setTrim(_rangeValues.start, _rangeValues.end, widget.rmsValues);
      });
    });
  }

  Future<void> _handleChange(RangeValues values) async {
    setState(() {
      _rangeValues = values;
      _waveformVisualizer = WaveformVisualizer.setTrim(values.start, values.end, widget.rmsValues);
      _rangeStartDuration = widget.fileDuration * _rangeValues.start;
      _rangeEndDuration = widget.fileDuration * _rangeValues.end;
    });
    if (_rangeValues.start < _rangeValues.end) await widget.onChange(_rangeValues.start, _rangeValues.end);
  }

  Future<void> _handleConfirm() async {
    widget.onConfirm(_rangeValues.start, _rangeValues.end);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _handleCancel() async {
    widget.onCancel();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _handleReset() async {
    const start = MediaPlayerParams.defaultRangeStart;
    const end = MediaPlayerParams.defaultRangeEnd;
    setState(() {
      _rangeValues = const RangeValues(start, end);
      _waveformVisualizer = WaveformVisualizer.setTrim(0, 1, widget.rmsValues);
      _rangeStartDuration = widget.fileDuration * start;
      _rangeEndDuration = widget.fileDuration * end;
    });
    if (widget.onReset != null) {
      await widget.onReset!();
    } else {
      await widget.onChange(start, end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ParentSettingPage(
      title: l10n.mediaPlayerSetTrim,
      confirm: _handleConfirm,
      reset: _handleReset,
      cancel: _handleCancel,
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
                  divisions: 1000,
                  labels: RangeLabels(
                    l10n.formatDurationWithMillis(_rangeStartDuration),
                    l10n.formatDurationWithMillis(_rangeEndDuration),
                  ),
                  onChanged: (values) async {
                    var start = values.start;
                    var end = values.end;
                    if (start == end) {
                      end = end + 0.001;
                      if (end > 1.0) {
                        end = 1.0;
                        start = 0.999;
                      }
                    }
                    await _handleChange(RangeValues(start, end));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
