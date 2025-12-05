import 'package:tiomusic/util/constants/piano_constants.dart';
import 'package:tiomusic/util/util_midi.dart';
import 'package:tiomusic/widgets/piano/key_note.dart';
import 'package:tonic/tonic.dart';

List<KeyNote> createNaturals(int lowestNote) => createNotes(lowestNote).where((note) => note.isNatural).toList();

List<KeyNote> createSharps(int lowestNote) => createSharpsWithSpacing(lowestNote).nonNulls.toList();

List<KeyNote?> createSharpsWithSpacing(int lowestNote) {
  final notes = createNotes(lowestNote);
  final sharpsWithSpacing = <KeyNote?>[];
  for (final (index, note) in notes.indexed) {
    if (index >= notes.length - 1) break;
    if (!note.isNatural) continue;
    if (notes[index + 1].isNatural) {
      sharpsWithSpacing.add(null);
    } else {
      sharpsWithSpacing.add(notes[index + 1]);
    }
  }
  return sharpsWithSpacing;
}

List<KeyNote> createNotes(int lowestNote) {
  final notes = <KeyNote>[];
  int currentNote = lowestNote;
  int naturalNotesRemaining = PianoParams.numberOfWhiteKeys;
  while (naturalNotesRemaining > 0) {
    final isNatural = midiToName(currentNote).length == 1;
    if (isNatural) naturalNotesRemaining--;
    notes.add(KeyNote(note: currentNote, name: Pitch.fromMidiNumber(currentNote).toString(), isNatural: isNatural));
    currentNote++;
  }
  return notes;
}
