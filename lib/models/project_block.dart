import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tiomusic/l10n/app_localization.dart';
import 'package:tiomusic/models/blocks/image_block.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/blocks/piano_block.dart';
import 'package:tiomusic/models/blocks/text_block.dart';
import 'package:tiomusic/models/blocks/tuner_block.dart';
import 'package:tiomusic/models/icon_converter.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:uuid/uuid.dart';

part 'project_block.g.dart';

// ignore_for_file: must_be_immutable // FIXME: fix these block issues

// This is the parent class of all blocks

@JsonSerializable(createFactory: false)
abstract class ProjectBlock extends ChangeNotifier with EquatableMixin {
  String get kind;

  String get title;
  set title(String newTitle);

  // id
  String get id;
  set id(String newID);

  DateTime get timeLastModified;
  set timeLastModified(DateTime newTime);

  // Uuid object
  static const Uuid _uuid = Uuid();

  String? get islandToolID;
  set islandToolID(String? newToolID);

  @IconSerialiser()
  Widget get icon;

  ProjectBlock();

  List<String> getSettingsFormatted(AppLocalizations l10n) {
    return List.empty();
  }

  static String getIdOrCreateNewId(String id) {
    return id == '' ? _uuid.v4() : id;
  }

  static String createNewId() {
    return _uuid.v4();
  }

  factory ProjectBlock.fromJson(Map<String, dynamic> json) {
    switch (json['kind']) {
      case TunerParams.kind:
        return TunerBlock.fromJson(json);
      case MetronomeParams.kind:
        return MetronomeBlock.fromJson(json);
      case MediaPlayerParams.kind:
        return MediaPlayerBlock.fromJson(json);
      case ImageParams.kind:
        return ImageBlock.fromJson(json);
      case PianoParams.kind:
        return PianoBlock.fromJson(json);
      case TextParams.kind:
        return TextBlock.fromJson(json);
      default:
        throw "Loading blocks from Json threw error: unknown block kind: ${json['kind']}";
    }
  }

  Map<String, dynamic> toJson();
}
