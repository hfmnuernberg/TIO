import 'package:flutter/foundation.dart';

class ActiveReferenceSoundButton with ChangeNotifier {
  int buttonIdx = 0;
  bool buttonOn = false;
  double freq = 0;

  void turnOff() {
    buttonOn = false;
    notifyListeners();
  }

  void turnOn(int idx, double frequency) {
    buttonOn = true;
    buttonIdx = idx;
    freq = frequency;
    notifyListeners();
  }
}
