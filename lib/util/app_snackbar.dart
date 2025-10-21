import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _activeSnackbarController;

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> Function() showSnackbar({
  required BuildContext context,
  required String message,
}) => () {
  final messenger = ScaffoldMessenger.of(context);

  if (_activeSnackbarController != null) return _activeSnackbarController!;

  final controller = messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 5),
      backgroundColor: ColorTheme.surfaceTint,
      behavior: SnackBarBehavior.floating,
    ),
  );

  _activeSnackbarController = controller;
  controller.closed.whenComplete(() {
    if (identical(_activeSnackbarController, controller)) {
      _activeSnackbarController = null;
    }
  });

  return controller;
};
