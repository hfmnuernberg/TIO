import 'package:flutter/services.dart';

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
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
