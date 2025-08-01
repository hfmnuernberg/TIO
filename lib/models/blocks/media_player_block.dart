import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart';
import 'package:tiomusic/l10n/app_localization.dart';
import 'package:tiomusic/models/loop_mode.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';

part 'media_player_block.g.dart';

// ignore_for_file: must_be_immutable // FIXME: fix these block issues
// ignore_for_file: deprecated_member_use_from_same_package // FIXME: fix these block issues

@JsonSerializable()
class MediaPlayerBlock extends ProjectBlock {
  @override
  List<Object> get props => [
    _id,
    bpm,
    _volume,
    _pitchSemitones,
    _speedFactor,
    _rangeStart,
    _rangeEnd,
    _loopMode,
    _markerPositions,
    _relativePath,
  ];

  @override
  @JsonKey(defaultValue: MediaPlayerParams.kind, includeFromJson: false, includeToJson: true)
  String get kind => MediaPlayerParams.kind;

  late String _title;
  @override
  @JsonKey(defaultValue: MediaPlayerParams.displayName)
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

  @JsonKey(defaultValue: 80)
  late int bpm;

  late double _pitchSemitones;
  @JsonKey(defaultValue: MediaPlayerParams.defaultPitchSemitones)
  double get pitchSemitones => _pitchSemitones;
  set pitchSemitones(double newValue) {
    _pitchSemitones = newValue;
    notifyListeners();
  }

  late double _speedFactor;
  @JsonKey(defaultValue: MediaPlayerParams.defaultSpeedFactor)
  double get speedFactor => _speedFactor;
  set speedFactor(double newValue) {
    _speedFactor = newValue;
    notifyListeners();
  }

  late double _rangeStart;
  @JsonKey(defaultValue: MediaPlayerParams.defaultRangeStart)
  double get rangeStart => _rangeStart;
  set rangeStart(double newValue) {
    _rangeStart = newValue;
    notifyListeners();
  }

  late double _rangeEnd;
  @JsonKey(defaultValue: MediaPlayerParams.defaultRangeEnd)
  double get rangeEnd => _rangeEnd;
  set rangeEnd(double newValue) {
    _rangeEnd = newValue;
    notifyListeners();
  }

  late LoopMode _loopMode;
  @JsonKey(defaultValue: LoopMode.none)
  LoopMode get loopMode => _loopMode;
  set loopMode(LoopMode newValue) {
    _loopMode = newValue;
    notifyListeners();
  }

  late String _relativePath;
  @JsonKey(defaultValue: MediaPlayerParams.defaultPath)
  String get relativePath => _relativePath;
  set relativePath(String newPath) {
    _relativePath = newPath;
    notifyListeners();
  }

  late List<double> _markerPositions;
  @JsonKey(defaultValue: [])
  List<double> get markerPositions => _markerPositions;

  @override
  List<String> getSettingsFormatted(AppLocalizations l10n) {
    List<String> settings = [];
    if (_relativePath.isNotEmpty) {
      settings.add(basename(_relativePath));
    }
    if (_pitchSemitones.abs() >= 0.01) {
      settings.add('${_pitchSemitones > 0 ? '↑' : '↓'} ${l10n.mediaPlayerSemitones(_pitchSemitones.round())}');
    }
    if (_speedFactor != 1) {
      settings.add('${l10n.formatNumber(_speedFactor)}x ${l10n.mediaPlayerSpeed}');
    }
    if (_rangeStart.abs() >= 0.001 || (_rangeEnd - 1.0).abs() >= 0.001) {
      settings.add('${l10n.mediaPlayerTrim} ${(_rangeStart * 100).round()}% → ${(_rangeEnd * 100).round()}%');
    }
    if (_loopMode == LoopMode.none) {
      settings.add(l10n.mediaPlayerLoopingNothing);
    }
    if (_loopMode == LoopMode.one) {
      settings.add(l10n.mediaPlayerLooping);
    }
    if (_loopMode == LoopMode.all) {
      settings.add(l10n.mediaPlayerLoopingAll);
    }
    settings.add('$bpm ${l10n.commonBpm}');
    return settings;
  }

  MediaPlayerBlock(
    String title,
    String id,
    String? islandToolID,
    this.bpm,
    double volume,
    double pitchSemitones,
    double speedFactor,
    String relativePath,
    double rangeStart,
    double rangeEnd,
    LoopMode loopMode,
    DateTime timeLastModified,
    List<double> markerPositions,
  ) {
    _timeLastModified = timeLastModified;
    _title = title;
    _islandToolID = islandToolID;
    _id = ProjectBlock.getIdOrCreateNewId(id);
    _volume = volume;
    _pitchSemitones = pitchSemitones;
    _speedFactor = speedFactor;
    _rangeStart = rangeStart;
    _rangeEnd = rangeEnd;
    _loopMode = loopMode;
    _relativePath = relativePath;
    _markerPositions = markerPositions;
  }

  MediaPlayerBlock.withDefaults(AppLocalizations l10n) {
    _timeLastModified = DateTime.now();
    _title = l10n.mediaPlayer;
    _islandToolID = null;
    _id = ProjectBlock.createNewId();
    bpm = 80;
    _volume = TIOMusicParams.defaultVolume;
    _pitchSemitones = MediaPlayerParams.defaultPitchSemitones;
    _speedFactor = MediaPlayerParams.defaultSpeedFactor;
    _relativePath = MediaPlayerParams.defaultPath;
    _rangeStart = MediaPlayerParams.defaultRangeStart;
    _rangeEnd = MediaPlayerParams.defaultRangeEnd;
    _loopMode = LoopMode.none;
    _markerPositions = [];
  }

  MediaPlayerBlock.withTitle(String newTitle) {
    _timeLastModified = DateTime.now();
    _title = newTitle;
    _islandToolID = null;
    _id = ProjectBlock.createNewId();
    bpm = 80;
    _volume = TIOMusicParams.defaultVolume;
    _pitchSemitones = MediaPlayerParams.defaultPitchSemitones;
    _speedFactor = MediaPlayerParams.defaultSpeedFactor;
    _relativePath = MediaPlayerParams.defaultPath;
    _rangeStart = MediaPlayerParams.defaultRangeStart;
    _rangeEnd = MediaPlayerParams.defaultRangeEnd;
    _loopMode = LoopMode.none;
    _markerPositions = [];
  }

  @override
  Widget get icon => MediaPlayerParams.icon;

  factory MediaPlayerBlock.fromJson(Map<String, dynamic> json) => _$MediaPlayerBlockFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MediaPlayerBlockToJson(this);
}
