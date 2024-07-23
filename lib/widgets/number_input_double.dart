// Number Input of type double consisting of +/- buttons and a manual input

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'dart:async';
import 'dart:math';

import 'package:tiomusic/util/shapes.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

class NumberInputDouble extends StatefulWidget {
  final double maxValue;
  final double minValue;
  final double defaultValue;
  final double countingValue;
  final int countingIntervalMs;
  final TextEditingController displayText;
  final String descriptionText;
  final double buttonRadius;
  final double buttonGap;
  final double textFieldWidth;
  final double textFontSize;
  final double relIconSize;
  final bool allowNegativeNumbers;

  const NumberInputDouble({
    super.key,
    required this.maxValue,
    required this.minValue,
    required this.defaultValue,
    required this.countingValue,
    required this.displayText,
    this.countingIntervalMs = 100,
    this.descriptionText = '',
    this.buttonRadius = 25,
    this.buttonGap = 10,
    this.textFieldWidth = 100,
    this.textFontSize = 40,
    this.relIconSize = 0.4,
    this.allowNegativeNumbers = false,
  });

  @override
  State<NumberInputDouble> createState() => _NumberInputDoubleState();
}

class _NumberInputDoubleState extends State<NumberInputDouble> {
  bool _isPlusButtonActive = true;
  bool _isMinusButtonActive = true;
  late TextEditingController _valueController;
  late Timer _decreaseTimer;
  late Timer _increaseTimer;
  late int _maxDigitsLeft;
  late int _maxDigitsRight;
  late int _sliderDivisions;

  late double _sliderValue;

  // Initialize variables
  @override
  void initState() {
    super.initState();
    widget.displayText.value = widget.displayText.value.copyWith(text: widget.defaultValue.toString());
    _valueController = TextEditingController(text: widget.defaultValue.toString());
    _decreaseTimer = Timer(Duration(milliseconds: widget.countingIntervalMs), () {});
    _increaseTimer = Timer(Duration(milliseconds: widget.countingIntervalMs), () {});

    _calcMaxDigits();

    _sliderDivisions = (widget.maxValue - widget.minValue) ~/ widget.countingValue;
    _sliderValue = widget.defaultValue;

    widget.displayText.addListener(_onExternalChange);
  }

  // Dispose variables
  @override
  void dispose() {
    _decreaseTimer.cancel();
    _increaseTimer.cancel();
    super.dispose();
  }

  // Handle external changes of the displayed text
  void _onExternalChange() {
    _validateInput(widget.displayText.value.text);
  }

  // Calculate the maximum number of digits on the display according to maximum and minimum value
  void _calcMaxDigits() {
    String countingValueString = widget.countingValue.toString();
    String maxValueString = widget.maxValue.toString();
    String minValueString = widget.minValue.toString();

    int maxDigitsLeftMin =
        (minValueString.contains('.') ? minValueString.split('.')[0].length : minValueString.length) -
            (minValueString.contains('-') ? 1 : 0);
    int maxDigitsLeftMax =
        (maxValueString.contains('.') ? maxValueString.split('.')[0].length : maxValueString.length) -
            (maxValueString.contains('-') ? 1 : 0);
    _maxDigitsLeft = [maxDigitsLeftMin, maxDigitsLeftMax].reduce(max);
    _maxDigitsRight = countingValueString.contains('.') ? countingValueString.split('.')[1].length : 0;
  }

  // Decrease the currently displayed value
  void _decreaseValue() {
    if (_valueController.value.text != '') {
      _valueController.value = _valueController.value.copyWith(
          text: (double.parse(_valueController.value.text) - widget.countingValue).toStringAsFixed(_maxDigitsRight));
      _manageButtonActivity(_valueController.value.text);
      _validateInput(_valueController.value.text);
    }
  }

  // Increase the currently displayed value
  void _increaseValue() {
    if (_valueController.value.text != '') {
      _valueController.value = _valueController.value.copyWith(
          text: (double.parse(_valueController.value.text) + widget.countingValue).toStringAsFixed(_maxDigitsRight));
      _manageButtonActivity(_valueController.value.text);
      _validateInput(_valueController.value.text);
    }
  }

  // Looped decrease
  void _startDecreaseTimer() {
    _decreaseTimer = Timer.periodic(Duration(milliseconds: widget.countingIntervalMs), (timer) {
      _decreaseValue();
    });
  }

  // Looped increase
  void _startIncreaseTimer() {
    _increaseTimer = Timer.periodic(Duration(milliseconds: widget.countingIntervalMs), (timer) {
      _increaseValue();
    });
  }

  // Stop looped decrease
  void _endDecreaseTimer() {
    _decreaseTimer.cancel();
  }

  // Stop looped increase
  void _endIncreaseTimer() {
    _increaseTimer.cancel();
  }

  // Check if plus and minus buttons should be active or inactive
  void _manageButtonActivity(String input) {
    if (input != '' && input != '-' && input != '.' && input != '-.') {
      if (double.parse(input) <= widget.minValue) {
        _isMinusButtonActive = false;
      } else {
        _isMinusButtonActive = true;
      }
      if (double.parse(input) >= widget.maxValue) {
        _isPlusButtonActive = false;
      } else {
        _isPlusButtonActive = true;
      }
    }
    setState(() {});
  }

  // Check if submitted input is valid
  void _validateInput(String input) {
    if (input != '' && input != '-' && input != '.' && input != '-.') {
      if (input[0] == '.') {
        input = '0$input';
      } else {
        if (input.substring(0, 1) == '-.') {
          input = '-0${input.substring(1)}';
        }
      }
      // Check for min/max values
      if (double.parse(input) < widget.minValue) {
        input = widget.minValue.toString();
      } else {
        if (double.parse(input) > widget.maxValue) {
          input = widget.maxValue.toString();
        }
      }
    } else {
      // Set default value when input is empty
      input = widget.defaultValue.toString();
    }
    _valueController.value = _valueController.value.copyWith(text: input);
    widget.displayText.value = widget.displayText.value.copyWith(text: input);
    _sliderValue = double.parse(input);
    setState(() {});
  }

  // Main build
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Minus button
            GestureDetector(
              onLongPress: _startDecreaseTimer,
              onLongPressUp: _endDecreaseTimer,
              child: TIOFlatButton(
                onPressed:
                    (_valueController.value.text == '') ? () {} : (_isMinusButtonActive ? _decreaseValue : () {}),
                customStyle: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: const LeftButtonShape(),
                  fixedSize: Size(widget.buttonRadius * 2, widget.buttonRadius * 2),
                ),
                icon: Icon(
                  Icons.remove,
                  size: widget.buttonRadius * widget.relIconSize * 2,
                ),
              ),
            ),
            SizedBox(width: widget.buttonGap),
            // Text display
            SizedBox(
              width: widget.textFieldWidth,
              child: Focus(
                child: TextFormField(
                  controller: _valueController,
                  keyboardType: TextInputType.numberWithOptions(signed: widget.allowNegativeNumbers, decimal: true),
                  inputFormatters: <TextInputFormatter>[
                    // Allow only positive and negative doubles
                    FilteringTextInputFormatter.allow(RegExp(r'^-?(\d{0,' +
                        _maxDigitsLeft.toString() +
                        r'})[.,]?(\d{0,' +
                        _maxDigitsRight.toString() +
                        r'})')),

                    ConvertSemicolonToDot(),

                    // Delete leading zeros and zeros between sign and number
                    DeleteLeadingZeros(),
                  ],
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorTheme.primary)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorTheme.primary)),
                    counterText: '',
                  ),
                  style: TextStyle(fontSize: widget.textFontSize, color: ColorTheme.primary),
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    _manageButtonActivity(value);
                  },
                  onFieldSubmitted: (value) {
                    _validateInput(value);
                  },
                ),
                onFocusChange: (hasFocus) {
                  if (hasFocus) {
                    _valueController.value = _valueController.value.copyWith(
                        selection: TextSelection(
                      baseOffset: 0,
                      extentOffset: _valueController.value.text.length,
                    ));
                  } else {
                    _validateInput(_valueController.value.text);
                  }
                },
              ),
            ),
            SizedBox(width: widget.buttonGap),
            // Plus button
            GestureDetector(
              onLongPress: _startIncreaseTimer,
              onLongPressUp: _endIncreaseTimer,
              child: TIOFlatButton(
                onPressed: (_valueController.value.text == '') ? () {} : (_isPlusButtonActive ? _increaseValue : () {}),
                customStyle: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: const RightButtonShape(),
                  fixedSize: Size(widget.buttonRadius * 2, widget.buttonRadius * 2),
                ),
                icon: Icon(
                  Icons.add,
                  size: widget.buttonRadius * widget.relIconSize * 2,
                ),
              ),
            ),
          ],
        ),
        Text(widget.descriptionText, style: const TextStyle(color: ColorTheme.primary)),
        // slider
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Slider(
            value: _sliderValue,
            inactiveColor: ColorTheme.primary80,
            min: widget.minValue,
            max: widget.maxValue,
            divisions: _sliderDivisions,
            label: _valueController.text,
            onChanged: (newValue) {
              setState(() {
                _sliderValue = double.parse(newValue.toStringAsFixed(1));
                _manageButtonActivity(_sliderValue.toString());
                _valueController.value = _valueController.value.copyWith(text: _sliderValue.toString());
                _validateInput(_valueController.text);
              });
            },
          ),
        ),
      ],
    );
  }
}

// Custom TextInputFormatter to delete leading zeros with and without a sign
class DeleteLeadingZeros extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;
    if (RegExp(r'^-0\d').firstMatch(text) != null) {
      text = '-${text.substring(2)}';
    } else {
      if (RegExp(r'^0\d').firstMatch(text) != null) {
        text = text.substring(1);
      }
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class ConvertSemicolonToDot extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;
    if (text.contains(',')) {
      text = text.replaceAll(',', '.');
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
