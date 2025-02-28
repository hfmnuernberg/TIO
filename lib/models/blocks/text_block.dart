import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/util/util_functions.dart';

part 'text_block.g.dart';

// ignore_for_file: must_be_immutable // FIXME: fix these block issues

@JsonSerializable()
class TextBlock extends ProjectBlock {
  // this check is only used for quick tools at the moment
  @override
  List<Object> get props => [];

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

  late String _content;
  @JsonKey(defaultValue: TextParams.defaultContent)
  String get content => _content;
  set content(String newContent) {
    _content = newContent;
    notifyListeners();
  }

  @override
  List<String> getSettingsFormatted() {
    if (_content.characters.length < 50) {
      return [_content.toString().trim()];
    } else {
      return ["${_content.characters.take(50).toString().trim()}..."];
    }
  }

  TextBlock(String title, String id, String? islandToolID, String content, DateTime timeLastModified) {
    _timeLastModified = timeLastModified;
    _content = content;
    _title = title;
    _id = ProjectBlock.getIdOrCreateNewId(id);
    _islandToolID = islandToolID;
  }

  TextBlock.withDefaults() {
    _timeLastModified = DateTime.now();
    _content = TextParams.defaultContent;
    _title = TextParams.displayName;
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
  get icon => blockTypeInfos[BlockType.text]!.icon;

  factory TextBlock.fromJson(Map<String, dynamic> json) => _$TextBlockFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TextBlockToJson(this);
}
