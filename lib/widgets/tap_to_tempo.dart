//Tap to Tempo: Measures the difference of taps to calculate the corresponding BPM number

import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

const int cooldownInMs = 3000;
const int lerpFrameLengthInMs = 50;

class Tap2Tempo extends StatefulWidget {
  final TextEditingController bpmHandle;
  final bool enabled;

  const Tap2Tempo({super.key, required this.bpmHandle, this.enabled = true});

  @override
  State<Tap2Tempo> createState() => _Tap2TempoState();
}

class _Tap2TempoState extends State<Tap2Tempo> {
  var _time1 = DateTime.now();
  var _time2 = DateTime.now();
  var _bpmList = <int>[];
  bool _firstTap = true;
  int _t2tColorLerpValue = cooldownInMs;
  late Timer? _t2tTimer;

  @override
  void initState() {
    super.initState();
    _t2tTimer = Timer(Duration.zero, () {});
  }

  @override
  void dispose() {
    _t2tTimer?.cancel();
    super.dispose();
  }

  // Measure time between taps
  void _tap2tempo() {
    _time2 = DateTime.now();
    _tap2tempoColorLerpTimer();
    var bpm = _ms2BPM(_time2.difference(_time1).inMilliseconds);
    if (_firstTap) {
      widget.bpmHandle.value = widget.bpmHandle.value.copyWith(
        text: '',
        selection: const TextSelection(baseOffset: 0, extentOffset: 0),
      );
      _bpmList = List.empty(growable: true);
      _firstTap = false;
    } else {
      _bpmList.add(bpm);
      widget.bpmHandle.value = widget.bpmHandle.value.copyWith(text: (_bpmList.average).round().toString());
    }
    _time1 = _time2;
    setState(() {});
  }

  // Update screen to lerp background color of the Tap2Tempo button
  void _tap2tempoColorLerpTimer() {
    _t2tTimer?.cancel();
    _t2tColorLerpValue = 0;
    _t2tTimer = Timer.periodic(const Duration(milliseconds: lerpFrameLengthInMs), (timer) {
      _t2tColorLerpValue = lerpFrameLengthInMs * timer.tick;
      if (_t2tColorLerpValue >= cooldownInMs) {
        timer.cancel();
        _firstTap = true;
      }
      setState(() {});
    });
  }

  // Convert ms to BPM
  int _ms2BPM(int ms) {
    return (60000 ~/ ms);
  }

  @override
  Widget build(BuildContext context) {
    return TIOTextButton(
      text: "Tap to tempo",
      onTap: widget.enabled ? _tap2tempo : () {},
      backgroundColor: Color.lerp(ColorTheme.tertiary60, ColorTheme.surface, _t2tColorLerpValue / cooldownInMs),
      icon: const Icon(Icons.touch_app_outlined, size: 40),
    );
  }
}
