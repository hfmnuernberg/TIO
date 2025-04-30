import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tiomusic/l10n/app_localization.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/util/util_functions.dart';

part 'text_block.g.dart';

// ignore_for_file: must_be_immutable // FIXME: fix these block issues
// ignore_for_file: deprecated_member_use_from_same_package // FIXME: fix these block issues

@JsonSerializable()
class TextBlock extends ProjectBlock {
  // this check is only used for quick tools at the moment
  @override
  List<Object> get props => [_id];

  @override
  @JsonKey(defaultValue: TextParams.kind, includeFromJson: false, includeToJson: true)
  String get kind => TextParams.kind;

  late String _title;
  @override
  @JsonKey(defaultValue: TextParams.displayName)
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

  late String _content;
  @JsonKey(defaultValue: TextParams.defaultContent)
  String get content => _content;
  set content(String newContent) {
    _content = newContent;
    notifyListeners();
  }

  @override
  List<String> getSettingsFormatted(AppLocalizations l10n) {
    if (_content.characters.length < 50) {
      return [_content.trim()];
    } else {
      return ['${_content.characters.take(50).toString().trim()}...'];
    }
  }

  TextBlock(String title, String id, String? islandToolID, String content, DateTime timeLastModified) {
    _timeLastModified = timeLastModified;
    _content = content;
    _title = title;
    _id = ProjectBlock.getIdOrCreateNewId(id);
    _islandToolID = islandToolID;
  }

  TextBlock.withDefaults(AppLocalizations l10n) {
    _timeLastModified = DateTime.now();
    _content = TextParams.defaultContent;
    _title = l10n.text;
    _islandToolID = null;
    _id = ProjectBlock.createNewId();
  }

  TextBlock.withTitle(String newTitle) {
    _timeLastModified = DateTime.now();
    _content = TextParams.defaultContent;
    _title = newTitle;
    _islandToolID = null;
    _id = ProjectBlock.createNewId();
  }

  @override
  get icon => TextParams.icon;

  factory TextBlock.fromJson(Map<String, dynamic> json) => _$TextBlockFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TextBlockToJson(this);
}
