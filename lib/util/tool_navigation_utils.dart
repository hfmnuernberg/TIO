import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/blocks/image_block.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/blocks/piano_block.dart';
import 'package:tiomusic/models/blocks/text_block.dart';
import 'package:tiomusic/models/blocks/tuner_block.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/image/image_page.dart';
import 'package:tiomusic/pages/media_player/media_player_page.dart';
import 'package:tiomusic/pages/metronome/metronome.dart';
import 'package:tiomusic/pages/piano/piano.dart';
import 'package:tiomusic/pages/text/text.dart';
import 'package:tiomusic/pages/tuner/tuner_page.dart';
import 'package:tiomusic/services/file_references.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/directional_page_route.dart';

enum ReturnAction { goToNewTool, showTutorial }

Future<dynamic> goToTool(
  BuildContext context,
  Project project,
  ProjectBlock block, {
  bool pianoAlreadyOn = false,
  bool replace = false,
  bool transitionLeftToRight = false,
  bool shouldAutoplay = false,
}) {
  final page = MultiProvider(
    providers: [
      ChangeNotifierProvider<Project>.value(value: project),
      ChangeNotifierProvider<ProjectBlock>.value(value: block),
    ],

    builder: (context, child) {
      if (block is TunerBlock) return const TunerPage(isQuickTool: false);
      if (block is MetronomeBlock) return const MetronomePage(isQuickTool: false);
      if (block is MediaPlayerBlock) return MediaPlayerPage(isQuickTool: false, shouldAutoplay: shouldAutoplay);
      if (block is ImageBlock) return const ImageTool(isQuickTool: false);
      if (block is PianoBlock) return PianoPage(isQuickTool: false, withoutInitAndStart: pianoAlreadyOn);
      if (block is TextBlock) return const TextTool(isQuickTool: false);
      throw 'ERROR: Unknown block type $block';
    },
  );

  final route = MaterialPageRoute(builder: (_) => page);
  final routeWithTransition = DirectionalPageRoute(builder: (_) => page, transitionLeftToRight: transitionLeftToRight);

  return replace ? Navigator.of(context).pushReplacement(routeWithTransition) : Navigator.of(context).push(route);
}

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

void saveToolInNewProject(
  BuildContext context,
  ProjectBlock tool,
  bool isQuickTool,
  String projectTitle,
  String toolTitle, {
  bool pianoAlreadyOn = false,
}) async {
  ProjectLibrary projectLibrary = context.read<ProjectLibrary>();
  Project newProject = Project.defaultThumbnail(projectTitle);
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
