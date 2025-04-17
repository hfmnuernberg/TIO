import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/shapes.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

class OldNumberInputDouble extends StatefulWidget {
  final double max;
  final double min;
  final double defaultValue;
  final double step;
  final TextEditingController controller;
  final int stepIntervalInMs;
  final String label;
  final double buttonRadius;
  final double buttonGap;
  final double textFieldWidth;
  final double textFontSize;
  final double relIconSize;
  final bool allowNegativeNumbers;

  const OldNumberInputDouble({
    super.key,
    required this.max,
    required this.min,
    required this.defaultValue,
    required this.step,
    required this.controller,
    int? stepIntervalInMs,
    String? label,
    double? buttonRadius,
    double? buttonGap,
    double? textFieldWidth,
    double? textFontSize,
    double? relIconSize,
    bool? allowNegativeNumbers,
  }) : stepIntervalInMs = stepIntervalInMs ?? 100,
       label = label ?? '',
       buttonRadius = buttonRadius ?? 25,
       buttonGap = buttonGap ?? 10,
       textFieldWidth = textFieldWidth ?? 100,
       textFontSize = textFontSize ?? 40,
       relIconSize = relIconSize ?? 0.4,
       allowNegativeNumbers = allowNegativeNumbers ?? false;

  @override
  State<OldNumberInputDouble> createState() => _OldNumberInputDoubleState();
}

class _OldNumberInputDoubleState extends State<OldNumberInputDouble> {
  bool _isPlusButtonActive = true;
  bool _isMinusButtonActive = true;
  late TextEditingController _valueController;
  Timer? _decreaseTimer;
  Timer? _increaseTimer;
  late int _maxDigitsLeft;
  late int _maxDigitsRight;

  @override
  void initState() {
    super.initState();

    _calcMaxDigits();

    widget.controller.addListener(_onExternalChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _valueController = TextEditingController(
      text: _formatNumber(
        widget.controller.value.text.isEmpty ? widget.defaultValue : double.parse(widget.controller.value.text),
      ),
    );
  }

  @override
  void dispose() {
    _decreaseTimer?.cancel();
    _increaseTimer?.cancel();
    super.dispose();
  }

  void _onExternalChange() {
    _validateInput(widget.controller.value.text);
  }

  double _round(double number) => double.parse(number.toStringAsFixed(_maxDigitsRight));

  String _formatNumber(double number) => context.l10n.formatNumber(_round(number));

  double _parseNumber(String number) => context.l10n.parseNumber(number);

  void _calcMaxDigits() {
    String countingValueString = widget.step.toString();
    String maxValueString = widget.max.toString();
    String minValueString = widget.min.toString();

    int maxDigitsLeftMin =
        (minValueString.contains('.') ? minValueString.split('.')[0].length : minValueString.length) -
        (minValueString.contains('-') ? 1 : 0);
    int maxDigitsLeftMax =
        (maxValueString.contains('.') ? maxValueString.split('.')[0].length : maxValueString.length) -
        (maxValueString.contains('-') ? 1 : 0);
    _maxDigitsLeft = [maxDigitsLeftMin, maxDigitsLeftMax].reduce(max);
    _maxDigitsRight = countingValueString.contains('.') ? countingValueString.split('.')[1].length : 0;
  }

  void _decreaseValue() {
    if (_valueController.value.text.isEmpty) return;

    _valueController.text = _formatNumber(_parseNumber(_valueController.value.text) - widget.step);
    _manageButtonActivity(_valueController.value.text);
    _validateInput(_valueController.value.text);
  }

  void _increaseValue() {
    if (_valueController.value.text.isEmpty) return;

    _valueController.text = _formatNumber(_parseNumber(_valueController.value.text) + widget.step);
    _manageButtonActivity(_valueController.value.text);
    _validateInput(_valueController.value.text);
  }

  void _startDecreaseTimer() {
    _decreaseTimer = Timer.periodic(Duration(milliseconds: widget.stepIntervalInMs), (timer) {
      _decreaseValue();
    });
  }

  void _startIncreaseTimer() {
    _increaseTimer = Timer.periodic(Duration(milliseconds: widget.stepIntervalInMs), (timer) {
      _increaseValue();
    });
  }

  void _endDecreaseTimer() {
    _decreaseTimer?.cancel();
  }

  void _endIncreaseTimer() {
    _increaseTimer?.cancel();
  }

  void _manageButtonActivity(String input) {
    if (input != '' && input != '-' && input != '.' && input != '-.') {
      if (_parseNumber(input) <= widget.min) {
        _isMinusButtonActive = false;
      } else {
        _isMinusButtonActive = true;
      }
      if (_parseNumber(input) >= widget.max) {
        _isPlusButtonActive = false;
      } else {
        _isPlusButtonActive = true;
      }
    }
    setState(() {});
  }

  void _validateInput(String input) {
    if (input != '' && input != '-' && input != '.' && input != ',' && input != '-.' && input != '-,') {
      if (input[0] == '.') {
        input = '0$input';
      } else {
        if (input.substring(0, 1) == '-.') {
          input = '-0${input.substring(1)}';
        }
      }
      if (_parseNumber(input) < widget.min) {
        input = _formatNumber(widget.min);
      } else {
        if (_parseNumber(input) > widget.max) {
          input = _formatNumber(widget.max);
        }
      }
    } else {
      input = _formatNumber(widget.defaultValue);
    }
    _valueController.value = _valueController.value.copyWith(text: input);
    widget.controller.value = widget.controller.value.copyWith(text: input);
    setState(() {});
  }

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
                onPressed:
                    (_valueController.value.text == '') ? () {} : (_isMinusButtonActive ? _decreaseValue : () {}),
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
                    keyboardType: TextInputType.numberWithOptions(signed: widget.allowNegativeNumbers, decimal: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                        RegExp('^-?(\\d{0,$_maxDigitsLeft})[.,]?(\\d{0,$_maxDigitsRight})'),
                      ),
                      DeleteLeadingZeros(),
                    ],
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorTheme.primary)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorTheme.primary)),
                      counterText: '',
                    ),
                    style: TextStyle(fontSize: widget.textFontSize, color: ColorTheme.primary),
                    textAlign: TextAlign.center,
                    onChanged: _manageButtonActivity,
                    onFieldSubmitted: _validateInput,
                  ),
                ),
                onFocusChange: (hasFocus) {
                  if (hasFocus) {
                    _valueController.value = _valueController.value.copyWith(
                      selection: TextSelection(baseOffset: 0, extentOffset: _valueController.value.text.length),
                    );
                  } else {
                    _validateInput(_valueController.value.text);
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
                onPressed: (_valueController.value.text == '') ? () {} : (_isPlusButtonActive ? _increaseValue : () {}),
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
