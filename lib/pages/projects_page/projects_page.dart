import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/image_block.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/blocks/piano_block.dart';
import 'package:tiomusic/models/blocks/tuner_block.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/info_pages/about_page.dart';
import 'package:tiomusic/pages/info_pages/feedback_page.dart';
import 'package:tiomusic/pages/media_player/media_player.dart';
import 'package:tiomusic/pages/metronome/metronome.dart';
import 'package:tiomusic/pages/piano/piano.dart';
import 'package:tiomusic/pages/project_page/project_page.dart';
import 'package:tiomusic/pages/projects_page/editable_project_list.dart';
import 'package:tiomusic/pages/projects_page/import_project.dart';
import 'package:tiomusic/pages/projects_page/project_list.dart';
import 'package:tiomusic/pages/tuner/tuner.dart';
import 'package:tiomusic/services/file_references.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/util/tutorial_util.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tiomusic/widgets/input/edit_text_dialog.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  // TODO: _getSurveyBanner into own file
  // TODO: _quickToolButton into own file
  late FileSystem _fs;
  late FileReferences _fileReferences;
  late ProjectRepository _projectRepo;

  bool _showBanner = false;
  bool _isEditing = false;

  final Tutorial _tutorial = Tutorial();
  final GlobalKey _keyAddProjectButton = GlobalKey();
  final GlobalKey _keyNavigationBar = GlobalKey();

  @override
  void initState() {
    super.initState();

    _fs = context.read<FileSystem>();
    _fileReferences = context.read<FileReferences>();
    _projectRepo = context.read<ProjectRepository>();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    _showTutorial();
  }

  void _showTutorial() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final projectLibrary = context.read<ProjectLibrary>();

      if (projectLibrary.showHomepageTutorial) {
        projectLibrary.showHomepageTutorial = false;
        await context.read<ProjectRepository>().saveLibrary(projectLibrary);
        _createTutorial();
        if (!mounted) return;
        _tutorial.show(context);
      }
    });
  }

  void _createTutorial() {
    var targets = <CustomTargetFocus>[
      CustomTargetFocus(
        _keyAddProjectButton,
        context.l10n.projectsTutorialAddProject,
        alignText: ContentAlign.right,
        pointingDirection: PointingDirection.left,
        pointerPosition: PointerPosition.left,
      ),
      CustomTargetFocus(
        _keyNavigationBar,
        context.l10n.projectsTutorialStartUsingTool,
        buttonsPosition: ButtonsPosition.top,
        pointingDirection: PointingDirection.down,
        alignText: ContentAlign.top,
        shape: ShapeLightFocus.RRect,
      ),
      CustomTargetFocus(
        null,
        context: context,
        context.l10n.projectsTutorialHowToUseTio,
        customTextPosition: CustomTargetContentPosition(top: MediaQuery.of(context).size.height / 2 - 100),
      ),
      CustomTargetFocus(
        null,
        context: context,
        context.l10n.projectsTutorialCanIncludeMultipleTools,
        customTextPosition: CustomTargetContentPosition(top: MediaQuery.of(context).size.height / 2 - 100),
      ),
    ];
    _tutorial.create(targets.map((e) => e.targetFocus).toList(), () async {
      context.read<ProjectLibrary>().showHomepageTutorial = false;
      await _projectRepo.saveLibrary(context.read<ProjectLibrary>());
    }, context);
  }

  void _toggleEditingMode() => setState(() => _isEditing = !_isEditing);

  Future<void> _handleReorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;

    final projectLibrary = context.read<ProjectLibrary>();

    final mutableList = projectLibrary.projects.toList();
    final project = mutableList.removeAt(oldIndex);
    mutableList.insert(newIndex, project);
    projectLibrary.projects = mutableList;

    await _projectRepo.saveLibrary(projectLibrary);

    setState(() {});
  }

  void addNewProject() async {
    final l10n = context.l10n;
    final newTitle = await showEditTextDialog(
      context: context,
      label: l10n.projectsNew,
      value: l10n.formatDateAndTime(DateTime.now()),
      isNew: true,
    );
    if (newTitle == null) return;

    final newProject = Project.defaultPicture(newTitle);
    if (context.mounted) {
      // TODO: fix async gap warning
      await _projectRepo.saveLibrary(context.read<ProjectLibrary>());
    }

    _handleGoToProject(newProject, true);
  }

  void _aboutPagePressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return AboutPage();
        },
      ),
    );
  }

  void _feedbackPagePressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const FeedbackPage();
        },
      ),
    );
  }

  void _showTutorialAgainPressed() async {
    context.read<ProjectLibrary>().resetAllTutorials();
    await _projectRepo.saveLibrary(context.read<ProjectLibrary>());

    _createTutorial();
    Future.delayed(Duration.zero, () {
      if (mounted) _tutorial.show(context);
    });
  }

  void _onQuickToolTapped(BlockType blockType) {
    ChangeNotifierProvider<ProjectBlock> provider;

    ProjectBlock block;
    Widget toolPage;
    switch (blockType) {
      case BlockType.metronome:
        block = MetronomeBlock.withDefaults(context.l10n);
        toolPage = const Metronome(isQuickTool: true);
      case BlockType.tuner:
        block = TunerBlock.withDefaults(context.l10n);
        toolPage = const Tuner(isQuickTool: true);
      case BlockType.mediaPlayer:
        block = MediaPlayerBlock.withDefaults(context.l10n);
        toolPage = const MediaPlayer(isQuickTool: true);
      case BlockType.piano:
        block = PianoBlock.withDefaults(context.l10n);
        toolPage = const Piano(isQuickTool: true);
      default:
        throw Exception('Wrong BlockType');
    }

    provider = ChangeNotifierProvider<ProjectBlock>.value(
      value: block,
      builder: (context, child) {
        return toolPage;
      },
    );

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) {
              return provider;
            },
          ),
        )
        .then(doActionOnReturn);
  }

  void doActionOnReturn(returnValue) {
    setState(() {});

    if (returnValue is Map) {
      if (returnValue['action'] == ReturnAction.goToNewTool) {
        _goToToolOverProjectPage(returnValue['project'], returnValue['block'], returnValue['pianoAlreadyOn']);
      }
    } else {
      // on every return to the home page
      var projectLibrary = context.read<ProjectLibrary>();
      if (!projectLibrary.neverShowSurveyAgain) {
        if (projectLibrary.idxCheckShowSurvey < projectLibrary.showSurveyAtVisits.length) {
          if (projectLibrary.visitedToolsCounter >
              projectLibrary.showSurveyAtVisits[projectLibrary.idxCheckShowSurvey]) {
            _showBanner = true;
            setState(() {});
          }
        }
      }
    }
  }

  Future<bool?> _confirmDeleteProject({bool deleteAll = false}) => showDialog<bool>(
    context: context,
    builder: (context) {
      final l10n = context.l10n;

      return AlertDialog(
        title: Text(l10n.commonDelete, style: const TextStyle(color: ColorTheme.primary)),
        content:
            deleteAll
                ? Text(l10n.projectsDeleteAllConfirmation, style: TextStyle(color: ColorTheme.primary))
                : Text(l10n.projectsDeleteConfirmation, style: TextStyle(color: ColorTheme.primary)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(l10n.commonNo),
          ),
          TIOFlatButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            text: l10n.commonYes,
            boldText: true,
          ),
        ],
      );
    },
  );

  void _handleDelete(int index) async {
    bool? isConfirmed = await _confirmDeleteProject();
    if (isConfirmed != true) return;

    if (!mounted) return;
    final projectLibrary = context.read<ProjectLibrary>();
    final project = projectLibrary.projects[index];

    for (final block in project.blocks) {
      if (block is ImageBlock) _fileReferences.dec(block.relativePath, projectLibrary);
      if (block is MediaPlayerBlock) _fileReferences.dec(block.relativePath, projectLibrary);
    }

    projectLibrary.removeProject(projectLibrary.projects[index]);

    await _projectRepo.saveLibrary(projectLibrary);
  }

  void _handleDeleteAllProjects() async {
    bool? isConfirmed = await _confirmDeleteProject();
    if (isConfirmed != true) return;

    if (!mounted) return;
    final projectLibrary = context.read<ProjectLibrary>();

    for (final project in projectLibrary.projects) {
      for (final block in project.blocks) {
        if (block is ImageBlock) _fileReferences.dec(block.relativePath, projectLibrary);
        if (block is MediaPlayerBlock) _fileReferences.dec(block.relativePath, projectLibrary);
      }
    }

    projectLibrary.clearProjects();

    await _projectRepo.saveLibrary(projectLibrary);
  }

  void _goToToolOverProjectPage(Project project, ProjectBlock tool, bool pianoAlreadyOn) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) {
              return ChangeNotifierProvider<Project>.value(
                value: project,
                builder: (context, child) {
                  return ProjectPage(
                    goStraightToTool: true,
                    toolToOpenDirectly: tool,
                    withoutRealProject: false,
                    pianoAlreadyOn: pianoAlreadyOn,
                  );
                },
              );
            },
          ),
        )
        .then(doActionOnReturn);
  }

  Future<void> _handleGoToProject(Project project, bool withoutRealProject) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ChangeNotifierProvider<Project>.value(
              value: project,
              child: ProjectPage(goStraightToTool: false, withoutRealProject: withoutRealProject),
            ),
      ),
    );
    doActionOnReturn(result);
  }

  Widget _getSurveyBanner() {
    final l10n = context.l10n;

    return Positioned(
      left: 0,
      top: 0,
      width: MediaQuery.of(context).size.width,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        elevation: 8,
        margin: const EdgeInsets.all(TIOMusicParams.edgeInset),
        color: ColorTheme.onPrimary,
        surfaceTintColor: ColorTheme.onPrimary,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.feedbackQuestion, style: TextStyle(color: ColorTheme.surfaceTint)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () async {
                      final Uri url = Uri.parse('https://cloud9.evasys.de/hfmn/online.php?p=Q2TYV');
                      if (await launchUrl(url) && mounted) {
                        _showBanner = false;
                        context.read<ProjectLibrary>().neverShowSurveyAgain = true;
                        await _projectRepo.saveLibrary(context.read<ProjectLibrary>());
                        setState(() {});
                      }
                    },
                    child: Text(l10n.feedbackCta),
                  ),
                  IconButton(
                    onPressed: () async {
                      _showBanner = false;

                      // show banner a second and third time and then never again
                      var projectLibrary = context.read<ProjectLibrary>();
                      projectLibrary.idxCheckShowSurvey++;
                      if (projectLibrary.idxCheckShowSurvey >= projectLibrary.showSurveyAtVisits.length) {
                        projectLibrary.neverShowSurveyAgain = true;
                      }
                      await _projectRepo.saveLibrary(projectLibrary);

                      setState(() {});
                    },
                    icon: const Icon(Icons.close, color: ColorTheme.surfaceTint),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<ImageProvider<Object>> _generateThumbnails(ProjectLibrary projectLibrary) =>
      projectLibrary.projects.map<ImageProvider<Object>>((project) {
        if (project.thumbnailPath.isEmpty) return const AssetImage(TIOMusicParams.tiomusicIconPath);
        return FileImage(File(_fs.toAbsoluteFilePath(project.thumbnailPath)));
      }).toList();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final blockTypes = getBlockTypeInfos(l10n);

    final menuItems = [
      MenuItemButton(
        onPressed: _aboutPagePressed,
        child: Text(context.l10n.homeAbout, style: const TextStyle(color: ColorTheme.primary)),
      ),
      MenuItemButton(
        onPressed: _feedbackPagePressed,
        child: Text(l10n.homeFeedback, style: const TextStyle(color: ColorTheme.primary)),
      ),
      MenuItemButton(
        onPressed: () => importProject(context),
        child: Text(l10n.projectsImport, style: const TextStyle(color: ColorTheme.primary)),
      ),
      MenuItemButton(
        onPressed: () {
          setState(() => _isEditing = false);
          addNewProject();
        },
        child: Text(context.l10n.projectsAddNew, style: TextStyle(color: ColorTheme.primary)),
      ),
      MenuItemButton(
        onPressed: _toggleEditingMode,
        child: Text(
          _isEditing ? context.l10n.projectsEditDone : context.l10n.projectsEdit,
          style: TextStyle(color: ColorTheme.primary),
        ),
      ),
      MenuItemButton(
        onPressed: _handleDeleteAllProjects,
        child: Text(l10n.projectsDeleteAll, style: const TextStyle(color: ColorTheme.primary)),
      ),
      MenuItemButton(
        onPressed: _showTutorialAgainPressed,
        child: Text(l10n.projectsTutorialStart, style: const TextStyle(color: ColorTheme.primary)),
      ),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(l10n.home),
        centerTitle: true,
        backgroundColor: ColorTheme.surfaceBright,
        foregroundColor: ColorTheme.primary,
        leading: IconButton(
          key: _keyAddProjectButton,
          onPressed: addNewProject,
          icon: const Icon(Icons.add),
          tooltip: l10n.projectsNew,
        ),
        actions: [
          MenuAnchor(
            builder: (context, controller, child) {
              return IconButton(
                onPressed: () {
                  controller.isOpen ? controller.close() : controller.open();
                },
                icon: const Icon(Icons.more_vert),
                tooltip: context.l10n.projectsMenu,
              );
            },
            style: const MenuStyle(
              backgroundColor: WidgetStatePropertyAll(ColorTheme.surface),
              elevation: WidgetStatePropertyAll(0),
            ),
            menuChildren: menuItems,
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        fit: StackFit.expand,
        children: [
          FittedBox(fit: BoxFit.cover, child: Image.asset('assets/images/tiomusic-bg.png')),

          Column(
            children: [
              Expanded(
                child: Consumer<ProjectLibrary>(
                  builder:
                      (context, projectLibrary, child) =>
                          projectLibrary.projects.isEmpty
                              ? Padding(
                                padding: const EdgeInsets.all(40),
                                child: Text(
                                  l10n.projectsNoProjects,
                                  style: const TextStyle(color: Colors.white, fontSize: 42),
                                ),
                              )
                              : Padding(
                                padding: const EdgeInsets.only(
                                  top: TIOMusicParams.bigSpaceAboveList,
                                  bottom: TIOMusicParams.bigSpaceAboveList / 2,
                                ),
                                child:
                                    _isEditing
                                        ? EditableProjectList(
                                          projectLibrary: projectLibrary,
                                          projectThumbnails: _generateThumbnails(projectLibrary),
                                          onGoToProject: _handleGoToProject,
                                          onDelete: _handleDelete,
                                          onReorder: _handleReorder,
                                        )
                                        : ProjectList(
                                          projectLibrary: projectLibrary,
                                          projectThumbnails: _generateThumbnails(projectLibrary),
                                          onGoToProject: _handleGoToProject,
                                        ),
                              ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: TIOMusicParams.edgeInset, bottom: TIOMusicParams.edgeInset),
                color: ColorTheme.surface,
                child: Column(
                  key: _keyNavigationBar,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _quickToolButton(blockTypes[BlockType.metronome]!.icon, l10n.metronome, BlockType.metronome),
                        _quickToolButton(
                          blockTypes[BlockType.mediaPlayer]!.icon,
                          l10n.mediaPlayer,
                          BlockType.mediaPlayer,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _quickToolButton(blockTypes[BlockType.tuner]!.icon, l10n.tuner, BlockType.tuner),
                        _quickToolButton(blockTypes[BlockType.piano]!.icon, l10n.piano, BlockType.piano),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_showBanner) _getSurveyBanner() else const SizedBox(),
        ],
      ),
    );
  }

  Widget _quickToolButton(icon, String label, BlockType block) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: ColorTheme.primary90),
        ),
        width: MediaQuery.of(context).size.width / 2 - TIOMusicParams.edgeInset,
        child: InkWell(
          onTap: () => _onQuickToolTapped(block),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                circleToolIcon(icon),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(color: ColorTheme.primary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
