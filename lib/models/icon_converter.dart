import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

class IconSerialiser implements JsonConverter<Widget, int> {
  const IconSerialiser();

  // Blocks derive their icon from their kind, so the serialised code point is never read back.
  @override
  Widget fromJson(int codePoint) => throw UnsupportedError('Block icons are not deserialised');

  @override
  int toJson(Widget widget) => (widget as Icon).icon!.codePoint;
}

// see this for codePoints:
// https://api.flutter.dev/flutter/material/Icons-class.html#constants
