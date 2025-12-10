import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/pages/media_player/markers/waveform.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/domain/audio/player.dart';
import 'package:tiomusic/pages/media_player/markers/zoom_rms_helper.dart';

const defaultStart = 0.0;
const defaultEnd = 1.0;

class SetTrim extends StatefulWidget {
  final Float32List rmsValues;
  final double initialStart;
  final double initialEnd;
  final Duration fileDuration;
  final Player player;
  final Future<void> Function(double start, double end) onChange;
  final Future<void> Function(double start, double end) onConfirm;
  final Future<void> Function() onCancel;

  const SetTrim({
    super.key,
    required this.initialStart,
    required this.initialEnd,
    required this.rmsValues,
    required this.fileDuration,
    required this.player,
    required this.onChange,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<SetTrim> createState() => _SetTrimState();
}

class _SetTrimState extends State<SetTrim> {
  late RangeValues rangeValues;
  late Float32List rmsValues;
  late int targetVisibleBins;

  @override
  void initState() {
    super.initState();
    rangeValues = RangeValues(widget.initialStart, widget.initialEnd);
    rmsValues = widget.rmsValues;
    targetVisibleBins = widget.rmsValues.length;
  }

  Future<void> handleChange(RangeValues values) async {
    setState(() => rangeValues = values);
    if (rangeValues.start < rangeValues.end) await widget.onChange(rangeValues.start, rangeValues.end);
  }

  Future<void> handleWaveformPositionChange(double relative) async {
    double start = rangeValues.start;
    double end = rangeValues.end;

    const double minDelta = 0.001;

    final bool moveRangeStart = (relative - start).abs() <= (relative - end).abs();
    if (moveRangeStart) {
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

    await handleChange(RangeValues(start, end));
  }

  Future<void> handleConfirm() async {
    await widget.onConfirm(rangeValues.start, rangeValues.end);
    if (mounted) Navigator.pop(context);
  }

  Future<void> handleCancel() async {
    await widget.onCancel();
    if (mounted) Navigator.pop(context);
  }

  Future<void> handleReset() async => handleChange(const RangeValues(defaultStart, defaultEnd));

  Future<void> handleZoomChanged(double viewStart, double viewEnd) async {
    final Float32List? newRms = await recalculateRmsForZoom(
      player: widget.player,
      targetVisibleBins: targetVisibleBins,
      viewStart: viewStart,
      viewEnd: viewEnd,
      currentBinCount: rmsValues.length,
    );
    if (!mounted || newRms == null) return;
    setState(() => rmsValues = newRms);
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: context.l10n.mediaPlayerSetTrim,
      confirm: handleConfirm,
      reset: handleReset,
      cancel: handleCancel,
      customWidget: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Waveform(
            rmsValues: rmsValues,
            position: null,
            rangeStart: rangeValues.start,
            rangeEnd: rangeValues.end,
            fileDuration: widget.fileDuration,
            markerPositions: const [],
            selectedMarkerPosition: null,
            onPositionChange: handleWaveformPositionChange,
            onZoomChanged: handleZoomChanged,
          ),
        ],
      ),
    );
  }
}
