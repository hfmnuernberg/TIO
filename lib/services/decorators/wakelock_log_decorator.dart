import 'package:tiomusic/services/wakelock.dart';
import 'package:tiomusic/util/log.dart';

class WakelockLogDecorator implements Wakelock {
  static final _logger = createPrefixLogger('Wakelock');

  final Wakelock _wakelock;

  WakelockLogDecorator(this._wakelock);

  @override
  Future<void> enable() async {
    await _wakelock.enable();
    _logger.t('enable()');
  }

  @override
  Future<void> disable() async {
    await _wakelock.disable();
    _logger.t('disable()');
  }
}
