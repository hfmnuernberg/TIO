import 'package:tiomusic/services/audio_session.dart';
import 'package:tiomusic/util/log.dart';

class AudioSessionLogDecorator implements AudioSession {
  static final _logger = createPrefixLogger('AudioSession');

  final AudioSession _as;

  AudioSessionLogDecorator(this._as);

  @override
  Future<bool> start() async {
    final result = await _as.start();
    _logger.t('start(): $result');
    return result;
  }

  @override
  Future<bool> stop() async {
    final result = await _as.stop();
    _logger.t('stop(): $result');
    return result;
  }

  @override
  Future<void> preparePlayback() async {
    await _as.preparePlayback();
    _logger.t('preparePlayback()');
  }

  @override
  Future<void> prepareRecording() async {
    await _as.prepareRecording();
    _logger.t('prepareRecording()');
  }

  @override
  Future<AudioSessionInterruptionListenerHandle> registerInterruptionListener(
    AudioSessionInterruptionCallback onInterrupt,
  ) async {
    final result = await _as.registerInterruptionListener(onInterrupt);
    _logger.t('registerInterruptionListener(onInterrupt): handle');
    return result;
  }

  @override
  Future<void> unregisterInterruptionListener(AudioSessionInterruptionListenerHandle handle) async {
    await _as.unregisterInterruptionListener(handle);
    _logger.t('unregisterInterruptionListener(handle)');
  }
}
