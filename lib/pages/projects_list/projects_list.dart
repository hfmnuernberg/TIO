import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/blocks/piano_block.dart';
import 'package:tiomusic/models/blocks/tuner_block.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/info_pages/about_page.dart';
import 'package:tiomusic/pages/info_pages/feedback_page.dart';
import 'package:tiomusic/pages/media_player/media_player.dart';
import 'package:tiomusic/pages/metronome/metronome.dart';
import 'package:tiomusic/pages/piano/piano.dart';
import 'package:tiomusic/pages/project_page/project_page.dart';
import 'package:tiomusic/pages/projects_list/import_project.dart';
import 'package:tiomusic/pages/tuner/tuner.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/util/tutorial_util.dart';
import 'package:tiomusic/widgets/card_list_tile.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tiomusic/widgets/input/edit_text_dialog.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectsList extends StatefulWidget {
  const ProjectsList({super.key});

  @override
  State<ProjectsList> createState() => _ProjectsListState();
}

class _ProjectsListState extends State<ProjectsList> {
  final List<MenuItemButton> _menuItems = List.empty(growable: true);

  bool _showBanner = false;

  final Tutorial _tutorial = Tutorial();
  final GlobalKey _keyAddProjectButton = GlobalKey();
  final GlobalKey _keyNavigationBar = GlobalKey();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_menuItems.isEmpty) {
      final l10n = context.l10n;

      _menuItems.addAll([
        MenuItemButton(
          onPressed: _aboutPagePressed,
          child: Text(l10n.homeAbout, style: const TextStyle(color: ColorTheme.primary)),
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
          onPressed: _deleteAllProjectsPressed,
          child: Text(l10n.projectsDeleteAll, style: const TextStyle(color: ColorTheme.primary)),
        ),
        MenuItemButton(
          onPressed: _showTutorialAgainPressed,
          child: Text(l10n.projectsTutorialStart, style: const TextStyle(color: ColorTheme.primary)),
        ),
      ]);
    }

    _showTutorial();
  }

  void _showTutorial() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final projectLibrary = context.read<ProjectLibrary>();

      if (projectLibrary.showHomepageTutorial) {
        projectLibrary.showHomepageTutorial = false;
        FileIO.saveProjectLibraryToJson(projectLibrary);
        _createTutorial();
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
    _tutorial.create(targets.map((e) => e.targetFocus).toList(), () {
      context.read<ProjectLibrary>().showHomepageTutorial = false;
      FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    }, context);
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

  void _deleteAllProjectsPressed() async {
    bool? deleteProject = await _deleteProject(deleteAll: true);
    if (deleteProject != null && deleteProject) {
      if (mounted) {
        final projectLibrary = Provider.of<ProjectLibrary>(context, listen: false);
        projectLibrary.clearProjects();
        FileIO.saveProjectLibraryToJson(projectLibrary);
      }
    }
  }

  void _showTutorialAgainPressed() {
    context.read<ProjectLibrary>().resetAllTutorials();
    FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());

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

  Future<bool?> _deleteProject({bool deleteAll = false}) => showDialog<bool>(
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

  void _goToProjectPage(Project project, bool withoutRealProject) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) {
              return ChangeNotifierProvider<Project>.value(
                value: project,
                builder: (context, child) {
                  return ProjectPage(goStraightToTool: false, withoutRealProject: withoutRealProject);
                },
              );
            },
          ),
        )
        .then(doActionOnReturn);
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
                        FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
                        setState(() {});
                      }
                    },
                    child: Text(l10n.feedbackCta),
                  ),
                  IconButton(
                    onPressed: () {
                      _showBanner = false;

                      // show banner a second and third time and then never again
                      var projectLibrary = context.read<ProjectLibrary>();
                      projectLibrary.idxCheckShowSurvey++;
                      if (projectLibrary.idxCheckShowSurvey >= projectLibrary.showSurveyAtVisits.length) {
                        projectLibrary.neverShowSurveyAgain = true;
                      }
                      FileIO.saveProjectLibraryToJson(projectLibrary);

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
          onPressed: () async {
            final newTitle = await showEditTextDialog(
              context: context,
              label: l10n.projectsNew,
              value: l10n.formatDateAndTime(DateTime.now()),
              isNew: true,
            );
            if (newTitle == null) return;

            final newProject = Project.defaultPicture(newTitle);
            if (context.mounted) {
              FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
            }

            _goToProjectPage(newProject, true);
          },
          icon: const Icon(Icons.add),
        ),
        actions: [
          MenuAnchor(
            builder: (context, controller, child) {
              return IconButton(
                onPressed: () {
                  controller.isOpen ? controller.close() : controller.open();
                },
                icon: const Icon(Icons.more_vert),
              );
            },
            style: const MenuStyle(
              backgroundColor: WidgetStatePropertyAll(ColorTheme.surface),
              elevation: WidgetStatePropertyAll(0),
            ),
            menuChildren: _menuItems,
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        fit: StackFit.expand,
        children: [
          // background image
          FittedBox(fit: BoxFit.cover, child: Image.asset('assets/images/tiomusic-bg.png')),

          Column(
            children: [
              Expanded(
                child:
                // list
                Consumer<ProjectLibrary>(
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
                                child: ListView.builder(
                                  itemCount: projectLibrary.projects.length,
                                  itemBuilder: (context, idx) {
                                    return CardListTile(
                                      title: projectLibrary.projects[idx].title,
                                      subtitle: l10n.formatDateAndTime(projectLibrary.projects[idx].timeLastModified),
                                      trailingIcon: IconButton(
                                        onPressed: () {
                                          _goToProjectPage(projectLibrary.projects[idx], false);
                                        },
                                        icon: const Icon(Icons.arrow_forward),
                                        color: ColorTheme.primaryFixedDim,
                                      ),
                                      menuIconOne: IconButton(
                                        onPressed: () async {
                                          bool? deleteProject = await _deleteProject();
                                          if (deleteProject != null && deleteProject) {
                                            projectLibrary.removeProject(projectLibrary.projects[idx]);
                                            FileIO.saveProjectLibraryToJson(projectLibrary);
                                          }
                                        },
                                        icon: const Icon(Icons.delete_outlined),
                                        color: ColorTheme.surfaceTint,
                                      ),
                                      leadingPicture: projectLibrary.projects[idx].thumbnail,
                                      onTapFunction: () {
                                        _goToProjectPage(projectLibrary.projects[idx], false);
                                      },
                                    );
                                  },
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
          // survey banner
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
