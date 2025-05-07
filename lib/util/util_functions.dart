import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localization.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/image_block.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/blocks/piano_block.dart';
import 'package:tiomusic/models/blocks/text_block.dart';
import 'package:tiomusic/models/blocks/tuner_block.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/models/rhythm_group.dart';
import 'package:tiomusic/pages/image/image_page.dart';
import 'package:tiomusic/pages/media_player/media_player.dart';
import 'package:tiomusic/pages/metronome/metronome.dart';
import 'package:tiomusic/pages/piano/piano.dart';
import 'package:tiomusic/pages/text/text.dart';
import 'package:tiomusic/pages/tuner/tuner.dart';
import 'package:tiomusic/services/file_references.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/directional_page_route.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

// ---------------------------------------------------------------
// copy an asset to a temporary file

Future<String> copyAssetToTemp(FileSystem fs, String assetPath) async {
  final tempAssetPath = '${fs.tmpFolderPath}/${assetPath.split('/').last}';
  final byteData = await rootBundle.load(assetPath);
  final bytes = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
  await fs.saveFileAsBytes(tempAssetPath, bytes);
  return tempAssetPath;
}

// ---------------------------------------------------------------
// format the settings into Text that can be displayed

String formatSettingValues(List settingValues) {
  String resultString = '';
  bool firstTime = true;
  for (dynamic settingValue in settingValues) {
    if (firstTime) {
      firstTime = false;
    } else {
      resultString = '$resultString\n';
    }
    resultString = '$resultString$settingValue';
  }
  return resultString;
}

// ---------------------------------------------------------------
// open setting page with the correct provider

void _emptyFunction(value) {}

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

// ---------------------------------------------------------------
// show a dialog for editing the title of tool and project

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

// ---------------------------------------------------------------
// show a dialog for asking if user wants to override existing file by starting to record

Future<bool?> askForOverridingFileOnRecordingStart(BuildContext context) => showDialog<bool>(
  context: context,
  builder: (context) {
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.mediaPlayerOverwriteSound, style: const TextStyle(color: ColorTheme.primary)),
      content: Text(l10n.mediaPlayerOverwriteSoundQuestion, style: const TextStyle(color: ColorTheme.primary)),
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

// ---------------------------------------------------------------
// show a dialog for asking if user wants to save the quick tool before leaving the tool page and loosing the changes

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

// ---------------------------------------------------------------
// show a dialog to tell the user that the file format is not supported

Future<void> showFormatNotSupportedDialog(BuildContext context, String? format) => showDialog<void>(
  context: context,
  builder: (context) {
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.mediaPlayerErrorFileFormat, style: TextStyle(color: ColorTheme.primary)),
      content: Text(
        l10n.mediaPlayerErrorFileFormatDescription(format ?? ''),
        style: const TextStyle(color: ColorTheme.primary),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonGotIt))],
    );
  },
);

// ---------------------------------------------------------------
// show a dialog to tell the user that the file could not be opened

Future<void> showFileOpenFailedDialog(BuildContext context, {String? fileName}) {
  final l10n = context.l10n;
  fileName = (fileName ?? '').isEmpty ? null : fileName;

  return showDialog<void>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(l10n.mediaPlayerErrorFileOpen, style: TextStyle(color: ColorTheme.primary)),
          content: Column(
            children: [
              Text(l10n.mediaPlayerErrorFileOpenDescription, style: const TextStyle(color: ColorTheme.primary)),
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

// ---------------------------------------------------------------
// show a dialog to tell the user that the file is somehow not accessible

Future<void> showFileNotAccessibleDialog(BuildContext context, {String? fileName}) {
  final l10n = context.l10n;
  fileName = (fileName ?? '').isEmpty ? null : fileName;

  return showDialog<void>(
    context: context,
    builder:
        (context) => AlertDialog(
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

// ---------------------------------------------------------------
// show a dialog to tell the user that no camera was found

Future<void> showNoCameraFoundDialog(BuildContext context) {
  final l10n = context.l10n;
  return showDialog<void>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(l10n.imageNoCameraFound, style: TextStyle(color: ColorTheme.primary)),
          content: Text(l10n.imageNoCameraFoundHint, style: TextStyle(color: ColorTheme.primary)),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonGotIt))],
        ),
  );
}

// ---------------------------------------------------------------
// navigate to a new tool page and provide the correct providers

Future<dynamic> goToTool(
  BuildContext context,
  Project project,
  ProjectBlock block, {
  bool pianoAlreadyOn = false,
  bool replace = false,
  bool transitionLeftToRight = false,
}) {
  final page = MultiProvider(
    providers: [
      ChangeNotifierProvider<Project>.value(value: project),
      ChangeNotifierProvider<ProjectBlock>.value(value: block),
    ],

    builder: (context, child) {
      if (block is TunerBlock) return const Tuner(isQuickTool: false);
      if (block is MetronomeBlock) return const Metronome(isQuickTool: false);
      if (block is MediaPlayerBlock) return const MediaPlayer(isQuickTool: false);
      if (block is ImageBlock) return const ImageTool(isQuickTool: false);
      if (block is PianoBlock) return Piano(isQuickTool: false, withoutInitAndStart: pianoAlreadyOn);
      if (block is TextBlock) return const TextTool(isQuickTool: false);
      throw 'ERROR: Unknown block type $block';
    },
  );

  final route = MaterialPageRoute(builder: (context) => page);
  final customRoute = DirectionalPageRoute(builder: (context) => page, transitionLeftToRight: transitionLeftToRight);

  return replace ? Navigator.of(context).pushReplacement(customRoute) : Navigator.of(context).push(route);
}

// ---------------------------------------------------------------
// get the current date and time

DateTime getCurrentDateTime() {
  return DateTime.now();
}

// ---------------------------------------------------------------
// save tool in existing project

Future<void> saveToolInProject(
  BuildContext context,
  int index,
  ProjectBlock tool,
  bool isQuickTool,
  String newTitle, {
  bool pianoAlreadyOn = false,
}) async {
  ProjectLibrary projectLibrary = context.read<ProjectLibrary>();
  ProjectBlock newBlock = projectLibrary.projects[index].copyTool(tool, newTitle);

  if (!isQuickTool) {
    if (newBlock is ImageBlock) context.read<FileReferences>().inc(newBlock.relativePath);
    if (newBlock is MediaPlayerBlock) context.read<FileReferences>().inc(newBlock.relativePath);
  }

  await context.read<ProjectRepository>().saveLibrary(projectLibrary);

  if (context.mounted) {
    // if we save a tool, that already belongs to a project
    if (!isQuickTool) {
      // also pop the tool page back to project page
      Navigator.of(context).pop();
    }
    // pop back to home page
    final returnData = {
      'action': ReturnAction.goToNewTool,
      'project': projectLibrary.projects[index],
      'block': newBlock,
      'pianoAlreadyOn': pianoAlreadyOn,
    };
    Navigator.of(context).pop(returnData);
  }
}

// ---------------------------------------------------------------
// save tool in a new project

void saveToolInNewProject(
  BuildContext context,
  ProjectBlock tool,
  bool isQuickTool,
  String projectTitle,
  String toolTitle, {
  bool pianoAlreadyOn = false,
}) async {
  ProjectLibrary projectLibrary = context.read<ProjectLibrary>();
  Project newProject = Project.defaultPicture(projectTitle);
  projectLibrary.addProject(newProject);
  ProjectBlock newBlock = newProject.copyTool(tool, toolTitle);

  if (!isQuickTool) {
    if (newBlock is ImageBlock) context.read<FileReferences>().inc(newBlock.relativePath);
    if (newBlock is MediaPlayerBlock) context.read<FileReferences>().inc(newBlock.relativePath);
  }

  await context.read<ProjectRepository>().saveLibrary(projectLibrary);

  if (context.mounted) {
    // if we save a tool, that already belongs to a project
    if (!isQuickTool) {
      // also pop the tool page
      Navigator.of(context).pop();
    }
    // pop back to home page
    final returnData = {
      'action': ReturnAction.goToNewTool,
      'project': newProject,
      'block': newBlock,
      'pianoAlreadyOn': pianoAlreadyOn,
    };
    Navigator.of(context).pop(returnData);
  }
}

enum ReturnAction { goToNewTool }

// ---------------------------------------------------------------
// our modal bottom sheet

Future<dynamic> ourModalBottomSheet(BuildContext context, List<Widget> titelChildren, List<Widget> contentChildren) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.75,
        child: Column(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                color: ColorTheme.surface,
              ),
              child: Column(children: [const SizedBox(height: 20), Column(children: titelChildren)]),
            ),
            Expanded(child: ColoredBox(color: ColorTheme.primary80, child: Column(children: contentChildren))),
          ],
        ),
      );
    },
  );
}

// ---------------------------------------------------------------
// Circle Icon for displaying the tool icons all with the same color

Widget circleToolIcon(Widget icon) {
  return CircleAvatar(backgroundColor: ColorTheme.secondaryContainer, child: icon);
}

// ---------------------------------------------------------------

bool checkIslandPossible(Project? project, ProjectBlock toolBlock) {
  if (project != null) {
    // if we are in a normal tool, check the following

    // check if there is more than one tool in the project
    if (project.blocks.length > 1) {
      bool possibleToolFound = false;
      for (ProjectBlock block in project.blocks) {
        // don't allow the same kind that is currently open
        if (block.kind != toolBlock.kind) {
          // only allow tuner, metronome and media player as islands
          if (block.kind == 'tuner' || block.kind == 'metronome' || block.kind == 'media_player') {
            possibleToolFound = true;
          }
        }
      }
      return possibleToolFound;
    }
  }
  return false;
}

// convert the RhythmGroup class into the MetroBar class, that is used in Rust
List<MetroBar> getRhythmAsMetroBar(List<RhythmGroup> rhythm) {
  return List<MetroBar>.generate(rhythm.length, (index) {
    return MetroBar(
      id: 0,
      beats: rhythm[index].beats,
      polyBeats: rhythm[index].polyBeats,
      beatLen: rhythm[index].beatLen,
    );
  });
}

enum IncreaseOrDecrease { increase, decrease }

// compare block values to default values
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
