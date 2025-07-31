import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tiomusic/l10n/app_localization.dart';
import 'package:tiomusic/models/blocks/image_block.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/blocks/piano_block.dart';
import 'package:tiomusic/models/blocks/tuner_block.dart';
import 'package:tiomusic/models/blocks/text_block.dart';
import 'package:tiomusic/models/note_handler.dart';

import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:uuid/uuid.dart';

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

  static const List<String> audioFormats = ['wav', 'aiff', 'mp3', 'ogg', 'flac', 'm4a'];
}

//---------------------------------------------
// IMAGE
//---------------------------------------------

class ImageParams {
  static const String kind = 'image';
  static const String displayName = 'Image';

  static const String defaultPath = '';

  static const Icon icon = Icon(Icons.image_outlined, color: ColorTheme.primary);
}

//---------------------------------------------
// MEDIA PLAYER
//---------------------------------------------

class MediaPlayerParams {
  static const String kind = 'media_player';
  static const String displayName = 'Media Player';

  static const double defaultPitchSemitones = 0;
  static const double defaultSpeedFactor = 1;
  static const double defaultRangeStart = 0;
  static const double defaultRangeEnd = 1;
  static const String defaultPath = '';
  static const bool defaultLooping = false;
  static const bool defaultLoopingAll = false;

  static const double binWidth = 8;

  static const double markerIconSize = 36;

  static const Icon icon = Icon(Icons.play_arrow, color: ColorTheme.primary);
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
// METRONOME
//---------------------------------------------

class MetronomeParams {
  static const Uuid _uuid = Uuid();

  static const String kind = 'metronome';
  static const String displayName = 'Metronome';

  static const String svgIconPath = 'assets/icons/Metronome.svg';

  // General parameters

  // Default BPM value
  static const int defaultBPM = 80;
  // Default random mute value
  static const int defaultRandomMute = 0;
  // Default rhythm
  static const String defaultId = '';
  // this function should be called in the constructor of the RhythmGroup class, to turn the empty string into a unique id
  static String getNewKeyID() {
    return _uuid.v4();
  }

  static const List<BeatType> defaultBeats = [
    BeatType.Accented,
    BeatType.Unaccented,
    BeatType.Unaccented,
    BeatType.Unaccented,
  ];
  static const List<BeatTypePoly> defaultPolyBeats = [];
  static const String defaultNoteKey = NoteValues.quarter;

  // Maximum BPM value
  static const int maxBPM = 500;
  // Minimum BPM value
  static const int minBPM = 10;

  // BPM input

  // Button radius
  static const double plusMinusButtonRadius = 20;
  // Text font size
  static const double numInputTextFontSize = 32;

  // Size of blinking circle
  static const double blinkingCircleRadius = 5;
  // Size of Rhythm Segments
  static const double rhythmSegmentSize = 48;
  // Maximum number of beats
  static const int maxBeatCount = 20;
  // Button radius in popup window
  static const double popupButtonRadius = 20;
  // Text font size in popup window
  static const double popupTextFontSize = 30;

  static const double heightRhythmGroups = 110;

  static SvgPicture icon = SvgPicture.asset(
    svgIconPath,
    colorFilter: const ColorFilter.mode(ColorTheme.primary, BlendMode.srcIn),
  );
}

//---------------------------------------------
// PIANO
//---------------------------------------------

class PianoParams {
  static const String kind = 'piano';
  static const String displayName = 'Piano';

  static const int defaultKeyboardPosition = 60;

  // the lowest and highest midi notes should be white keys
  static const int lowestMidiNote = 21;
  static const int highestMidiNote = 108;

  static const int numberOfWhiteKeys = 12;

  static const int defaultSoundFontIndex = 0;

  static const Icon icon = Icon(Icons.piano, color: ColorTheme.primary);
}

//---------------------------------------------
// TUNER
//---------------------------------------------

class TunerParams {
  static const String kind = 'tuner';
  static const String displayName = 'Tuner';

  static const String svgIconPath = 'assets/icons/Tuner.svg';

  static const double defaultConcertPitch = 440;
  static const int freqPollMillis = 35;

  static SvgPicture icon = SvgPicture.asset(
    svgIconPath,
    colorFilter: const ColorFilter.mode(ColorTheme.primary, BlendMode.srcIn),
  );
}

//---------------------------------------------
// TEXT
//---------------------------------------------

class TextParams {
  static const String kind = 'text';
  static const String displayName = 'Text';

  static const String defaultContent = '';

  static const Icon icon = Icon(Icons.notes_rounded, color: ColorTheme.primary);
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
