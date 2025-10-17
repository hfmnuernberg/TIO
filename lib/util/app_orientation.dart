import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum OrientationPolicy { phonePortraitTabletFree, phoneLandscapeTabletFree }

class AppOrientation {
  static Future<void> set(BuildContext context, {required OrientationPolicy policy}) async {
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    List<DeviceOrientation> orientations;
    switch (policy) {
      case OrientationPolicy.phonePortraitTabletFree:
        orientations = isTablet
            ? DeviceOrientation.values
            : const <DeviceOrientation>[DeviceOrientation.portraitUp, DeviceOrientation.portraitDown];
      case OrientationPolicy.phoneLandscapeTabletFree:
        orientations = isTablet
            ? DeviceOrientation.values
            : const <DeviceOrientation>[DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight];
    }

    await SystemChrome.setPreferredOrientations(orientations);
  }

  static Future<void> reset() => SystemChrome.setPreferredOrientations(DeviceOrientation.values);
}
