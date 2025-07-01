import 'package:tiomusic/src/rust/api/api.dart' as rust;
import 'package:tiomusic/services/audio_system.dart';

class RustBasedAudioSystem implements AudioSystem {
  @override
  Future<bool> mediaPlayerStart() async => rust.mediaPlayerStart();
}
