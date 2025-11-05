import 'package:flutter/material.dart';
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
import 'package:tiomusic/pages/media_player/media_player_page.dart';
import 'package:tiomusic/pages/metronome/metronome.dart';
import 'package:tiomusic/pages/piano/piano.dart';
import 'package:tiomusic/pages/project_page/project_page.dart';
import 'package:tiomusic/pages/projects_page/edit_projects_bar.dart';
import 'package:tiomusic/pages/projects_page/editable_project_list.dart';
import 'package:tiomusic/pages/projects_page/project_list.dart';
import 'package:tiomusic/pages/projects_page/projects_page_settings.dart';
import 'package:tiomusic/pages/projects_page/quick_tool_button.dart';
import 'package:tiomusic/pages/projects_page/survey_banner.dart';
import 'package:tiomusic/pages/tuner/tuner.dart';
import 'package:tiomusic/services/file_references.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/app_orientation.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/util/tutorial_util.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tiomusic/widgets/input/edit_text_dialog.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  late FileReferences _fileReferences;
  late ProjectRepository _projectRepo;

  bool _showBanner = false;
  bool _isEditing = false;

  final Tutorial _tutorial = Tutorial();
  final GlobalKey _keyAddProjectButton = GlobalKey();
  final GlobalKey _keyChangeProjectOrder = GlobalKey();
  final GlobalKey _keyQuickTools = GlobalKey();

  @override
  void initState() {
    super.initState();

    _fileReferences = context.read<FileReferences>();
    _projectRepo = context.read<ProjectRepository>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppOrientation.set(context, policy: OrientationPolicy.phonePortrait);
    });

    _showTutorial();
  }

  @override
  void dispose() {
    _tutorial.dispose();
    super.dispose();
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
    final l10n = context.l10n;
    var targets = <CustomTargetFocus>[
      CustomTargetFocus(
        null,
        context: context,
        l10n.projectsTutorialHowToUseTio,
        customTextPosition: CustomTargetContentPosition(top: MediaQuery.of(context).size.height / 2 - 100),
      ),
      CustomTargetFocus(
        _keyAddProjectButton,
        l10n.projectsTutorialAddProject,
        alignText: ContentAlign.right,
        pointingDirection: PointingDirection.left,
      ),
      CustomTargetFocus(
        _keyQuickTools,
        l10n.projectsTutorialStartUsingTool,
        alignText: ContentAlign.top,
        pointingDirection: PointingDirection.down,
        buttonsPosition: ButtonsPosition.top,
        shape: ShapeLightFocus.RRect,
      ),
      CustomTargetFocus(
        _keyChangeProjectOrder,
        l10n.projectsTutorialChangeProjectOrder,
        buttonsPosition: ButtonsPosition.top,
        pointingDirection: PointingDirection.down,
        alignText: ContentAlign.top,
        shape: ShapeLightFocus.RRect,
      ),
      CustomTargetFocus(
        null,
        context: context,
        l10n.projectsTutorialCanIncludeMultipleTools,
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
    final projectLibrary = context.read<ProjectLibrary>();

    final mutableList = projectLibrary.projects.toList();
    final project = mutableList.removeAt(oldIndex);
    mutableList.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, project);
    projectLibrary.projects = mutableList;

    await _projectRepo.saveLibrary(projectLibrary);

    setState(() {});
  }

  void _handleNew() async {
    final l10n = context.l10n;
    final newTitle = await showEditTextDialog(
      context: context,
      label: l10n.projectsNew,
      value: l10n.formatDateAndTime(DateTime.now()),
      isNew: true,
    );
    if (newTitle == null) return;

    final newProject = Project.defaultThumbnail(newTitle);

    if (!mounted) return;

    await _projectRepo.saveLibrary(context.read<ProjectLibrary>());

    setState(() => _isEditing = false);
    _handleGoToProject(newProject, true);
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
        toolPage = const MetronomePage(isQuickTool: true);
      case BlockType.tuner:
        block = TunerBlock.withDefaults(context.l10n);
        toolPage = const Tuner(isQuickTool: true);
      case BlockType.mediaPlayer:
        block = MediaPlayerBlock.withDefaults(context.l10n);
        toolPage = const MediaPlayerPage(isQuickTool: true);
      case BlockType.piano:
        block = PianoBlock.withDefaults(context.l10n);
        toolPage = const PianoPage(isQuickTool: true);
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

  void doActionOnReturn(Object? returnValue) {
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
        content: deleteAll
            ? Text(l10n.projectsDeleteAllConfirmation, style: TextStyle(color: ColorTheme.primary))
            : Text(l10n.projectsDeleteConfirmation, style: TextStyle(color: ColorTheme.primary)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonNo)),
          TIOFlatButton(onPressed: () => Navigator.of(context).pop(true), text: l10n.commonYes, boldText: true),
        ],
      );
    },
  );

  void _handleDelete(int index) async {
    final isConfirmed = await _confirmDeleteProject();
    if (isConfirmed != true) return;
    if (!mounted) return;

    final projectLibrary = context.read<ProjectLibrary>();
    final project = projectLibrary.projects[index];
    await _deleteProject(project);
  }

  Future<void> _handleDeleteAll() async {
    final confirmed = await _confirmDeleteProject(deleteAll: true);
    if (confirmed != true) return;
    if (!mounted) return;

    await _deleteAllProjects();
  }

  Future<void> _deleteProject(Project project) async {
    final library = context.read<ProjectLibrary>();

    for (final block in project.blocks) {
      if (block is ImageBlock) _fileReferences.dec(block.relativePath, library);
      if (block is MediaPlayerBlock) _fileReferences.dec(block.relativePath, library);
    }
    library.removeProject(project);
    await _projectRepo.saveLibrary(library);
  }

  Future<void> _deleteAllProjects() async {
    final library = context.read<ProjectLibrary>();

    for (final project in library.projects) {
      for (final block in project.blocks) {
        if (block is ImageBlock) _fileReferences.dec(block.relativePath, library);
        if (block is MediaPlayerBlock) _fileReferences.dec(block.relativePath, library);
      }
    }
    library.clearProjects();
    await _projectRepo.saveLibrary(library);
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
        builder: (context) => ChangeNotifierProvider<Project>.value(
          value: project,
          child: ProjectPage(goStraightToTool: false, withoutRealProject: withoutRealProject),
        ),
      ),
    );
    doActionOnReturn(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final blockTypes = getBlockTypeInfos(l10n);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(l10n.home),
        centerTitle: true,
        backgroundColor: ColorTheme.surfaceBright,
        foregroundColor: ColorTheme.primary,
        leading: IconButton(
          key: _keyAddProjectButton,
          onPressed: _handleNew,
          icon: const Icon(Icons.add),
          tooltip: l10n.projectsNew,
        ),
        actions: [
          ProjectsPageSettings(
            isEditing: _isEditing,
            onSetEditing: (editing) => setState(() => _isEditing = editing),
            onAddNew: _handleNew,
            onDeleteAll: _handleDeleteAll,
            onShowTutorialAgain: _showTutorialAgainPressed,
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          fit: StackFit.expand,
          children: [
            FittedBox(fit: BoxFit.fill, child: Image.asset('assets/images/tiomusic-bg.png')),

            Column(
              children: [
                Expanded(
                  child: Consumer<ProjectLibrary>(
                    builder: (context, projectLibrary, child) => Stack(
                      children: [
                        if (projectLibrary.projects.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(40),
                            child: Text(
                              l10n.projectsNoProjects,
                              style: const TextStyle(color: Colors.white, fontSize: 42),
                            ),
                          )
                        else if (_isEditing)
                          EditableProjectList(
                            projectLibrary: projectLibrary,
                            onDelete: _handleDelete,
                            onReorder: _handleReorder,
                          )
                        else
                          ProjectList(projectLibrary: projectLibrary, onGoToProject: _handleGoToProject),

                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: TIOMusicParams.smallSpaceAboveList + 2),
                            child: EditProjectsBar(
                              key: _keyChangeProjectOrder,
                              isEditing: _isEditing,
                              onAddProject: _handleNew,
                              onToggleEditing: _toggleEditingMode,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: TIOMusicParams.edgeInset, bottom: TIOMusicParams.edgeInset),
                  color: ColorTheme.surface,
                  child: Column(
                    key: _keyQuickTools,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          QuickToolButton(
                            icon: blockTypes[BlockType.metronome]!.icon,
                            label: l10n.metronome,
                            onTap: () => _onQuickToolTapped(BlockType.metronome),
                          ),
                          QuickToolButton(
                            icon: blockTypes[BlockType.mediaPlayer]!.icon,
                            label: l10n.mediaPlayer,
                            onTap: () => _onQuickToolTapped(BlockType.mediaPlayer),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          QuickToolButton(
                            icon: blockTypes[BlockType.tuner]!.icon,
                            label: l10n.tuner,
                            onTap: () => _onQuickToolTapped(BlockType.tuner),
                          ),
                          QuickToolButton(
                            icon: blockTypes[BlockType.piano]!.icon,
                            label: l10n.piano,
                            onTap: () => _onQuickToolTapped(BlockType.piano),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_showBanner) SurveyBanner(onClose: () => setState(() => _showBanner = false)) else const SizedBox(),
          ],
        ),
      ),
    );
  }
}
