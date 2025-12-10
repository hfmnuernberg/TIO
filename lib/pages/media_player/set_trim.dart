import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/pages/media_player/markers/waveform.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants/constants.dart';

const defaultStart = 0.0;
const defaultEnd = 1.0;

class SetTrim extends StatefulWidget {
  final Float32List rmsValues;
  final double initialStart;
  final double initialEnd;
  final Duration fileDuration;
  final Future<void> Function(double start, double end) onChange;
  final Future<void> Function(double start, double end) onConfirm;
  final Future<void> Function() onCancel;

  const SetTrim({
    super.key,
    required this.initialStart,
    required this.initialEnd,
    required this.rmsValues,
    required this.fileDuration,
    required this.onChange,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<SetTrim> createState() => _SetTrimState();
}

class _SetTrimState extends State<SetTrim> {
  late RangeValues _rangeValues;

  Duration _rangeStartDuration = Duration.zero;
  Duration _rangeEndDuration = Duration.zero;

  @override
  void initState() {
    super.initState();

    _rangeValues = RangeValues(widget.initialStart, widget.initialEnd);
    _rangeStartDuration = widget.fileDuration * _rangeValues.start;
    _rangeEndDuration = widget.fileDuration * _rangeValues.end;
  }

  Future<void> _handleChange(RangeValues values) async {
    setState(() {
      _rangeValues = values;
      _rangeStartDuration = widget.fileDuration * _rangeValues.start;
      _rangeEndDuration = widget.fileDuration * _rangeValues.end;
    });
    if (_rangeValues.start < _rangeValues.end) {
      await widget.onChange(_rangeValues.start, _rangeValues.end);
    }
  }

  Future<void> _handleWaveformPositionChange(double relative) async {
    double start = _rangeValues.start;
    double end = _rangeValues.end;

    const double minDelta = 0.001;

    // Decide which handle to move (whichever is closer to the tap)
    final bool moveStart = (relative - start).abs() <= (relative - end).abs();

    if (moveStart) {
      start = relative;
      if (start > end - minDelta) {
        start = (end - minDelta).clamp(0.0, 1.0);
      }
    } else {
      end = relative;
      if (end < start + minDelta) {
        end = (start + minDelta).clamp(0.0, 1.0);
      }
    }

    start = start.clamp(0.0, 1.0);
    end = end.clamp(0.0, 1.0);

    await _handleChange(RangeValues(start, end));
  }

  Future<void> _handleConfirm() async {
    await widget.onConfirm(_rangeValues.start, _rangeValues.end);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _handleCancel() async {
    await widget.onCancel();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _handleReset() async => _handleChange(const RangeValues(defaultStart, defaultEnd));

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
          Waveform(
            rmsValues: widget.rmsValues,
            position: null,
            rangeStart: _rangeValues.start,
            rangeEnd: _rangeValues.end,
            fileDuration: widget.fileDuration,
            markerPositions: const [],
            selectedMarkerPosition: null,
            onPositionChange: _handleWaveformPositionChange,
            onZoomChanged: (_, __) {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: TIOMusicParams.edgeInset),
            child: RangeSlider(
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
          ),
        ],
      ),
    );
  }
}
