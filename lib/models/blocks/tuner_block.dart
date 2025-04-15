import 'package:json_annotation/json_annotation.dart';
import 'package:tiomusic/l10n/app_localization.dart';

import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';

part 'tuner_block.g.dart';

// ignore_for_file: must_be_immutable // FIXME: fix these block issues
// ignore_for_file: deprecated_member_use_from_same_package // FIXME: fix these block issues

@JsonSerializable()
class TunerBlock extends ProjectBlock {
  // add here all the fields that should be compared when checking if two class instances have the same values
  // for now this check is only used to compare quick tools to the default settings, so some properties are left out here
  @override
  List<Object> get props => [chamberNoteHz];

  @override
  @JsonKey(defaultValue: TunerParams.kind, includeFromJson: false, includeToJson: true)
  String get kind => TunerParams.kind;

  late String _title;
  @override
  @JsonKey(defaultValue: TunerParams.displayName)
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

  late double _chamberNoteHz;
  @JsonKey(defaultValue: TunerParams.defaultConcertPitch)
  double get chamberNoteHz => _chamberNoteHz;
  set chamberNoteHz(double newChamberNoteHz) {
    _chamberNoteHz = newChamberNoteHz;
    notifyListeners();
  }

  @override
  List<String> getSettingsFormatted(AppLocalizations l10n) {
    return ['${l10n.formatDecimal(_chamberNoteHz)} Hz'];
  }

  TunerBlock(String title, String id, String? islandToolID, double chamberNoteHz, DateTime timeLastModified) {
    _timeLastModified = timeLastModified;
    _chamberNoteHz = chamberNoteHz;
    _title = title;
    _id = ProjectBlock.getIdOrCreateNewId(id);
    _islandToolID = islandToolID;
  }

  TunerBlock.withDefaults(AppLocalizations l10n) {
    _timeLastModified = DateTime.now();
    _chamberNoteHz = TunerParams.defaultConcertPitch;
    _title = l10n.tuner;
    _islandToolID = null;
    _id = ProjectBlock.createNewId();
  }

  TunerBlock.withTitle(String newTitle) {
    _timeLastModified = DateTime.now();
    _chamberNoteHz = TunerParams.defaultConcertPitch;
    _title = newTitle;
    _islandToolID = null;
    _id = ProjectBlock.createNewId();
  }

  @override
  get icon => TunerParams.icon;

  factory TunerBlock.fromJson(Map<String, dynamic> json) => _$TunerBlockFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TunerBlockToJson(this);
}
