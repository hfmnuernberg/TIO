const String _soundClick = 'click';
const String _soundClock = 'clock';
const String _soundPing = 'ping';
const String _soundCowbell = 'cowbell';

const String defaultMetronomeAccSound = _soundClick;
const String defaultMetronomeUnaccSound = _soundClick;
const String defaultMetronomePolyAccSound = _soundClick;
const String defaultMetronomePolyUnaccSound = _soundClick;
const String defaultMetronomeAccSound2 = _soundClock;
const String defaultMetronomeUnaccSound2 = _soundClock;
const String defaultMetronomePolyAccSound2 = _soundCowbell;
const String defaultMetronomePolyUnaccSound2 = _soundCowbell;

enum MetronomeSound {
  soundBop('bop'),
  soundClick(_soundClick),
  soundClock(_soundClock),
  soundHeart('heart'),
  soundPing(_soundPing),
  soundTick('tick'),
  soundWood('wood'),
  soundCowbell(_soundCowbell),
  soundClap('clap'),
  soundRim('rim'),
  soundBlup('blup'),
  soundDigiClick('digi click'),
  soundKick('kick'),
  soundNoise('noise'),
  soundPling('pling');

  const MetronomeSound(this.filename);

  final String filename;

  String get file => 'assets/metronome_sounds/$filename';

  static MetronomeSound fromFilename(String filename) =>
      MetronomeSound.values.firstWhere((sound) => sound.filename == filename, orElse: () => MetronomeSound.soundClick);
}
