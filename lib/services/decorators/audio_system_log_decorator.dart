import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/util/log.dart';

class AudioSystemLogDecorator implements AudioSystem {
  static final _logger = createPrefixLogger('AudioSystem');

  final AudioSystem _as;

  AudioSystemLogDecorator(this._as);

  @override
  Future<bool> mediaPlayerStart() {
    final result = _as.mediaPlayerStart();
    _logger.t('mediaPlayerStart(): $result');
    return result;
  }
}
