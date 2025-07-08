import 'dart:async';
import 'dart:ui';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stats/stats.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/tuner_block.dart';
import 'package:tiomusic/pages/parent_tool/parent_inner_island.dart';
import 'package:tiomusic/pages/tuner/tuner_functions.dart';
import 'package:tiomusic/services/audio_system.dart';

import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_midi.dart';

class TunerIslandView extends StatefulWidget {
  final TunerBlock tunerBlock;

  const TunerIslandView({super.key, required this.tunerBlock});

  @override
  State<TunerIslandView> createState() => _TunerIslandViewState();
}

class _TunerIslandViewState extends State<TunerIslandView> {
  Timer? _timerPollFreq;
  final _midiNameText = TextEditingController();

  late AudioSystem _as;

  late double _pitchFactor = 0.5;
  late String _midiName = 'A';
  late PitchIslandViewVisualizer _pitchIslandViewVisualizer;

  final _freqHistory = List<double>.filled(10, 0);
  var _freqHistoryIndex = 0;

  bool _isRunning = false;

  bool _processingButtonClick = false;

  StreamSubscription<AudioInterruptionEvent>? audioInterruptionListener;

  Future<bool> startTuner() async {
    _isRunning = true;
    audioInterruptionListener = (await AudioSession.instance).interruptionEventStream.listen((event) {
      if (event.type == AudioInterruptionType.unknown) stopTuner();
    });
    return TunerFunctions.start(_as);
  }

  Future<bool> stopTuner() async {
    await audioInterruptionListener?.cancel();
    _isRunning = false;
    _midiNameText.text = '';
    _pitchFactor = 0.5;
    _freqHistory.fillRange(0, _freqHistory.length, 0);
    _pitchIslandViewVisualizer = PitchIslandViewVisualizer(_pitchFactor, _midiName, false);
    return TunerFunctions.stop(_as);
  }

  @override
  void initState() {
    super.initState();

    _as = context.read<AudioSystem>();

    _pitchIslandViewVisualizer = PitchIslandViewVisualizer(_pitchFactor, _midiName, false);

    _timerPollFreq = Timer.periodic(const Duration(milliseconds: TunerParams.freqPollMillis), (t) async {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (!_isRunning) return;
      _onNewFrequency(await _as.tunerGetFrequency());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // start with delay to make sure previous tuner is stopped before new one is started (on copy/save)
      _processingButtonClick = true;
      await Future.delayed(const Duration(milliseconds: 400));
      startTuner();
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) setState(() => _processingButtonClick = false);
      });
    });
  }

  @override
  void deactivate() {
    stopTuner();
    _timerPollFreq?.cancel();
    super.deactivate();
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

    final freqStats = Stats.fromData(_freqHistory);
    final freq = freqStats.median.toDouble();
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
      await startTuner();
    }

    await Future.delayed(const Duration(milliseconds: TIOMusicParams.millisecondsPlayPauseDebounce));
    setState(() => _processingButtonClick = false);
  }
}

class PitchIslandViewVisualizer extends CustomPainter {
  late double _pitchFactor;
  late String _midiName;
  late bool _show = false;

  final double radiusSideCircles = 10;

  bool dirty = true;

  PitchIslandViewVisualizer(double factor, String midiName, bool show) {
    _pitchFactor = factor;
    _midiName = midiName;
    _show = show;
  }

  @override
  void paint(Canvas canvas, Size size) {
    dirty = false;

    var paintCircle =
        Paint()
          ..color = ColorTheme.primary
          ..strokeWidth = 2;

    var paintLine =
        Paint()
          ..color = ColorTheme.primaryFixedDim
          ..strokeWidth = 2;

    var paintEmptyCircle =
        Paint()
          ..color = ColorTheme.primary
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    var xPositionFactor = ((size.width - (radiusSideCircles * 2)) * _pitchFactor) + radiusSideCircles;
    var factorPosition = Offset(xPositionFactor, size.height / 2);

    // the line
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paintLine);

    // circles on the sides
    canvas.drawCircle(Offset(radiusSideCircles, size.height / 2), radiusSideCircles, paintLine);
    canvas.drawCircle(Offset(size.width - radiusSideCircles, size.height / 2), radiusSideCircles, paintLine);

    // empty circle in the middle
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 20, paintEmptyCircle);

    if (_show) {
      // circle showing the deviation
      canvas.drawCircle(factorPosition, 16, paintCircle);

      const textStyle = TextStyle(color: Colors.white, fontSize: 14);
      final textSpan = TextSpan(text: _midiName, style: textStyle);
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr, textAlign: TextAlign.center);
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(xPositionFactor - (textPainter.width / 2), size.height / 2 - (textPainter.height / 2)),
      );
    }
  }

  @override
  bool shouldRepaint(PitchIslandViewVisualizer oldDelegate) {
    return oldDelegate.dirty;
  }
}
