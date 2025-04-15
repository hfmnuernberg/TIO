enum SoundFont {
  piano1('piano_01.sf2'),
  piano2('piano_02.sf2'),
  electricPiano1('electric_piano_01.sf2'),
  electricPiano2('electric_piano_02.sf2'),
  pipeOrgan('pipe_organ.sf2'),
  harpsicord('harpsichord.sf2');

  const SoundFont(this.filename);

  final String filename;

  String get file => 'assets/sound_fonts/$filename';
}
