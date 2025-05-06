import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

class IconSerialiser implements JsonConverter<Widget, int> {
  const IconSerialiser();

  @override
  Widget fromJson(int codePoint) => Icon(IconData(codePoint));

  @override
  int toJson(Widget widget) => (widget as Icon).icon!.codePoint;
}

// see this for codePoints:
// https://api.flutter.dev/flutter/material/Icons-class.html#constants
