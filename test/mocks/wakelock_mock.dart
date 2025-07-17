import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/services/wakelock.dart';

class WakelockMock extends Mock implements Wakelock {
  WakelockMock() {
    mockEnable();
    mockDisable();
  }

  void mockEnable() => when(enable).thenAnswer((_) async {});

  void mockDisable() => when(disable).thenAnswer((_) async {});
}
