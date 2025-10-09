import 'package:tiomusic/domain/metronome/metronome_beat.dart';
import 'package:tiomusic/models/rhythm_group.dart';
import 'package:tiomusic/src/rust/api/modules/metronome.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';

MetronomeBeat getNextBeatOnStart(BeatHappenedEvent event, MetronomeBeat currentBeat, List<RhythmGroup> rhythms) =>
    MetronomeBeat(
      segmentIndex: event.barIndex,
      mainBeatIndex: _getCurrentMainBeatIndex(event, currentBeat, rhythms),
      polyBeatIndex: _getCurrentPolyBeatIndex(event, currentBeat, rhythms),
    );

MetronomeBeat getNextBeatOnStop(BeatHappenedEvent event, MetronomeBeat currentBeat) => MetronomeBeat(
  segmentIndex: event.barIndex,
  mainBeatIndex: event.isPoly ? currentBeat.mainBeatIndex : null,
  polyBeatIndex: event.isPoly ? null : currentBeat.polyBeatIndex,
);

int? _getCurrentMainBeatIndex(BeatHappenedEvent event, MetronomeBeat currentBeat, List<RhythmGroup> rhythms) {
  if (event.isPoly) return currentBeat.mainBeatIndex;
  if (_isMainBeatMuted(event, rhythms)) return null;
  return event.beatIndex;
}

int? _getCurrentPolyBeatIndex(BeatHappenedEvent event, MetronomeBeat currentBeat, List<RhythmGroup> rhythms) {
  if (!event.isPoly) return currentBeat.polyBeatIndex;
  if (_isPolyBeatMuted(event, rhythms)) return null;
  return event.beatIndex;
}

bool _isMainBeatMuted(BeatHappenedEvent event, List<RhythmGroup> rhythms) =>
    rhythms[event.barIndex].beats[event.beatIndex] == BeatType.Muted;

bool _isPolyBeatMuted(BeatHappenedEvent event, List<RhythmGroup> rhythms) =>
    rhythms[event.barIndex].polyBeats[event.beatIndex] == BeatTypePoly.Muted;
