import 'dart:math';

double freqToMidi(double freq, double condertPitchFreq) {
  return 12.0 * (log(freq / (condertPitchFreq / 2.0)) / log(2.0)) + 57.0;
}

double midiToFreq(double midi, {double concertPitch = 440.0}) {
  return concertPitch * pow(2.0, (midi - 69.0) / 12.0);
}

String midiToName(int midi) {
  return [
    "C",
    "C#/Db",
    "D",
    "D#/Eb",
    "E",
    "F",
    "F#/Gb",
    "G",
    "G#/Ab",
    "A",
    "A#/Bb",
    "B",
  ][midi % 12];
}

String midiToNameAndOctave(int midi) {
  return "${midiToName(midi)}${(midi / 12 - 1).floor()}";
}

String midiToNameOneChar(int midi) {
  return [
    "C",
    "C#",
    "D",
    "Eb",
    "E",
    "F",
    "F#",
    "G",
    "Ab",
    "A",
    "Bb",
    "B",
  ][midi % 12];
}
