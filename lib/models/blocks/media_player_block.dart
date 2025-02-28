import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tiomusic/models/file_io.dart';

import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';

part 'media_player_block.g.dart';

// ignore_for_file: must_be_immutable // FIXME: fix these block issues

@JsonSerializable()
class MediaPlayerBlock extends ProjectBlock {
  @override
  List<Object> get props => [
    bpm,
    _volume,
    _pitchSemitones,
    _speedFactor,
    _rangeStart,
    _rangeEnd,
    _looping,
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

  late bool _looping;
  @JsonKey(defaultValue: MediaPlayerParams.defaultLooping)
  bool get looping => _looping;
  set looping(bool newValue) {
    _looping = newValue;
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
  List<String> getSettingsFormatted() {
    List<String> settings = [];
    if (_relativePath.isNotEmpty) {
      settings.add(FileIO.getFileName(_relativePath));
    }
    if (_pitchSemitones.abs() >= 0.01) {
      settings.add(
        "${_pitchSemitones > 0 ? "↑" : "↓"} ${_pitchSemitones.abs()} semitone${pluralSDouble(_pitchSemitones)}",
      );
    }
    if (_speedFactor != 1) {
      settings.add("${_speedFactor}x speed");
    }
    if ((_rangeStart).abs() >= 0.001 || (_rangeEnd - 1.0).abs() >= 0.001) {
      settings.add("Trim ${(_rangeStart * 100).round()}% → ${(_rangeEnd * 100).round()}%");
    }
    if (_looping) {
      settings.add("Looping");
    }
    settings.add("$bpm bpm");
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
    bool looping,
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
    _looping = looping;
    _relativePath = relativePath;
    _markerPositions = markerPositions;
  }

  MediaPlayerBlock.withDefaults() {
    _timeLastModified = DateTime.now();
    _title = MediaPlayerParams.displayName;
    _islandToolID = null;
    _id = ProjectBlock.createNewId();
    bpm = 80;
    _volume = TIOMusicParams.defaultVolume;
    _pitchSemitones = MediaPlayerParams.defaultPitchSemitones;
    _speedFactor = MediaPlayerParams.defaultSpeedFactor;
    _relativePath = MediaPlayerParams.defaultPath;
    _rangeStart = MediaPlayerParams.defaultRangeStart;
    _rangeEnd = MediaPlayerParams.defaultRangeEnd;
    _looping = MediaPlayerParams.defaultLooping;
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
    _looping = MediaPlayerParams.defaultLooping;
    _markerPositions = [];
  }

  @override
  Icon get icon => blockTypeInfos[BlockType.mediaPlayer]!.icon;

  factory MediaPlayerBlock.fromJson(Map<String, dynamic> json) => _$MediaPlayerBlockFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MediaPlayerBlockToJson(this);

  Future<bool> pickAudio(BuildContext context, ProjectLibrary projectLibrary) async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.audio);

      if (result?.files.isEmpty ?? true) return false;

      final pickedAudioFile = File(result!.files.single.path!);

      if (context.mounted) {
        final newRelativePath = await FileIO.saveFileToAppStorage(
          context,
          pickedAudioFile,
          FileIO.getFileNameWithoutExtension(pickedAudioFile.path),
          _relativePath == "" ? null : _relativePath,
          projectLibrary,
          acceptedFormats: TIOMusicParams.audioFormats,
        );

        if (newRelativePath == null) return false;

        _relativePath = newRelativePath;

        notifyListeners();
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to pick audio: $e");
      return false;
    }
    return true;
  }

  String? getFileExtension() {
    if (relativePath.isEmpty) return null;
    var split = relativePath.split(".");
    if (split.isEmpty) return null;
    return ".${split.last}";
  }
}
