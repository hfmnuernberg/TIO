typedef AudioSessionInterruptionCallback = void Function();

mixin AudioSessionInterruptionListenerHandle {
  Future<void> cancel();
}

mixin AudioSession {
  Future<bool> start();
  Future<bool> stop();

  Future<void> preparePlayback();
  Future<void> prepareRecording();

  Future<AudioSessionInterruptionListenerHandle> registerInterruptionListener(
    AudioSessionInterruptionCallback onInterrupt,
  );
  Future<void> unregisterInterruptionListener(AudioSessionInterruptionListenerHandle handle);
}
