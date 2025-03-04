import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/util/color_constants.dart';

abstract class NoteHandler {
  static final Map<String, SvgNote> _noteValues = <String, SvgNote>{};

  // reads the files in assets/notes and creates a map with the note values
  static Future createNoteBeatLengthMap() async {
    final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    var noteFiles = assetManifest.listAssets().where((string) => string.startsWith('assets/notes')).toList();
    noteFiles = noteFiles.map((path) => path.replaceAll('assets/notes/', '')).toList();

    for (var fileName in noteFiles) {
      debugPrint(fileName);

      var key = FileIO.getFileNameWithoutExtension(fileName);
      double beatLength = double.parse(key.split('_').last);
      key = key.substring(0, key.length - (key.split('_').last.length + 1));

      var svg = SvgPicture.asset(
        'assets/notes/$fileName',
        colorFilter: const ColorFilter.mode(ColorTheme.surfaceTint, BlendMode.srcIn),
      );

      _noteValues[key] = SvgNote(svg: svg, beatLength: beatLength);
    }
  }

  static SvgPicture getNoteSvg(String noteKey) {
    if (_noteValues.containsKey(noteKey)) {
      return _noteValues[noteKey]!.svg;
    } else {
      throw Exception('Note key not found: $noteKey');
    }
  }

  static double getBeatLength(String noteKey) {
    if (_noteValues.containsKey(noteKey)) {
      return _noteValues[noteKey]!.beatLength;
    } else {
      throw Exception('Note key not found: $noteKey');
    }
  }
}

class SvgNote {
  final SvgPicture svg;
  final double beatLength;

  SvgNote({required this.svg, required this.beatLength});
}

abstract class NoteValues {
  static const String whole = 'e1';

  static const String half = 'e2';
  static const String halfDotted = 'e2.';

  static const String quarter = 'e4';
  static const String quarterDotted = 'e4.';

  static const String eighth = 'e8';
  static const String eighthDotted = 'e8.';

  static const String sixteenth = 'e16';
  static const String sixteenthDotted = 'e16.';

  static const String thirtySecond = 'e32';
  static const String thirtySecondDotted = 'e32.';

  static const String tuplet3Half = 'tuplet_3_2_e2';
  static const String tuplet3Quarter = 'tuplet_3_2_e4';
  static const String tuplet3Eighth = 'tuplet_3_2_e8';

  static const String tuplet5Sixteenth = 'tuplet_5_2_e16';

  static const String tuplet6Sixteenth = 'tuplet_6_2_e16';

  static const String tuplet7Sixteenth = 'tuplet_7_2_e16';
}
