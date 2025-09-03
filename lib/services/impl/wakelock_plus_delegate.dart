import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:tiomusic/services/wakelock.dart';

class WakelockPlusDelegate implements Wakelock {
  @override
  Future<void> enable() async => WakelockPlus.enable();

  @override
  Future<void> disable() async => WakelockPlus.disable();
}
