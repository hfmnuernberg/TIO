import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tiomusic/l10n/app_localization.dart';
import 'package:tiomusic/models/metronome_sound.dart';
import 'package:tiomusic/util/l10n/metronome_sound_extension.dart';

import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/rhythm_group.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';

part 'metronome_block.g.dart';

// ignore_for_file: must_be_immutable // FIXME: fix these block issues
// ignore_for_file: deprecated_member_use_from_same_package // FIXME: fix these block issues

@JsonSerializable()
class MetronomeBlock extends ProjectBlock {
  // add here all the fields that should be compared when checking if two class instances have the same values
  // for now this check is only used to compare quick tools to the default settings, so some properties are left out here
  @override
  List<Object> get props => [
    _id,
    bpm,
    randomMute,
    _rhythmGroups,
    _rhythmGroups2,
    accSound,
    unaccSound,
    polyAccSound,
    polyUnaccSound,
    accSound2,
    unaccSound2,
    polyAccSound2,
    polyUnaccSound2,
    _volume,
  ];

  @override
  @JsonKey(defaultValue: MetronomeParams.kind, includeFromJson: false, includeToJson: true)
  String get kind => MetronomeParams.kind;

  late String _title;
  @override
  @JsonKey(defaultValue: MetronomeParams.displayName)
  String get title => _title;
  @override
  set title(String newTitle) {
    _title = newTitle;
    notifyListeners();
  }

  late DateTime _timeLastModified;
  @override
  @JsonKey(defaultValue: getCurrentDateTime)
  DateTime get timeLastModified => _timeLastModified;
  @override
  set timeLastModified(DateTime newTime) {
    _timeLastModified = newTime;
  }

  late String _id;
  @override
  @JsonKey(defaultValue: '')
  String get id => _id;
  @override
  set id(String newID) {
    _id = newID;
    notifyListeners();
  }

  late String? _islandToolID;
  @override
  @JsonKey(defaultValue: null)
  String? get islandToolID => _islandToolID;
  @override
  set islandToolID(String? newToolID) {
    _islandToolID = newToolID;
    notifyListeners();
  }

  late double _volume;
  @JsonKey(defaultValue: TIOMusicParams.defaultVolume)
  double get volume => _volume;
  set volume(double newValue) {
    _volume = newValue;
    notifyListeners();
  }

  @JsonKey(defaultValue: MetronomeParams.defaultBPM)
  late int bpm;
  @JsonKey(defaultValue: MetronomeParams.defaultRandomMute)
  late int randomMute;

  @JsonKey(defaultValue: defaultMetronomeAccSound)
  late String accSound;
  @JsonKey(defaultValue: defaultMetronomeUnaccSound)
  late String unaccSound;
  @JsonKey(defaultValue: defaultMetronomePolyAccSound)
  late String polyAccSound;
  @JsonKey(defaultValue: defaultMetronomePolyUnaccSound)
  late String polyUnaccSound;

  @JsonKey(defaultValue: defaultMetronomeAccSound2)
  late String accSound2;
  @JsonKey(defaultValue: defaultMetronomeUnaccSound2)
  late String unaccSound2;
  @JsonKey(defaultValue: defaultMetronomePolyAccSound2)
  late String polyAccSound2;
  @JsonKey(defaultValue: defaultMetronomePolyUnaccSound2)
  late String polyUnaccSound2;

  late List<RhythmGroup> _rhythmGroups;
  @JsonKey(includeFromJson: true, includeToJson: true, defaultValue: [])
  List<RhythmGroup> get rhythmGroups => _rhythmGroups;
  set rhythmGroups(List<RhythmGroup> newValue) {
    _rhythmGroups = newValue;
    notifyListeners();
  }

  late List<RhythmGroup> _rhythmGroups2;
  @JsonKey(includeFromJson: true, includeToJson: true, defaultValue: [])
  List<RhythmGroup> get rhythmGroups2 => _rhythmGroups2;
  set rhythmGroups2(List<RhythmGroup> newValue) {
    _rhythmGroups2 = newValue;
    notifyListeners();
  }

  //----------------------------------------------------

  void changeRhythmOrder(int oldIdx, int newIdx, List<RhythmGroup> rhythm) {
    RhythmGroup currentGroup = rhythm[oldIdx];
    rhythm.removeAt(oldIdx);
    rhythm.insert(oldIdx < newIdx ? newIdx - 1 : newIdx, currentGroup);
    notifyListeners();
  }

  @override
  List<String> getSettingsFormatted(AppLocalizations l10n) {
    List<String> settings = [];

    if (_rhythmGroups2.isNotEmpty) {
      settings.add('_____ 1 _____');
    }

    settings.addAll([
      l10n.metronomeSegment(_rhythmGroups.length),
      '${l10n.metronomeSound}: ${MetronomeSound.fromFilename(accSound).getLabel(l10n)}/${MetronomeSound.fromFilename(unaccSound).getLabel(l10n)}',
      '${l10n.metronomeSoundPoly}: ${MetronomeSound.fromFilename(polyAccSound).getLabel(l10n)}/${MetronomeSound.fromFilename(polyUnaccSound).getLabel(l10n)}',
    ]);

    if (_rhythmGroups2.isNotEmpty) {
      settings.addAll([
        '_____ 2 _____',
        l10n.metronomeSegment(_rhythmGroups2.length),
        '${l10n.metronomeSound}: ${MetronomeSound.fromFilename(accSound2).getLabel(l10n)}/${MetronomeSound.fromFilename(unaccSound2).getLabel(l10n)}',
        '${l10n.metronomeSoundPoly}: ${MetronomeSound.fromFilename(polyAccSound2).getLabel(l10n)}/${MetronomeSound.fromFilename(polyUnaccSound2).getLabel(l10n)}',
      ]);
    }

    settings.addAll(['$bpm ${l10n.commonBpm}']);

    if (randomMute > 0) {
      settings.add('$randomMute% ${l10n.metronomeRandomMuteChance}');
    }

    return settings;
  }

  MetronomeBlock(
    String title,
    String id,
    String? islandToolID,
    this.bpm,
    this.randomMute,
    List<RhythmGroup> rhythmGroups,
    List<RhythmGroup> rhythmGroups2,
    this.accSound,
    this.unaccSound,
    this.polyAccSound,
    this.polyUnaccSound,
    this.accSound2,
    this.unaccSound2,
    this.polyAccSound2,
    this.polyUnaccSound2,
    DateTime timeLastModified,
    double volume,
  ) {
    _timeLastModified = timeLastModified;
    _title = title;
    _rhythmGroups = rhythmGroups;
    _rhythmGroups2 = rhythmGroups2;
    _islandToolID = islandToolID;
    _id = ProjectBlock.getIdOrCreateNewId(id);
    _volume = volume;
  }

  MetronomeBlock.withDefaults(AppLocalizations l10n) {
    _timeLastModified = DateTime.now();
    _title = l10n.metronome;
    _islandToolID = null;
    _volume = TIOMusicParams.defaultVolume;
    bpm = MetronomeParams.defaultBPM;
    randomMute = MetronomeParams.defaultRandomMute;
    resetPrimaryMetronome();
    resetSecondaryMetronome();
    _id = ProjectBlock.createNewId();
  }

  MetronomeBlock.withTitle(String newTitle) {
    _timeLastModified = DateTime.now();
    _title = newTitle;
    _islandToolID = null;
    _volume = TIOMusicParams.defaultVolume;
    bpm = MetronomeParams.defaultBPM;
    randomMute = MetronomeParams.defaultRandomMute;
    resetPrimaryMetronome();
    resetSecondaryMetronome();
    _id = ProjectBlock.createNewId();
  }

  // this method is for copying the class.
  // it is only needed for the metronome class so far, because of the RhythmGroup class.
  // the other blocks can just use the json conversion for copying.
  factory MetronomeBlock.from(MetronomeBlock blockToCopy) {
    return MetronomeBlock(
      blockToCopy.title,
      blockToCopy.id,
      blockToCopy.islandToolID,
      blockToCopy.bpm,
      blockToCopy.randomMute,
      blockToCopy._rhythmGroups,
      blockToCopy._rhythmGroups2,
      blockToCopy.accSound,
      blockToCopy.unaccSound,
      blockToCopy.polyAccSound,
      blockToCopy.polyUnaccSound,
      blockToCopy.accSound2,
      blockToCopy.unaccSound2,
      blockToCopy.polyAccSound2,
      blockToCopy.polyUnaccSound2,
      blockToCopy.timeLastModified,
      blockToCopy.volume,
    );
  }

  void resetPrimaryMetronome() {
    _rhythmGroups = [
      RhythmGroup(
        MetronomeParams.defaultId,
        MetronomeParams.defaultBeats,
        MetronomeParams.defaultPolyBeats,
        MetronomeParams.defaultNoteKey,
      ),
    ];
    accSound = defaultMetronomeAccSound;
    unaccSound = defaultMetronomeUnaccSound;
    polyAccSound = defaultMetronomePolyAccSound;
    polyUnaccSound = defaultMetronomePolyUnaccSound;
  }

  void resetSecondaryMetronome() {
    rhythmGroups2 = [];
    accSound2 = defaultMetronomeAccSound2;
    unaccSound2 = defaultMetronomeUnaccSound2;
    polyAccSound2 = defaultMetronomePolyAccSound2;
    polyUnaccSound2 = defaultMetronomePolyUnaccSound2;
  }

  @override
  Widget get icon => MetronomeParams.icon;

  bool get isSimpleModeSupported =>
      _rhythmGroups2.isEmpty && _rhythmGroups.length == 1 && rhythmGroups[0].rhythm != null;

  factory MetronomeBlock.fromJson(Map<String, dynamic> json) => _$MetronomeBlockFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MetronomeBlockToJson(this);
}
