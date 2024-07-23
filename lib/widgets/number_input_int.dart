// Number Input of type int consisting of +/- buttons and a manual input

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tiomusic/util/shapes.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'dart:async';

import 'package:tiomusic/widgets/confirm_setting_button.dart';

class NumberInputInt extends StatefulWidget {
  final int maxValue;
  final int minValue;
  final int defaultValue;
  final int countingValue;
  final TextEditingController displayText;
  final int countingIntervalMs;
  final String descriptionText;
  final double buttonRadius;
  final double buttonGap;
  final double relIconSize;
  final double textFieldWidth;
  final double textFontSize;

  const NumberInputInt({
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
    this.relIconSize = 0.4,
    this.textFieldWidth = 100,
    this.textFontSize = 40,
  });

  @override
  State<NumberInputInt> createState() => _NumberInputIntState();
}

class _NumberInputIntState extends State<NumberInputInt> {
  bool _isPlusButtonActive = true;
  bool _isMinusButtonActive = true;
  late TextEditingController _valueController;
  late Timer _decreaseTimer;
  late Timer _increaseTimer;
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

    _sliderDivisions = (widget.maxValue - widget.minValue) ~/ widget.countingValue;
    _sliderValue = widget.defaultValue.toDouble();

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

  // Decrease the currently displayed value
  void _decreaseValue() {
    if (_valueController.value.text != '') {
      _valueController.value = _valueController.value
          .copyWith(text: (int.parse(_valueController.value.text) - widget.countingValue).toString());
      _manageButtonActivity(_valueController.value.text);
      _validateInput(_valueController.value.text);
    }
  }

  // Increase the currently displayed value
  void _increaseValue() {
    if (_valueController.value.text != '') {
      _valueController.value = _valueController.value
          .copyWith(text: (int.parse(_valueController.value.text) + widget.countingValue).toString());
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
    if (input != '' && input != '-') {
      if (int.parse(input) <= widget.minValue) {
        _isMinusButtonActive = false;
      } else {
        _isMinusButtonActive = true;
      }
      if (int.parse(input) >= widget.maxValue) {
        _isPlusButtonActive = false;
      } else {
        _isPlusButtonActive = true;
      }
    }
    setState(() {});
  }

  // Check if submitted input is valid
  void _validateInput(String input) {
    if (input != '' && input != '-') {
      // Check for min/max values
      if (int.parse(input) < widget.minValue) {
        input = widget.minValue.toString();
      } else {
        if (int.parse(input) > widget.maxValue) {
          input = widget.maxValue.toString();
        }
      }
    } else {
      // Set default value when input is no number
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
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    // Allow only positive and negative integers
                    FilteringTextInputFormatter.allow(RegExp(r'^-?(\d*)')),
                    // Delete leading zeros
                    FilteringTextInputFormatter.deny(RegExp(r'^0+(?=.)')),
                    // Delete zero after sign
                    FilteringTextInputFormatter.deny(RegExp(r'^-0+'), replacementString: '-'),
                  ],
                  maxLength: _valueController.value.text.contains('-')
                      ? widget.minValue.toString().length
                      : widget.maxValue.toString().length,
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
            min: widget.minValue.toDouble(),
            max: widget.maxValue.toDouble(),
            divisions: _sliderDivisions,
            label: _valueController.text,
            onChanged: (newValue) {
              _sliderValue = double.parse(newValue.toStringAsFixed(0));
              var intValue = _sliderValue.toInt();
              _manageButtonActivity(intValue.toString());
              setState(() {
                _valueController.value = _valueController.value.copyWith(text: intValue.toString());
                _validateInput(_valueController.text);
              });
            },
          ),
        ),
      ],
    );
  }
}
