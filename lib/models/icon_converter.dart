import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

class IconSerialiser implements JsonConverter<Icon, int> {
  const IconSerialiser();

  @override
  Icon fromJson(int codePoint) => Icon(IconData(codePoint));

  @override
  int toJson(Icon icon) => icon.icon!.codePoint;
}

// see this for codePoints:
// https://api.flutter.dev/flutter/material/Icons-class.html#constants

