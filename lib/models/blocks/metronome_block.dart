import 'package:json_annotation/json_annotation.dart';

import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/rhythm_group.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';

part 'metronome_block.g.dart';

@JsonSerializable()
class MetronomeBlock extends ProjectBlock {
  // add here all the fields that should be compared when checking if two class instances have the same values
  // for now this check is only used to compare quick tools to the default settings, so some properties are left out here
  @override
  List<Object> get props => [
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
  @JsonKey(defaultValue: "")
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

  @JsonKey(defaultValue: MetronomeParams.defaultAccSound)
  late String accSound;
  @JsonKey(defaultValue: MetronomeParams.defaultUnaccSound)
  late String unaccSound;
  @JsonKey(defaultValue: MetronomeParams.defaultPolyAccSound)
  late String polyAccSound;
  @JsonKey(defaultValue: MetronomeParams.defaultPolyUnaccSound)
  late String polyUnaccSound;

  @JsonKey(defaultValue: MetronomeParams.defaultAccSound2)
  late String accSound2;
  @JsonKey(defaultValue: MetronomeParams.defaultUnaccSound2)
  late String unaccSound2;
  @JsonKey(defaultValue: MetronomeParams.defaultPolyAccSound2)
  late String polyAccSound2;
  @JsonKey(defaultValue: MetronomeParams.defaultPolyUnaccSound2)
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
    if (oldIdx < newIdx) {
      newIdx -= 1;
    }
    RhythmGroup currentGroup = rhythm[oldIdx];
    rhythm.removeAt(oldIdx);
    rhythm.insert(newIdx, currentGroup);
    notifyListeners();
  }

  @override
  List<String> getSettingsFormatted() {
    List<String> settings = [];

    if (_rhythmGroups2.isNotEmpty) {
      settings.add("_____ 1 _____");
    }

    settings.addAll([
      "${_rhythmGroups.length} segment${pluralSInt(_rhythmGroups.length)}",
      "Sound: $accSound/$unaccSound",
      "Poly-Sound: $polyAccSound/$polyUnaccSound",
    ]);

    if (_rhythmGroups2.isNotEmpty) {
      settings.addAll([
        "_____ 2 _____",
        "${_rhythmGroups2.length} segment${pluralSInt(_rhythmGroups2.length)}",
        "Sound: $accSound2/$unaccSound2",
        "Poly-Sound: $polyAccSound2/$polyUnaccSound2",
      ]);
    }

    settings.addAll(["$bpm bpm", "$randomMute % random mute"]);

    if (randomMute > 0) {
      settings.add("$randomMute% mute chance");
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
    _id = setIdOrNewId(id);
    _volume = volume;
  }

  MetronomeBlock.withDefaults() {
    _timeLastModified = DateTime.now();
    _title = MetronomeParams.displayName;
    _islandToolID = null;
    _volume = TIOMusicParams.defaultVolume;
    bpm = MetronomeParams.defaultBPM.toInt();
    randomMute = MetronomeParams.defaultRandomMute;
    _rhythmGroups = [
      RhythmGroup(
        MetronomeParams.defaultId,
        MetronomeParams.defaultBeats,
        MetronomeParams.defaultPolyBeats,
        MetronomeParams.defaultNoteKey,
      ),
    ];
    _rhythmGroups2 = [];
    accSound = MetronomeParams.defaultAccSound;
    unaccSound = MetronomeParams.defaultUnaccSound;
    polyAccSound = MetronomeParams.defaultPolyAccSound;
    polyUnaccSound = MetronomeParams.defaultPolyUnaccSound;
    accSound2 = MetronomeParams.defaultAccSound2;
    unaccSound2 = MetronomeParams.defaultUnaccSound2;
    polyAccSound2 = MetronomeParams.defaultPolyAccSound2;
    polyUnaccSound2 = MetronomeParams.defaultPolyUnaccSound2;
    _id = createNewId();
  }

  MetronomeBlock.withTitle(String newTitle) {
    _timeLastModified = DateTime.now();
    _title = newTitle;
    _islandToolID = null;
    _volume = TIOMusicParams.defaultVolume;
    bpm = MetronomeParams.defaultBPM.toInt();
    randomMute = MetronomeParams.defaultRandomMute;
    _rhythmGroups = [
      RhythmGroup(
        MetronomeParams.defaultId,
        MetronomeParams.defaultBeats,
        MetronomeParams.defaultPolyBeats,
        MetronomeParams.defaultNoteKey,
      ),
    ];
    _rhythmGroups2 = [];
    accSound = MetronomeParams.defaultAccSound;
    unaccSound = MetronomeParams.defaultUnaccSound;
    polyAccSound = MetronomeParams.defaultPolyAccSound;
    polyUnaccSound = MetronomeParams.defaultPolyUnaccSound;
    accSound2 = MetronomeParams.defaultAccSound2;
    unaccSound2 = MetronomeParams.defaultUnaccSound2;
    polyAccSound2 = MetronomeParams.defaultPolyAccSound2;
    polyUnaccSound2 = MetronomeParams.defaultPolyUnaccSound2;
    _id = createNewId();
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

  @override
  get icon => blockTypeInfos[BlockType.metronome]!.icon;

  factory MetronomeBlock.fromJson(Map<String, dynamic> json) => _$MetronomeBlockFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MetronomeBlockToJson(this);
}
