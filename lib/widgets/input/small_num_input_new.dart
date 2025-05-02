import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/shapes.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

class SmallNumInputNew extends StatefulWidget {
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
  final double textFontSize;
  final List<int>? validValues;

  const SmallNumInputNew({
    super.key,
    required this.maxValue,
    required this.minValue,
    required this.defaultValue,
    required this.countingValue,
    required this.displayText,
    this.countingIntervalMs = 100,
    this.descriptionText = '',
    this.buttonRadius = 25,
    this.buttonGap = 4,
    this.relIconSize = 0.4,
    this.textFontSize = 40,
    this.validValues,
  });

  @override
  State<SmallNumInputNew> createState() => _SmallNumInputNewState();
}

class _SmallNumInputNewState extends State<SmallNumInputNew> {
  bool _isPlusButtonActive = true;
  bool _isMinusButtonActive = true;
  late TextEditingController _valueController;
  Timer? _decreaseTimer;
  Timer? _increaseTimer;

  @override
  void initState() {
    super.initState();
    widget.displayText.value = widget.displayText.value.copyWith(text: widget.defaultValue.toString());
    _valueController = TextEditingController(text: widget.defaultValue.toString());

    widget.displayText.addListener(_onExternalChange);
  }

  @override
  void dispose() {
    _decreaseTimer?.cancel();
    _increaseTimer?.cancel();
    super.dispose();
  }

  void _onExternalChange() {
    _validateInput(widget.displayText.value.text);
  }

  void _updateControllers(int newValue) {
    final valueStr = newValue.toString();
    _valueController.text = valueStr;
    widget.displayText.text = valueStr;
    _manageButtonActivity(valueStr);
    setState(() {});
  }

  void _decreaseValue() {
    final current = int.tryParse(_valueController.text) ?? widget.defaultValue;
    final values = widget.validValues;

    if (values != null && values.isNotEmpty) {
      final reversed = values.reversed.toList();
      final index = reversed.indexWhere((v) => v < current);
      if (index != -1) {
        final prev = reversed[index];
        _updateControllers(prev);
      }
    } else {
      final prev = current - widget.countingValue;
      if (prev >= widget.minValue) {
        _updateControllers(prev);
      }
    }
  }

  void _increaseValue() {
    final current = int.tryParse(_valueController.text) ?? widget.defaultValue;
    final values = widget.validValues;

    if (values != null && values.isNotEmpty) {
      final index = values.indexWhere((v) => v > current);
      if (index != -1) {
        final next = values[index];
        _updateControllers(next);
      }
    } else {
      final next = current + widget.countingValue;
      if (next <= widget.maxValue) {
        _updateControllers(next);
      }
    }
  }

  void _startDecreaseTimer() {
    _decreaseTimer = Timer.periodic(Duration(milliseconds: widget.countingIntervalMs), (timer) {
      _decreaseValue();
    });
  }

  void _startIncreaseTimer() {
    _increaseTimer = Timer.periodic(Duration(milliseconds: widget.countingIntervalMs), (timer) {
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

  void _validateInput(String input) {
    int val = int.tryParse(input) ?? widget.defaultValue;

    if (widget.validValues != null && widget.validValues!.isNotEmpty) {
      if (!widget.validValues!.contains(val)) {
        val = widget.validValues!.first;
      }
    } else {
      if (val < widget.minValue) val = widget.minValue;
      if (val > widget.maxValue) val = widget.maxValue;
    }

    _updateControllers(val);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // number displayed
        Text(_valueController.value.text, style: TextStyle(fontSize: widget.textFontSize, color: ColorTheme.primary)),

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
                  fixedSize: Size(widget.buttonRadius, widget.buttonRadius),
                ),
                icon: Icon(Icons.remove, size: widget.buttonRadius * widget.relIconSize * 2),
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
                  fixedSize: Size(widget.buttonRadius, widget.buttonRadius),
                ),
                icon: Icon(Icons.add, size: widget.buttonRadius * widget.relIconSize * 2),
              ),
            ),
          ],
        ),
        // description
        Text(widget.descriptionText, style: const TextStyle(color: ColorTheme.primary)),
      ],
    );
  }
}
