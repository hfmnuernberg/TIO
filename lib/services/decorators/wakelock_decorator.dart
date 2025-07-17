import 'package:tiomusic/services/wakelock.dart';
import 'package:tiomusic/util/log.dart';

class WakelockDecorator implements Wakelock {
  static final _logger = createPrefixLogger('Wakelock');

  final Wakelock _wakelock;

  WakelockDecorator(this._wakelock);

  @override
  Future<void> enable() async {
    _logger.t('enable()');
    await _wakelock.enable();
  }

  @override
  Future<void> disable() async {
    _logger.t('disable()');
    await _wakelock.disable();
  }
}
