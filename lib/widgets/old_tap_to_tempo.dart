import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

const int cooldownInMs = 3000;
const int lerpFrameLengthInMs = 50;

class OldTap2Tempo extends StatefulWidget {
  final TextEditingController bpmHandle;
  final bool enabled;

  const OldTap2Tempo({super.key, required this.bpmHandle, this.enabled = true});

  @override
  State<OldTap2Tempo> createState() => _OldTap2TempoState();
}

class _OldTap2TempoState extends State<OldTap2Tempo> {
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
      widget.bpmHandle.value = widget.bpmHandle.value.copyWith(text: _bpmList.average.round().toString());
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
    return 60000 ~/ ms;
  }

  @override
  Widget build(BuildContext context) {
    return TIOTextButton(
      text: context.l10n.mediaPlayerTapToTempo,
      onTap: widget.enabled ? _tap2tempo : () {},
      backgroundColor: Color.lerp(ColorTheme.tertiary60, ColorTheme.surface, _t2tColorLerpValue / cooldownInMs),
      icon: const Icon(Icons.touch_app_outlined, size: 40),
    );
  }
}
