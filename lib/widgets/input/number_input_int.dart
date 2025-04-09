import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/shapes.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

class NumberInputInt extends StatefulWidget {
  final int max;
  final int min;
  final int defaultValue;
  final int step;
  final TextEditingController controller;
  final int stepIntervalInMs;
  final String label;
  final double buttonRadius;
  final double buttonGap;
  final double relIconSize;
  final double textFieldWidth;
  final double textFontSize;
  final bool allowNegativeNumbers;

  const NumberInputInt({
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
    double? relIconSize,
    double? textFieldWidth,
    double? textFontSize,
    bool? allowNegativeNumbers,
  }) : stepIntervalInMs = stepIntervalInMs ?? 100,
       label = label ?? '',
       buttonRadius = buttonRadius ?? 25,
       buttonGap = buttonGap ?? 10,
       relIconSize = relIconSize ?? 0.4,
       textFieldWidth = textFieldWidth ?? 100,
       textFontSize = textFontSize ?? 40,
       allowNegativeNumbers = allowNegativeNumbers ?? false;

  @override
  State<NumberInputInt> createState() => _NumberInputIntState();
}

class _NumberInputIntState extends State<NumberInputInt> {
  bool _isPlusButtonActive = true;
  bool _isMinusButtonActive = true;
  late TextEditingController _valueController;
  Timer? _decreaseTimer;
  Timer? _increaseTimer;

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController(
      text: widget.controller.value.text.isEmpty ? widget.defaultValue.toString() : widget.controller.value.text,
    );

    widget.controller.addListener(_onExternalChange);
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

  void _decreaseValue() {
    if (_valueController.value.text != '') {
      _valueController.value = _valueController.value.copyWith(
        text: (int.parse(_valueController.value.text) - widget.step).toString(),
      );
      _manageButtonActivity(_valueController.value.text);
      _validateInput(_valueController.value.text);
    }
  }

  void _increaseValue() {
    if (_valueController.value.text != '') {
      _valueController.value = _valueController.value.copyWith(
        text: (int.parse(_valueController.value.text) + widget.step).toString(),
      );
      _manageButtonActivity(_valueController.value.text);
      _validateInput(_valueController.value.text);
    }
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
    if (input != '' && input != '-') {
      if (int.parse(input) <= widget.min) {
        _isMinusButtonActive = false;
      } else {
        _isMinusButtonActive = true;
      }
      if (int.parse(input) >= widget.max) {
        _isPlusButtonActive = false;
      } else {
        _isPlusButtonActive = true;
      }
    }
    setState(() {});
  }

  void _validateInput(String input) {
    if (input != '' && input != '-') {
      if (int.parse(input) < widget.min) {
        input = widget.min.toString();
      } else {
        if (int.parse(input) > widget.max) {
          input = widget.max.toString();
        }
      }
    } else {
      input = widget.defaultValue.toString();
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
                semanticLabel: l10n.commonSemanticLabelMinusButton,
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
                  label: l10n.commonSemanticLabelInput(widget.label),
                  child: TextFormField(
                    controller: _valueController,
                    keyboardType: TextInputType.numberWithOptions(signed: widget.allowNegativeNumbers),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'^-?(\d*)')),
                      FilteringTextInputFormatter.deny(RegExp('^0+(?=.)')),
                      FilteringTextInputFormatter.deny(RegExp('^-0+'), replacementString: '-'),
                    ],
                    maxLength:
                        _valueController.value.text.contains('-')
                            ? widget.min.toString().length
                            : widget.max.toString().length,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: ColorTheme.primary)),
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: ColorTheme.primary)),
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
                semanticLabel: l10n.commonSemanticLabelPlusButton,
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
