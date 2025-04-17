import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

const int cooldownInMs = 3000;
const int gradiantFrameLengthInMs = 50;

class Tap2Tempo extends StatefulWidget {
  final int value;
  final Function(int) onChanged;
  final bool enabled;

  const Tap2Tempo({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  State<Tap2Tempo> createState() => _Tap2TempoState();
}

class _Tap2TempoState extends State<Tap2Tempo> {
  var _time1 = DateTime.now();
  var _time2 = DateTime.now();
  var _bpmList = <int>[];
  bool _firstTap = true;
  int _gradiantValue = cooldownInMs;
  late Timer? _gradiantTimer;

  @override
  void initState() {
    super.initState();
    _gradiantTimer = Timer(Duration.zero, () {});
  }

  @override
  void dispose() {
    _gradiantTimer?.cancel();
    super.dispose();
  }

  int _convertMsToBpm(int ms) => 60000 ~/ ms;

  void _updateBpm() {
    var bpm = _convertMsToBpm(_time2.difference(_time1).inMilliseconds);

    if (_firstTap) {
      _bpmList = List.empty(growable: true);
      setState(() => _firstTap = false);
    } else {
      _bpmList.add(bpm);
      widget.onChanged(_bpmList.average.round());
    }
  }

  void _startGradientTimer() {
    _gradiantTimer?.cancel();
    _gradiantValue = 0;
    _gradiantTimer = Timer.periodic(const Duration(milliseconds: gradiantFrameLengthInMs), (timer) {
      _gradiantValue = gradiantFrameLengthInMs * timer.tick;
      if (_gradiantValue >= cooldownInMs) {
        timer.cancel();
        _firstTap = true;
      }
      setState(() {});
    });
  }

  void _handleChange() {
    _time2 = DateTime.now();
    _startGradientTimer();
    _updateBpm();
    setState(() => _time1 = _time2);
  }

  @override
  Widget build(BuildContext context) {
    return TIOTextButton(
      text: context.l10n.mediaPlayerTapToTempo,
      onTap: widget.enabled ? _handleChange : () {},
      backgroundColor: Color.lerp(ColorTheme.tertiary60, ColorTheme.surface, _gradiantValue / cooldownInMs),
      icon: const Icon(Icons.touch_app_outlined, size: 40),
    );
  }
}
