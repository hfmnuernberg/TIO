import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';

Text getSnackbarTextContent(String message) => Text(message);

showSnackbar({
  required BuildContext context,
  required String message,
}) =>
    () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: getSnackbarTextContent(message),
          duration: const Duration(seconds: 5),
          backgroundColor: ColorTheme.surfaceTint,
          behavior: SnackBarBehavior.floating,
        ));
