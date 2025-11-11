import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/src/rust/api/modules/metronome.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';

import '../../utils/entities/metro_bar_matcher.dart';

mixin MetronomeMock on Mock implements AudioSystem {
  void mockMetronomeStart([bool result = true]) => when(metronomeStart).thenAnswer((_) async => result);
  void verifyMetronomeStartCalled() => verify(metronomeStart).called(1);
  void verifyMetronomeStartNeverCalled() => verifyNever(metronomeStart);

  void mockMetronomeStop([bool result = true]) => when(metronomeStop).thenAnswer((_) async => result);
  void verifyMetronomeStopCalled() => verify(metronomeStop).called(1);
  void verifyMetronomeStopNeverCalled() => verifyNever(metronomeStop);

  void mockMetronomeSetBpm([bool result = true]) =>
      when(() => metronomeSetBpm(bpm: any(named: 'bpm'))).thenAnswer((_) async => result);
  void verifyMetronomeSetBpmCalledWith(double bpm) => verify(() => metronomeSetBpm(bpm: bpm)).called(1);

  void mockMetronomeLoadFile([bool result = true]) => when(
        () => metronomeLoadFile(
      beatType: any(named: 'beatType'),
      wavFilePath: any(named: 'wavFilePath'),
    ),
  ).thenAnswer((_) async => result);

  void mockMetronomeSetRhythm([bool result = true]) => when(
        () => metronomeSetRhythm(
      bars: any(named: 'bars'),
      bars2: any(named: 'bars2'),
    ),
  ).thenAnswer((_) async => result);
  void verifyMetronomeSetRhythmCalledWith(List<MetroBar> bars, [List<MetroBar> bars2 = const []]) => verify(
        () => metronomeSetRhythm(
      bars: any(named: 'bars', that: metroBarListEquals(bars)),
      bars2: any(named: 'bars2', that: metroBarListEquals(bars2)),
    ),
  ).called(1);

  void mockMetronomePollBeatEventHappened([BeatHappenedEvent? event]) =>
      when(metronomePollBeatEventHappened).thenAnswer((_) async => event);

  void mockMetronomePollBeatEventHappenedOnce([BeatHappenedEvent? event]) {
    bool called = false;
    when(metronomePollBeatEventHappened).thenAnswer((_) async {
      if (called) {
        called = true;
        return event;
      }
      return null;
    });
  }

  void mockMetronomeSetMuted([bool result = true]) =>
      when(() => metronomeSetMuted(muted: any(named: 'muted'))).thenAnswer((_) async => result);

  void mockMetronomeSetBeatMuteChance([bool result = true]) =>
      when(() => metronomeSetBeatMuteChance(muteChance: any(named: 'muteChance'))).thenAnswer((_) async => result);
  void verifyMetronomeSetBeatMuteChanceCalledWith(double muteChance) =>
      verify(() => metronomeSetBeatMuteChance(muteChance: muteChance)).called(1);

  void mockMetronomeSetVolume([bool result = true]) =>
      when(() => metronomeSetVolume(volume: any(named: 'volume'))).thenAnswer((_) async => result);
  void verifyMetronomeSetVolumeCalledWith(double volume) => verify(() => metronomeSetVolume(volume: volume)).called(1);
}
