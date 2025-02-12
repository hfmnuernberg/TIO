// Number Input of type int consisting of +/- buttons and a manual input

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/shapes.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

class NumberInput extends StatefulWidget {
  final int max;
  final int min;
  final int defaultValue;
  final int step;
  final TextEditingController controller;
  final int countingStepsInMilliseconds;
  final String descriptionText;
  final double buttonRadius;
  final double buttonGap;
  final double relIconSize;
  final double textFieldWidth;
  final double textFontSize;

  const NumberInput({
    super.key,
    required this.max,
    required this.min,
    required this.defaultValue,
    required this.step,
    required this.controller,
    required this.countingStepsInMilliseconds,
    required this.descriptionText,
    required this.buttonRadius,
    required this.buttonGap,
    required this.relIconSize ,
    required this.textFieldWidth ,
    required this.textFontSize,
  });

  @override
  State<NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends State<NumberInput> {
  bool _isPlusButtonActive = true;
  bool _isMinusButtonActive = true;
  late TextEditingController _valueController;
  Timer? _decreaseTimer;
  Timer? _increaseTimer;

  // Initialize variables
  @override
  void initState() {
    super.initState();
    widget.controller.value = widget.controller.value.copyWith(text: widget.defaultValue.toString());
    _valueController = TextEditingController(text: widget.defaultValue.toString());

    widget.controller.addListener(_onExternalChange);
  }

  // Dispose variables
  @override
  void dispose() {
    _decreaseTimer?.cancel();
    _increaseTimer?.cancel();
    super.dispose();
  }

  // Handle external changes of the displayed text
  void _onExternalChange() {
    _validateInput(widget.controller.value.text);
  }

  // Decrease the currently displayed value
  void _decreaseValue() {
    if (_valueController.value.text != '') {
      _valueController.value = _valueController.value
          .copyWith(text: (int.parse(_valueController.value.text) - widget.step).toString());
      _manageButtonActivity(_valueController.value.text);
      _validateInput(_valueController.value.text);
    }
  }

  // Increase the currently displayed value
  void _increaseValue() {
    if (_valueController.value.text != '') {
      _valueController.value = _valueController.value
          .copyWith(text: (int.parse(_valueController.value.text) + widget.step).toString());
      _manageButtonActivity(_valueController.value.text);
      _validateInput(_valueController.value.text);
    }
  }

  // Looped decrease
  void _startDecreaseTimer() {
    _decreaseTimer = Timer.periodic(Duration(milliseconds: widget.countingStepsInMilliseconds), (timer) {
      _decreaseValue();
    });
  }

  // Looped increase
  void _startIncreaseTimer() {
    _increaseTimer = Timer.periodic(Duration(milliseconds: widget.countingStepsInMilliseconds), (timer) {
      _increaseValue();
    });
  }

  // Stop looped decrease
  void _endDecreaseTimer() {
    _decreaseTimer?.cancel();
  }

  // Stop looped increase
  void _endIncreaseTimer() {
    _increaseTimer?.cancel();
  }

  // Check if plus and minus buttons should be active or inactive
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

  // Check if submitted input is valid
  void _validateInput(String input) {
    if (input != '' && input != '-') {
      // Check for min/max values
      if (int.parse(input) < widget.min) {
        input = widget.min.toString();
      } else {
        if (int.parse(input) > widget.max) {
          input = widget.max.toString();
        }
      }
    } else {
      // Set default value when input is no number
      input = widget.defaultValue.toString();
    }
    _valueController.value = _valueController.value.copyWith(text: input);
    widget.controller.value = widget.controller.value.copyWith(text: input);
    setState(() {});
  }

  // Main build
  @override
  Widget build(BuildContext context) {
    return Column(
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
                      ? widget.min.toString().length
                      : widget.max.toString().length,
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
      ],
    );
  }
}
