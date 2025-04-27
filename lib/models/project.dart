import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tiomusic/models/blocks/image_block.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/blocks/piano_block.dart';
import 'package:tiomusic/models/blocks/text_block.dart';
import 'package:tiomusic/models/blocks/tuner_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/util/constants.dart';

part 'project.g.dart';

@JsonSerializable(explicitToJson: true)
class Project extends ChangeNotifier {
  late String _title;
  @JsonKey(defaultValue: 'Default Title')
  String get title => _title;
  set title(String newTitle) {
    _title = newTitle;
    notifyListeners();
  }

  late String _thumbnailPath;
  @JsonKey(defaultValue: TIOMusicParams.noImagePath)
  String get thumbnailPath => _thumbnailPath;
  set thumbnailPath(String newThumbnailPath) {
    _thumbnailPath = newThumbnailPath;
    notifyListeners();
  }

  late Map<String, int> _toolCounter;
  @JsonKey(
    defaultValue: {
      ImageParams.kind: 0,
      MediaPlayerParams.kind: 0,
      MetronomeParams.kind: 0,
      PianoParams.kind: 0,
      TextParams.kind: 0,
      TunerParams.kind: 0,
    },
  )
  Map<String, int> get toolCounter => _toolCounter;
  void increaseCounter(String toolType) {
    _toolCounter.update(
      toolType,
      (value) {
        return value + 1;
      },
      ifAbsent: () {
        return 1;
      },
    );
  }

  Future<void> setThumbnail(String relativePath) async {
    _thumbnailPath = relativePath;
    notifyListeners();
  }

  Future<void> setDefaultThumbnail() async {
    _thumbnailPath = TIOMusicParams.noImagePath;
    notifyListeners();
  }

  @JsonKey(includeFromJson: true, includeToJson: true, defaultValue: [])
  late List<ProjectBlock> _blocks;

  @JsonKey(includeFromJson: false, includeToJson: false)
  UnmodifiableListView<ProjectBlock> get blocks => UnmodifiableListView(_blocks);

  set blocks(List<ProjectBlock> newOrder) {
    _blocks = newOrder;
    notifyListeners();
  }

  late DateTime timeLastModified;

  Project(String title, this._blocks, String thumbnailPath, this.timeLastModified, Map<String, int> toolCounter) {
    _title = title;
    _thumbnailPath = thumbnailPath;
    _toolCounter = toolCounter;
  }

  Project.defaultPicture(String title) {
    timeLastModified = DateTime.now();
    _title = title;
    _toolCounter = {
      ImageParams.kind: 0,
      MediaPlayerParams.kind: 0,
      MetronomeParams.kind: 0,
      PianoParams.kind: 0,
      TextParams.kind: 0,
      TunerParams.kind: 0,
    };
    _blocks = List.empty(growable: true);
    setDefaultThumbnail();
  }

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  void removeBlock(ProjectBlock block, ProjectLibrary projectLibrary) {
    _blocks.remove(block);
    notifyListeners();
  }

  void addBlock(ProjectBlock newBlock) {
    _blocks.insert(0, newBlock);
    notifyListeners();
  }

  void clearBlocks(ProjectLibrary projectLibrary) {
    _blocks.clear();
    notifyListeners();
  }

  ProjectBlock copyTool(ProjectBlock block, String newTitle) {
    Map<String, dynamic> jsonMap = block.toJson();
    ProjectBlock newBlock;

    switch (block.kind) {
      case TunerParams.kind:
        newBlock = TunerBlock.fromJson(jsonMap);
      case MetronomeParams.kind:
        newBlock = MetronomeBlock.from(block as MetronomeBlock);
      case MediaPlayerParams.kind:
        newBlock = MediaPlayerBlock.fromJson(jsonMap);
      case ImageParams.kind:
        newBlock = ImageBlock.fromJson(jsonMap);
      case PianoParams.kind:
        newBlock = PianoBlock.fromJson(jsonMap);
      case TextParams.kind:
        newBlock = TextBlock.fromJson(jsonMap);
      default:
        throw 'Error: Failed to copy tool. Unknown block type ${block.kind}!';
    }

    // new ID, otherwise the copied tool would have the same as the original tool
    newBlock.id = ProjectBlock.createNewId();
    newBlock.title = newTitle;
    addBlock(newBlock);

    return newBlock;
  }
}
