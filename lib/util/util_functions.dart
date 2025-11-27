import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localization.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/blocks/piano_block.dart';
import 'package:tiomusic/models/blocks/tuner_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/common_buttons.dart';

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

Future<List<String>?> editTwoTitles(BuildContext context, String currentProjectTitle, String currentToolTitle) {
  TextEditingController projectController = TextEditingController(text: currentProjectTitle);
  TextEditingController toolController = TextEditingController(text: currentToolTitle);
  projectController.selection = TextSelection(baseOffset: 0, extentOffset: currentProjectTitle.length);
  toolController.selection = TextSelection(baseOffset: 0, extentOffset: currentToolTitle.length);
  FocusNode focusSecondField = FocusNode();

  return showDialog<List<String>>(
    context: context,
    builder: (context) {
      final l10n = context.l10n;

      return SimpleDialog(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: Column(
              children: [
                TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: '',
                    border: const OutlineInputBorder(borderSide: BorderSide(color: ColorTheme.primary)),
                    enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: ColorTheme.primary)),
                    label: Text(l10n.toolNewProjectTitle, style: const TextStyle(color: ColorTheme.surfaceTint)),
                  ),
                  style: const TextStyle(color: ColorTheme.primary),
                  controller: projectController,
                  onSubmitted: (_) => focusSecondField.requestFocus(),
                ),
                const SizedBox(height: 16),
                TextField(
                  focusNode: focusSecondField,
                  decoration: InputDecoration(
                    hintText: '',
                    border: const OutlineInputBorder(borderSide: BorderSide(color: ColorTheme.primary)),
                    enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: ColorTheme.primary)),
                    label: Text(l10n.toolNewTitle, style: const TextStyle(color: ColorTheme.surfaceTint)),
                  ),
                  style: const TextStyle(color: ColorTheme.primary),
                  controller: toolController,
                  onSubmitted: (_) => _submitTitles(context, projectController, toolController),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
                    TIOFlatButton(
                      onPressed: () => _submitTitles(context, projectController, toolController),
                      text: l10n.commonSubmit,
                      boldText: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

void _submitTitles(BuildContext context, TextEditingController controllerOne, TextEditingController controllerTwo) {
  Navigator.of(context).pop([controllerOne.text, controllerTwo.text]);
  controllerOne.clear();
  controllerTwo.clear();
}

Future<bool?> askForSavingQuickTool(BuildContext context) => showDialog<bool>(
  context: context,
  builder: (context) {
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.toolQuickToolSave, style: TextStyle(color: ColorTheme.primary)),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text(l10n.commonNo),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text(l10n.commonYes, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  },
);

Future<void> showFileNotAccessibleDialog(BuildContext context, {String? fileName}) {
  final l10n = context.l10n;
  fileName = (fileName ?? '').isEmpty ? null : fileName;

  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.mediaPlayerErrorFileAccessible, style: TextStyle(color: ColorTheme.primary)),
      content: Column(
        children: [
          Text(l10n.mediaPlayerErrorFileAccessibleDescription, style: const TextStyle(color: ColorTheme.primary)),
          if (fileName != null)
            Container(
              margin: const EdgeInsets.only(top: 8),
              child: Text(
                '${context.l10n.mediaPlayerFile}: ${basename(fileName)}',
                style: const TextStyle(color: ColorTheme.primary),
              ),
            ),
        ],
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonGotIt))],
    ),
  );
}

Future<void> showNoCameraFoundDialog(BuildContext context) {
  final l10n = context.l10n;
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.imageNoCameraFound, style: TextStyle(color: ColorTheme.primary)),
      content: Text(l10n.imageNoCameraFoundHint, style: TextStyle(color: ColorTheme.primary)),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonGotIt))],
    ),
  );
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
