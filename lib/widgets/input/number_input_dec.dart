import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/shapes.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

class NumberInputDec extends StatefulWidget {
  final double value;
  final Function(double) onChanged;
  final double max;
  final double min;
  final double defaultValue;
  final int decimalDigits;
  final double step;
  final int stepIntervalInMs;
  final String label;
  final double buttonRadius;
  final double buttonGap;
  final double textFieldWidth;
  final double textFontSize;
  final double relIconSize;

  const NumberInputDec({
    super.key,
    required this.value,
    required this.onChanged,
    double? min,
    double? max,
    double? defaultValue,
    int? decimalDigits,
    double? step,
    int? stepIntervalInMs,
    String? label,
    double? buttonRadius,
    double? buttonGap,
    double? textFieldWidth,
    double? textFontSize,
    double? relIconSize,
  }) : min = min ?? double.negativeInfinity,
       max = max ?? double.infinity,
       defaultValue = defaultValue ?? 0,
       decimalDigits = decimalDigits ?? 1,
       step = step ?? 1,
       stepIntervalInMs = stepIntervalInMs ?? 100,
       label = label ?? '',
       buttonRadius = buttonRadius ?? 25,
       buttonGap = buttonGap ?? 10,
       textFieldWidth = textFieldWidth ?? 100,
       textFontSize = textFontSize ?? 40,
       relIconSize = relIconSize ?? 0.4;

  @override
  State<NumberInputDec> createState() => _NumberInputDecState();
}

class _NumberInputDecState extends State<NumberInputDec> {
  late TextEditingController _valueController;
  Timer? _decreaseTimer;
  Timer? _increaseTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _valueController = TextEditingController(text: _formatNumber(widget.value));
  }

  @override
  void didUpdateWidget(covariant NumberInputDec oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      _valueController.text = _formatNumber(widget.value);
    }
  }

  @override
  void dispose() {
    _decreaseTimer?.cancel();
    _increaseTimer?.cancel();
    super.dispose();
  }

  double _round(double number) => double.parse(number.toStringAsFixed(widget.decimalDigits));
  String _formatNumber(double number) => context.l10n.formatNumber(_round(number));
  double _parseNumber(String number) => context.l10n.parseNumber(number);

  double _parseInput(String input) {
    if (['', '-', '.', ',', '-.', '-,'].contains(input)) return widget.defaultValue;

    if (input[0] == '.') {
      input = '0$input';
    } else if (input.substring(0, 1) == '-.') {
      input = '-0${input.substring(1)}';
    }

    final number = _parseNumber(input);
    if (number < widget.min) return widget.min;
    if (number > widget.max) return widget.max;

    return number;
  }

  void _decreaseValue() => _updateValue(_parseNumber(_valueController.text) - widget.step);
  void _increaseValue() => _updateValue(_parseNumber(_valueController.text) + widget.step);

  void _startDecreaseTimer() =>
      _decreaseTimer = Timer.periodic(Duration(milliseconds: widget.stepIntervalInMs), (_) => _decreaseValue());
  void _startIncreaseTimer() =>
      _increaseTimer = Timer.periodic(Duration(milliseconds: widget.stepIntervalInMs), (_) => _increaseValue());

  void _endDecreaseTimer() => _decreaseTimer?.cancel();
  void _endIncreaseTimer() => _increaseTimer?.cancel();

  void _updateValue(double value) {
    if (value == widget.value) return;
    _valueController.text = _formatNumber(value);
    widget.onChanged(value);
  }

  void _handleUpdate(String input) => _updateValue(_parseInput(input));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onLongPress: _startDecreaseTimer,
              onLongPressUp: _endDecreaseTimer,
              child: TIOFlatButton(
                semanticLabel: l10n.commonMinus,
                onPressed: widget.value <= widget.min ? null : _decreaseValue,
                customStyle: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: const LeftButtonShape(),
                  fixedSize: Size(widget.buttonRadius * 2, widget.buttonRadius * 2),
                ),
                icon: Icon(Icons.remove, size: widget.buttonRadius * widget.relIconSize * 2),
              ),
            ),
            SizedBox(width: widget.buttonGap),
            SizedBox(
              width: widget.textFieldWidth,
              child: Focus(
                child: Semantics(
                  label: '${widget.label} ${l10n.commonInput}',
                  child: TextFormField(
                    controller: _valueController,
                    keyboardType: TextInputType.numberWithOptions(signed: widget.min < 0, decimal: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp('^-?\\d*[.,]?\\d*\$')),
                      DeleteLeadingZeros(),
                    ],
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorTheme.primary)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorTheme.primary)),
                      counterText: '',
                    ),
                    style: TextStyle(fontSize: widget.textFontSize, color: ColorTheme.primary),
                    textAlign: TextAlign.center,
                    onFieldSubmitted: _handleUpdate,
                  ),
                ),
                onFocusChange: (hasFocus) {
                  if (hasFocus) {
                    _valueController.value = _valueController.value.copyWith(
                      selection: TextSelection(baseOffset: 0, extentOffset: _valueController.value.text.length),
                    );
                  } else {
                    _handleUpdate(_valueController.value.text);
                  }
                },
              ),
            ),
            SizedBox(width: widget.buttonGap),
            GestureDetector(
              onLongPress: _startIncreaseTimer,
              onLongPressUp: _endIncreaseTimer,
              child: TIOFlatButton(
                semanticLabel: l10n.commonPlus,
                onPressed: widget.value >= widget.max ? null : _increaseValue,
                customStyle: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: const RightButtonShape(),
                  fixedSize: Size(widget.buttonRadius * 2, widget.buttonRadius * 2),
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

class DeleteLeadingZeros extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;
    if (RegExp(r'^-0\d').firstMatch(text) != null) {
      text = '-${text.substring(2)}';
    } else {
      if (RegExp(r'^0\d').firstMatch(text) != null) {
        text = text.substring(1);
      }
    }
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
