import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/domain/tuner/tuner.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/tuner_block.dart';
import 'package:tiomusic/pages/parent_tool/parent_inner_island.dart';
import 'package:tiomusic/pages/tuner/pitch_visualizer.dart';
import 'package:tiomusic/services/audio_session.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/wakelock.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants/constants.dart';
import 'package:tiomusic/util/util_midi.dart';

class TunerIslandView extends StatefulWidget {
  final TunerBlock tunerBlock;

  const TunerIslandView({super.key, required this.tunerBlock});

  @override
  State<TunerIslandView> createState() => _TunerIslandViewState();
}

class _TunerIslandViewState extends State<TunerIslandView> {
  final _midiNameText = TextEditingController();

  late final Tuner _tuner;

  late double _pitchFactor = 0.5;
  late String _midiName = 'A';
  late PitchIslandViewVisualizer _pitchIslandViewVisualizer;

  final _freqHistory = List<double>.filled(10, 0);
  var _freqHistoryIndex = 0;

  bool _isRunning = false;

  bool _processingButtonClick = false;

  @override
  void initState() {
    super.initState();

    _pitchIslandViewVisualizer = PitchIslandViewVisualizer(_pitchFactor, _midiName, false);

    _tuner = Tuner(
      context.read<AudioSystem>(),
      context.read<AudioSession>(),
      context.read<Wakelock>(),
      onRunningChange: (running) {
        if (!mounted) return;
        setState(() => _isRunning = running);
      },
      onFrequencyChange: (freq) {
        if (!mounted) return;
        if (!_isRunning) return;
        _onNewFrequency(freq);
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // start with delay to make sure previous tuner is stopped before new one is started (on copy/save)
      _processingButtonClick = true;
      await Future.delayed(const Duration(milliseconds: 400));
      await _tuner.start();
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) setState(() => _processingButtonClick = false);
      });
    });
  }

  @override
  void deactivate() {
    stopTuner();
    super.deactivate();
  }

  @override
  void dispose() {
    _midiNameText.dispose();
    _tuner.dispose();
    super.dispose();
  }

  Future<bool> stopTuner() async {
    final success = await _tuner.stop();

    _midiNameText.text = '';
    _pitchFactor = 0.5;
    _freqHistory.fillRange(0, _freqHistory.length, 0);
    _pitchIslandViewVisualizer = PitchIslandViewVisualizer(_pitchFactor, _midiName, false);

    return success;
  }

  double _medianOf(Iterable<double> values) {
    final list = values.toList()..sort();
    if (list.isEmpty) return 0;
    final mid = list.length ~/ 2;
    return list.length.isOdd ? list[mid] : (list[mid - 1] + list[mid]) / 2.0;
  }

  void _onNewFrequency(double? newFreq) {
    if (!mounted) return;
    if (newFreq == null) return;

    if (newFreq <= 0.0) {
      // there is no detectable frequency
      setState(() {
        _pitchIslandViewVisualizer = PitchIslandViewVisualizer(_pitchFactor, _midiName, false);
      });
      return;
    }

    _freqHistory[_freqHistoryIndex] = newFreq;
    _freqHistoryIndex = (_freqHistoryIndex + 1) % _freqHistory.length;

    final freq = _medianOf(_freqHistory.where((e) => e > 0));
    if (freq.abs() < 0.0001) return;

    var midi = freqToMidi(freq, widget.tunerBlock.chamberNoteHz);

    setState(() {
      _midiNameText.text = midiToNameOneChar(midi.round());
      _midiName = _midiNameText.text;
      _pitchFactor = clampDouble((midi - midi.round()) + 0.5, 0, 1);
      _pitchIslandViewVisualizer = PitchIslandViewVisualizer(_pitchFactor, _midiName, true);
    });
  }

  // Start/Stop
  void _startStop() async {
    if (_processingButtonClick) return;
    setState(() => _processingButtonClick = true);

    if (_isRunning) {
      await stopTuner();
    } else {
      await _tuner.start();
    }

    await Future.delayed(const Duration(milliseconds: TIOMusicParams.millisecondsPlayPauseDebounce));
    setState(() => _processingButtonClick = false);
  }

  @override
  Widget build(BuildContext context) {
    return ParentInnerIsland(
      onMainIconPressed: _startStop,
      mainIcon: _isRunning ? const Icon(TIOMusicParams.pauseIcon, color: ColorTheme.primary) : widget.tunerBlock.icon,
      parameterText: '${context.l10n.formatNumber(widget.tunerBlock.chamberNoteHz)} Hz',
      centerView: _pitchIslandViewVisualizer,
      textSpaceWidth: 60,
    );
  }
}
