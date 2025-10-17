import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum OrientationPolicy { phonePortrait, phoneLandscape }

class AppOrientation {
  static Future<void> set(BuildContext context, {required OrientationPolicy policy}) async {
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    List<DeviceOrientation> orientations;
    switch (policy) {
      case OrientationPolicy.phonePortrait:
        orientations = isTablet
            ? DeviceOrientation.values
            : const <DeviceOrientation>[DeviceOrientation.portraitUp, DeviceOrientation.portraitDown];
      case OrientationPolicy.phoneLandscape:
        orientations = isTablet
            ? DeviceOrientation.values
            : const <DeviceOrientation>[DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight];
    }

    await SystemChrome.setPreferredOrientations(orientations);
  }
}
