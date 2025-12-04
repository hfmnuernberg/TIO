import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localization.dart';
import 'package:tiomusic/models/blocks/image_block.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/blocks/piano_block.dart';
import 'package:tiomusic/models/blocks/text_block.dart';
import 'package:tiomusic/models/blocks/tuner_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/util/constants/image_constants.dart';
import 'package:tiomusic/util/constants/media_player_constants.dart';
import 'package:tiomusic/util/constants/metronome_constants.dart';
import 'package:tiomusic/util/constants/piano_constants.dart';
import 'package:tiomusic/util/constants/text_constants.dart';
import 'package:tiomusic/util/constants/tuner_constants.dart';

//---------------------------------------------
// GENERAL TIO MUSIC APP
//---------------------------------------------

class TIOMusicParams {
  static const String noImagePath = '';
  static const String tiomusicIconPath = 'assets/icons/tiomusic.png';

  static const double spaceBetweenPlusButtonAndBottom = 24;
  static const double sizeBigButtons = 40;
  static const double sizeSmallButtons = 24;
  static const IconData pauseIcon = Icons.pause;

  static const double paddingOnOffButtons = 4;

  static const double defaultVolume = 0.5;

  static const double smallSpaceAboveList = 16;
  static const double bigSpaceAboveList = 32;

  static const double edgeInset = 16;

  static const double titleFontSize = 22;

  static const double textFieldWidth1Digit = 80;
  static const double textFieldWidth2Digits = 100;
  static const double textFieldWidth3Digits = 120;
  static const double textFieldWidth4Digits = 140;

  static const int millisecondsPlayPauseDebounce = 250;

  static const double beatButtonSizeBig = 32;
  static const double beatButtonSizeSmall = 28;
  static const double beatButtonSizeMainPage = 16;
  static const double beatButtonSizeIsland = 12;

  static const double beatButtonPadding = 2;

  static const double rhythmPlusButtonSize = 16;

  // media file extensions

  static const List<String> audioFormats = ['wav', 'aiff', 'mp3', 'ogg', 'flac', 'm4a', 'mid'];
}

//---------------------------------------------
// PARENT TOOL
//---------------------------------------------

class ParentToolParams {
  // Height of appBar
  static const double appBarHeight = 58;
  // Height of island
  static const double islandHeight = 78;
}

//---------------------------------------------
// BLOCK TYPE INFO
//---------------------------------------------

enum BlockType { tuner, metronome, mediaPlayer, image, piano, text }

// TODO(TIO-278): merge into BlockType enum
class BlockTypeInfo {
  BlockTypeInfo(
    this.name,
    this.kind,
    this.description,
    this.icon,
    this.createWithDefaults,
    this.createWithTitle,
    this.createFromJson,
  );

  String name;
  String kind;
  String description;

  dynamic icon;
  ProjectBlock Function(AppLocalizations) createWithDefaults;
  ProjectBlock Function(String) createWithTitle;
  ProjectBlock Function(Map<String, dynamic>) createFromJson;
}

Map<BlockType, BlockTypeInfo> getBlockTypeInfos(AppLocalizations l10n) => {
  BlockType.tuner: BlockTypeInfo(
    l10n.tuner,
    TunerParams.kind,
    l10n.tunerDescription,
    TunerParams.icon,
    TunerBlock.withDefaults,
    TunerBlock.withTitle,
    TunerBlock.fromJson,
  ),
  BlockType.metronome: BlockTypeInfo(
    l10n.metronome,
    MetronomeParams.kind,
    l10n.metronomeDescription,
    MetronomeParams.icon,
    MetronomeBlock.withDefaults,
    MetronomeBlock.withTitle,
    MetronomeBlock.fromJson,
  ),
  BlockType.mediaPlayer: BlockTypeInfo(
    l10n.mediaPlayer,
    MediaPlayerParams.kind,
    l10n.mediaPlayerDescription,
    MediaPlayerParams.icon,
    MediaPlayerBlock.withDefaults,
    MediaPlayerBlock.withTitle,
    MediaPlayerBlock.fromJson,
  ),
  BlockType.image: BlockTypeInfo(
    l10n.image,
    ImageParams.kind,
    l10n.imageDescription,
    ImageParams.icon,
    ImageBlock.withDefaults,
    ImageBlock.withTitle,
    ImageBlock.fromJson,
  ),
  BlockType.piano: BlockTypeInfo(
    l10n.piano,
    PianoParams.kind,
    l10n.pianoDescription,
    PianoParams.icon,
    PianoBlock.withDefaults,
    PianoBlock.withTitle,
    PianoBlock.fromJson,
  ),
  BlockType.text: BlockTypeInfo(
    l10n.text,
    TextParams.kind,
    l10n.textDescription,
    TextParams.icon,
    TextBlock.withDefaults,
    TextBlock.withTitle,
    TextBlock.fromJson,
  ),
};
