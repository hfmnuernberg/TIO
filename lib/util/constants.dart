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

  static const List<String> audioFormats = ['.wav', '.aiff', '.mp3', '.ogg', '.flac', '.m4a'];
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

  static const int beatDetectionDurationMillis = 10;

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

  // Metronome Sound

  static const String _soundBop = 'bop';
  static const String _soundClick = 'click';
  static const String _soundClock = 'clock';
  static const String _soundHeart = 'heart';
  static const String _soundPing = 'ping';
  static const String _soundTick = 'tick';
  static const String _soundWood = 'wood';
  static const String _soundCowbell = 'cowbell';
  static const String _soundClap = 'clap';
  static const String _soundRim = 'rim';
  static const String _soundBlup = 'blup';
  static const String _soundDigiClick = 'digi click';
  static const String _soundKick = 'kick';
  static const String _soundNoise = 'noise';
  static const String _soundPling = 'pling';

  // Path to sound files
  static const String metronomeSoundsPath = 'assets/metronome_sounds';
  // Sound names
  static const List<String> metronomeSounds = [
    _soundBop,
    _soundClick,
    _soundClock,
    _soundHeart,
    _soundPing,
    _soundTick,
    _soundWood,
    _soundCowbell,
    _soundClap,
    _soundRim,
    _soundBlup,
    _soundDigiClick,
    _soundKick,
    _soundNoise,
    _soundPling,
  ];

  static getSoundFontName(AppLocalizations l10n, String metronomeSound) => switch (metronomeSound) {
    _soundBop => l10n.metronomeSoundTypeBop,
    _soundClick => l10n.metronomeSoundTypeClick,
    _soundClock => l10n.metronomeSoundTypeClock,
    _soundHeart => l10n.metronomeSoundTypeHeart,
    _soundPing => l10n.metronomeSoundTypePing,
    _soundTick => l10n.metronomeSoundTypeTick,
    _soundWood => l10n.metronomeSoundTypeWood,
    _soundCowbell => l10n.metronomeSoundTypeCowbell,
    _soundClap => l10n.metronomeSoundTypeClap,
    _soundRim => l10n.metronomeSoundTypeRim,
    _soundBlup => l10n.metronomeSoundTypeBlup,
    _soundDigiClick => l10n.metronomeSoundTypeDigiClick,
    _soundKick => l10n.metronomeSoundTypeKick,
    _soundNoise => l10n.metronomeSoundTypeNoise,
    _soundPling => l10n.metronomeSoundTypePling,
    _ => '',
  };

  static const String defaultSound = _soundClick;

  static const String defaultAccSound = _soundClick;
  static const String defaultUnaccSound = _soundClick;
  static const String defaultPolyAccSound = _soundPing;
  static const String defaultPolyUnaccSound = _soundPing;

  static const String defaultAccSound2 = _soundClock;
  static const String defaultUnaccSound2 = _soundClock;
  static const String defaultPolyAccSound2 = _soundCowbell;
  static const String defaultPolyUnaccSound2 = _soundCowbell;

  // Turn visual metronome on/off by default
  static const bool defaultVisualMetronome = false;

  // Maximum BPM value
  static const int maxBPM = 500;
  // Minimum BPM value
  static const int minBPM = 10;
  // Duration of Blackscreen in ms when visual metronome is enabled
  static const int flashDurationInMs = 100;

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
  static const int maxNumBeats = 20;
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

  static const String _soundFontPiano1 = 'assets/sound_fonts/piano_01.sf2';
  static const String _soundFontPiano2 = 'assets/sound_fonts/piano_02.sf2';
  static const String _soundFontElectricPiano1 = 'assets/sound_fonts/electric_piano_01.sf2';
  static const String _soundFontElectricPiano2 = 'assets/sound_fonts/electric_piano_02.sf2';
  static const String _soundFontPipeOrgan = 'assets/sound_fonts/pipe_organ.sf2';
  static const String _soundFontHarpsicord = 'assets/sound_fonts/harpsichord.sf2';

  // There is a problem if sound fonts are too big, they should be about 1 MB, not more
  static const List<String> soundFontPaths = <String>[
    _soundFontPiano1,
    _soundFontPiano2,
    _soundFontElectricPiano1,
    _soundFontElectricPiano2,
    _soundFontPipeOrgan,
    _soundFontHarpsicord,
  ];

  static getSoundFontName(AppLocalizations l10n, String soundFontPath) => switch (soundFontPath) {
    _soundFontPiano1 => l10n.pianoInstrumentGrandPiano1,
    _soundFontPiano2 => l10n.pianoInstrumentGrandPiano2,
    _soundFontElectricPiano1 => l10n.pianoInstrumentElectricPiano1,
    _soundFontElectricPiano2 => l10n.pianoInstrumentElectricPiano2,
    _soundFontPipeOrgan => l10n.pianoInstrumentPipeOrgan,
    _soundFontHarpsicord => l10n.pianoInstrumentHarpsichord,
    _ => '',
  };

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
