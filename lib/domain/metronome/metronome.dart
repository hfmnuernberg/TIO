import 'dart:async';

import 'package:tiomusic/domain/metronome/metronome_beat.dart';
import 'package:tiomusic/domain/metronome/metronome_beat_event.dart';
import 'package:tiomusic/domain/metronome/metronome_sounds.dart';
import 'package:tiomusic/models/rhythm_group.dart';
import 'package:tiomusic/services/audio_session.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/wakelock.dart';
import 'package:tiomusic/src/rust/api/modules/metronome.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';
import 'package:tiomusic/util/log.dart';

const int beatSamplingIntervalInMs = 10;
const int beatDurationInMs = 100;

typedef BeatCallback = void Function(MetronomeBeatEvent beat);

class Metronome {
  static final logger = createPrefixLogger('Metronome');

  final AudioSystem _as;
  final AudioSession _audioSession;
  final Wakelock _wakelock;

  final BeatCallback _onBeatEvent;
  final BeatCallback _onBeatStart;
  final BeatCallback _onBeatStop;

  bool _isOn = false;
  bool get isOn => _isOn;

  bool _isMute = false;
  bool get isMute => _isMute;

  final MetronomeSounds _sounds;
  MetronomeSounds get sounds => _sounds;

  MetronomeBeat _currentBeat = MetronomeBeat();
  MetronomeBeat get currentBeat => _currentBeat;

  MetronomeBeat _currentSecondaryBeat = MetronomeBeat();
  MetronomeBeat get currentSecondaryBeat => _currentSecondaryBeat;

  AudioSessionInterruptionListenerHandle? _audioSessionInterruptionListenerHandle;

  Timer? _beatDetection;

  Metronome(
    this._as,
    this._audioSession,
    FileSystem fs,
    this._wakelock, {
    BeatCallback? onBeatEvent,
    BeatCallback? onBeatStart,
    BeatCallback? onBeatStop,
  }) : _sounds = MetronomeSounds(_as, fs),
       _onBeatEvent = onBeatEvent ?? ((_) {}),
       _onBeatStart = onBeatStart ?? ((_) {}),
       _onBeatStop = onBeatStop ?? ((_) {});

  Future<void> start() async {
    if (_isOn) return;

    _audioSessionInterruptionListenerHandle = await _audioSession.registerInterruptionListener(stop);

    await _audioSession.preparePlayback();

    final success = await _as.metronomeStart();
    if (!success) return logger.e('Unable to start Metronome.');

    _beatDetection = Timer.periodic(const Duration(milliseconds: beatSamplingIntervalInMs), (t) => _checkForBeats());

    if (success) await _wakelock.enable();

    _isOn = true;
  }

  Future<void> stop() async {
    if (!_isOn) return;

    await _wakelock.disable();

    _beatDetection?.cancel();
    _beatDetection = null;

    final success = await _as.metronomeStop();
    if (!success) return logger.e('Unable to stop Metronome.');

    if (_audioSessionInterruptionListenerHandle != null) {
      _audioSession.unregisterInterruptionListener(_audioSessionInterruptionListenerHandle!);
      _audioSessionInterruptionListenerHandle = null;
    }

    _currentBeat = MetronomeBeat();
    _currentSecondaryBeat = MetronomeBeat();

    _isOn = false;
  }

  Future<void> restart() async {
    await stop();
    await start();
  }

  Future<void> setVolume(double volume) async => _as.metronomeSetVolume(volume: volume);

  Future<void> setBpm(int bpm) async => _as.metronomeSetBpm(bpm: bpm.toDouble());

  Future<void> mute() async => _isMute = await _as.metronomeSetMuted(muted: true);

  Future<void> unmute() async => _isMute = !(await _as.metronomeSetMuted(muted: false));

  Future<void> setChanceOfMuteBeat(int chanceInPercent) async =>
      _as.metronomeSetBeatMuteChance(muteChance: chanceInPercent.toDouble() / 100.0);

  Future<void> setRhythm(List<RhythmGroup> rhythmGroups, [List<RhythmGroup> secondaryRhythmGroups = const []]) async {
    _as.metronomeSetRhythm(bars: _toMetroBars(rhythmGroups), bars2: _toMetroBars(secondaryRhythmGroups));
  }

  List<MetroBar> _toMetroBars(List<RhythmGroup> rhythmGroups) =>
      rhythmGroups
          .map((group) => MetroBar(id: 0, beats: group.beats, polyBeats: group.polyBeats, beatLen: group.beatLen))
          .toList();

  Future<void> _checkForBeats() async {
    if (!_isOn) return;

    final event = await _as.metronomePollBeatEventHappened();
    if (event == null) return;
    if (event.isRandomMute) return;

    final msUntilStart = event.millisecondsBeforeStart;
    final msUntilStop = event.millisecondsBeforeStart + beatDurationInMs;

    Timer(Duration(milliseconds: msUntilStart), () => _startBeat(event));
    Timer(Duration(milliseconds: msUntilStop), () => _stopBeat(event));
  }

  void _startBeat(BeatHappenedEvent event) {
    if (!isOn) return;

    if (event.isSecondary) {
      _currentSecondaryBeat = MetronomeBeat(
        segmentIndex: event.barIndex,
        mainBeatIndex: event.isPoly ? _currentSecondaryBeat.mainBeatIndex : event.beatIndex,
        polyBeatIndex: event.isPoly ? event.beatIndex : _currentSecondaryBeat.polyBeatIndex,
      );
    } else {
      _currentBeat = MetronomeBeat(
        segmentIndex: event.barIndex,
        mainBeatIndex: event.isPoly ? _currentBeat.mainBeatIndex : event.beatIndex,
        polyBeatIndex: event.isPoly ? event.beatIndex : _currentBeat.polyBeatIndex,
      );
    }
    _onBeatEvent(MetronomeBeatEvent(isPoly: event.isPoly, isSecondary: event.isSecondary));
    _onBeatStart(MetronomeBeatEvent(isPoly: event.isPoly, isSecondary: event.isSecondary));
  }

  void _stopBeat(BeatHappenedEvent event) {
    if (!isOn) return;

    if (event.isSecondary) {
      _currentSecondaryBeat = MetronomeBeat(
        segmentIndex: event.barIndex,
        mainBeatIndex: event.isPoly ? _currentSecondaryBeat.mainBeatIndex : null,
        polyBeatIndex: event.isPoly ? null : _currentSecondaryBeat.polyBeatIndex,
      );
    } else {
      _currentBeat = MetronomeBeat(
        segmentIndex: event.barIndex,
        mainBeatIndex: event.isPoly ? _currentBeat.mainBeatIndex : null,
        polyBeatIndex: event.isPoly ? null : _currentBeat.polyBeatIndex,
      );
    }
    _onBeatEvent(MetronomeBeatEvent(isPoly: event.isPoly, isSecondary: event.isSecondary));
    _onBeatStop(MetronomeBeatEvent(isPoly: event.isPoly, isSecondary: event.isSecondary));
  }
}
