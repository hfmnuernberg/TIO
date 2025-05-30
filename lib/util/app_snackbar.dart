import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> Function() showSnackbar({
  required BuildContext context,
  required String message,
}) =>
    () => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        backgroundColor: ColorTheme.surfaceTint,
        behavior: SnackBarBehavior.floating,
      ),
    );
