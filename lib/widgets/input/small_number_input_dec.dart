import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/shapes.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

class SmallNumberInputDec extends StatefulWidget {
  final double value;
  final Function(double) onChange;
  final double min;
  final double max;
  final int decimalDigits;
  final double decrementStep;
  final double incrementStep;
  final int stepIntervalInMs;
  final String label;
  final double buttonRadius;
  final double buttonGap;
  final double textFontSize;
  final double relIconSize;

  const SmallNumberInputDec({
    super.key,
    required this.value,
    required this.onChange,
    double? min,
    double? max,
    int? decimalDigits,
    double? step,
    double? decrementStep,
    double? incrementStep,
    int? stepIntervalInMs,
    String? label,
    double? buttonRadius,
    double? buttonGap,
    double? textFontSize,
    double? relIconSize,
  }) : min = min ?? double.negativeInfinity,
       max = max ?? double.infinity,
       decimalDigits = decimalDigits ?? 1,
       decrementStep = decrementStep ?? step ?? 1,
       incrementStep = incrementStep ?? step ?? 1,
       stepIntervalInMs = stepIntervalInMs ?? 100,
       label = label ?? '',
       buttonRadius = buttonRadius ?? 25,
       buttonGap = buttonGap ?? 4,
       textFontSize = textFontSize ?? 40,
       relIconSize = relIconSize ?? 0.4;

  @override
  State<SmallNumberInputDec> createState() => _NumberInputDecState();
}

class _NumberInputDecState extends State<SmallNumberInputDec> {
  Timer? _decreaseTimer;
  Timer? _increaseTimer;

  @override
  void dispose() {
    _decreaseTimer?.cancel();
    _increaseTimer?.cancel();
    super.dispose();
  }

  double _round(double number) => double.parse(number.toStringAsFixed(widget.decimalDigits));
  String _formatNumber(double number) => context.l10n.formatNumber(_round(number));

  void _decreaseValue() => _updateValue((widget.value - widget.decrementStep).clamp(widget.min, widget.max));
  void _increaseValue() => _updateValue((widget.value + widget.incrementStep).clamp(widget.min, widget.max));

  void _startDecreaseTimer() =>
      _decreaseTimer = Timer.periodic(Duration(milliseconds: widget.stepIntervalInMs), (_) => _decreaseValue());
  void _startIncreaseTimer() =>
      _increaseTimer = Timer.periodic(Duration(milliseconds: widget.stepIntervalInMs), (_) => _increaseValue());

  void _endDecreaseTimer() => _decreaseTimer?.cancel();
  void _endIncreaseTimer() => _increaseTimer?.cancel();

  void _updateValue(double value) {
    if (value != widget.value) widget.onChange(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_formatNumber(widget.value), style: TextStyle(fontSize: widget.textFontSize, color: ColorTheme.primary)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onLongPress: _startDecreaseTimer,
              onLongPressUp: _endDecreaseTimer,
              child: TIOFlatButton(
                semanticLabel: l10n.commonMinus,
                onPressed: widget.value - widget.decrementStep < widget.min ? null : _decreaseValue,
                customStyle: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: const LeftButtonShape(),
                  fixedSize: Size(widget.buttonRadius, widget.buttonRadius),
                ),
                icon: Icon(Icons.remove, size: widget.buttonRadius * widget.relIconSize * 2),
              ),
            ),
            SizedBox(width: widget.buttonGap),
            GestureDetector(
              onLongPress: _startIncreaseTimer,
              onLongPressUp: _endIncreaseTimer,
              child: TIOFlatButton(
                semanticLabel: l10n.commonPlus,
                onPressed: widget.value + widget.incrementStep > widget.max ? null : _increaseValue,
                customStyle: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: const RightButtonShape(),
                  fixedSize: Size(widget.buttonRadius, widget.buttonRadius),
                ),
                icon: Icon(Icons.add, size: widget.buttonRadius * widget.relIconSize * 2),
              ),
            ),
          ],
        ),
        Text(widget.label, style: const TextStyle(color: ColorTheme.primary)),
      ],
    );
  }
}
