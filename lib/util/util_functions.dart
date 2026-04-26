import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localization.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/blocks/piano_block.dart';
import 'package:tiomusic/models/blocks/tuner_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/util/color_constants.dart';

String formatSettingValues(List<Object> settingValues) {
  final buffer = StringBuffer();
  bool firstTime = true;
  for (final settingValue in settingValues) {
    if (firstTime) {
      firstTime = false;
    } else {
      buffer.write('\n');
    }
    buffer.write('$settingValue');
  }
  return buffer.toString();
}

void _emptyFunction() {}

Future<dynamic> openSettingPage(
  Widget settingPage,
  BuildContext context,
  ProjectBlock block, {
  Function callbackOnReturn = _emptyFunction,
}) {
  ChangeNotifierProvider<ProjectBlock> provider;

  if (block is MetronomeBlock) {
    provider = ChangeNotifierProvider<ProjectBlock>.value(
      value: block,
      builder: (context, child) {
        return settingPage;
      },
    );
  } else if (block is TunerBlock) {
    provider = ChangeNotifierProvider<ProjectBlock>.value(
      value: block,
      builder: (context, child) {
        return settingPage;
      },
    );
  } else if (block is MediaPlayerBlock) {
    provider = ChangeNotifierProvider<ProjectBlock>.value(
      value: block,
      builder: (context, child) {
        return settingPage;
      },
    );
  } else if (block is PianoBlock) {
    provider = ChangeNotifierProvider<ProjectBlock>.value(
      value: block,
      builder: (context, child) {
        return settingPage;
      },
    );
  } else {
    throw 'Block is invalid type';
  }

  return Navigator.of(context)
      .push(
        MaterialPageRoute(
          builder: (context) {
            return provider;
          },
        ),
      )
      .then((value) {
        callbackOnReturn(value);
      });
}

DateTime getCurrentDateTime() {
  return DateTime.now();
}

Widget circleToolIcon(Widget icon) {
  return CircleAvatar(backgroundColor: ColorTheme.secondaryContainer, child: icon);
}

enum IncreaseOrDecrease { increase, decrease }

bool blockValuesSameAsDefaultBlock(ProjectBlock block, AppLocalizations l10n) {
  if (block is MetronomeBlock) {
    if (MetronomeBlock.withDefaults(l10n) == block) return true;
  } else if (block is MediaPlayerBlock) {
    if (MediaPlayerBlock.withDefaults(l10n) == block) return true;
  } else if (block is TunerBlock) {
    if (TunerBlock.withDefaults(l10n) == block) return true;
  } else if (block is PianoBlock) {
    if (PianoBlock.withDefaults(l10n) == block) return true;
  }
  return false;
}
