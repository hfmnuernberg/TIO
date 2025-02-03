import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
import 'package:tiomusic/pages/tuner/tuner.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/util/walkthrough_util.dart';
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

  final Walkthrough _walkthrough = Walkthrough();
  final GlobalKey _keyAddProjectButton = GlobalKey();
  final GlobalKey _keyNavigationBar = GlobalKey();

  @override
  void initState() {
    super.initState();

    _menuItems.add(
      MenuItemButton(
        onPressed: _aboutPagePressed,
        child: const Text("About", style: TextStyle(color: ColorTheme.primary)),
      ),
    );
    _menuItems.add(
      MenuItemButton(
        onPressed: _feedbackPagePressed,
        child: const Text("Feedback", style: TextStyle(color: ColorTheme.primary)),
      ),
    );
    _menuItems.add(
      MenuItemButton(
        onPressed: _deleteAllProjectsPressed,
        child: const Text("Delete all Projects", style: TextStyle(color: ColorTheme.primary)),
      ),
    );
    _menuItems.add(
      MenuItemButton(
        onPressed: _showTutorialAgainPressed,
        child: const Text("Show Walkthrough", style: TextStyle(color: ColorTheme.primary)),
      ),
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    if (context.read<ProjectLibrary>().showHomepageTutorial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _createWalkthrough();
        _walkthrough.show(context);
      });
    }
  }

  void _createWalkthrough() {
    // add the targets here
    var targets = <CustomTargetFocus>[
      CustomTargetFocus(
        _keyAddProjectButton,
        "Tap here to create a new project",
        alignText: ContentAlign.right,
        pointingDirection: PointingDirection.left,
        pointerPosition: PointerPosition.left,
      ),
      CustomTargetFocus(
        _keyNavigationBar,
        "Tap here to start using a tool",
        buttonsPosition: ButtonsPosition.top,
        pointingDirection: PointingDirection.down,
        alignText: ContentAlign.top,
        shape: ShapeLightFocus.RRect,
      ),
      CustomTargetFocus(
        null,
        context: context,
        "Welcome! You can use TIO in two ways.\n1. Create a project and add tools.\n2. Start with using a tool and save your specific settings to any project.",
        customTextPosition: CustomTargetContentPosition(top: MediaQuery.of(context).size.height / 2 - 100),
      ),
      CustomTargetFocus(
        null,
        context: context,
        "Projects can include multiple tools\n(tuner, metronome, piano setting, media player, image and text),\neven several tools of the same type.",
        customTextPosition: CustomTargetContentPosition(top: MediaQuery.of(context).size.height / 2 - 100),
      ),
    ];
    _walkthrough.create(
      targets.map((e) => e.targetFocus).toList(),
      () {
        context.read<ProjectLibrary>().showHomepageTutorial = false;
        FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
      },
      context,
    );
  }

  void _aboutPagePressed() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const AboutPage();
    }));
  }

  void _feedbackPagePressed() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const FeedbackPage();
    }));
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

    _createWalkthrough();
    Future.delayed(Duration.zero, () => _walkthrough.show(context));
  }

  void _onQuickToolTapped(BlockType blockType) {
    ChangeNotifierProvider<ProjectBlock> provider;

    ProjectBlock block;
    Widget toolPage;
    switch (blockType) {
      case BlockType.metronome:
        block = MetronomeBlock.withDefaults();
        toolPage = const Metronome(isQuickTool: true);
        break;
      case BlockType.tuner:
        block = TunerBlock.withDefaults();
        toolPage = const Tuner(isQuickTool: true);
        break;
      case BlockType.mediaPlayer:
        block = MediaPlayerBlock.withDefaults();
        toolPage = const MediaPlayer(isQuickTool: true);
        break;
      case BlockType.piano:
        block = PianoBlock.withDefaults();
        toolPage = const Piano(isQuickTool: true);
        break;
      default:
        throw Exception("Wrong BlockType");
    }

    provider = ChangeNotifierProvider<ProjectBlock>.value(
      value: block,
      builder: (context, child) {
        return toolPage;
      },
    );

    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return provider;
    })).then((value) {
      doActionOnReturn(value);
    });
  }

  void doActionOnReturn(dynamic returnValue) {
    setState(() {});

    if (returnValue is Map) {
      if (returnValue["action"] == ReturnAction.goToNewTool) {
        _goToToolOverProjectPage(returnValue["project"], returnValue["block"], returnValue["pianoAlreadyOn"]);
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
        builder: (context) => AlertDialog(
          title: const Text("Delete?", style: TextStyle(color: ColorTheme.primary)),
          content: deleteAll
              ? const Text("Do you really want to delete all projects?", style: TextStyle(color: ColorTheme.primary))
              : const Text("Do you really want to delete this project?", style: TextStyle(color: ColorTheme.primary)),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text("No")),
            TIOFlatButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              text: "Yes",
              boldText: true,
            ),
          ],
        ),
      );

  void _goToToolOverProjectPage(Project project, ProjectBlock tool, bool pianoAlreadyOn) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
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
    })).then((value) {
      doActionOnReturn(value);
    });
  }

  void _goToProjectPage(Project project, bool withoutRealProject) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return ChangeNotifierProvider<Project>.value(
        value: project,
        builder: (context, child) {
          return ProjectPage(goStraightToTool: false, withoutRealProject: withoutRealProject);
        },
      );
    })).then((value) {
      doActionOnReturn(value);
    });
  }

  Widget _getSurveyBanner() {
    return Positioned(
      left: 0,
      top: 0,
      width: MediaQuery.of(context).size.width,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        elevation: 8.0,
        margin: const EdgeInsets.all(TIOMusicParams.edgeInset),
        color: ColorTheme.onPrimary,
        surfaceTintColor: ColorTheme.onPrimary,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Do you like TIO Music? Please take part in this survey! (For now the survey is only available in German)',
                style: TextStyle(
                  color: ColorTheme.surfaceTint,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () async {
                      // open link in browser
                      final Uri url = Uri.parse('https://cloud9.evasys.de/hfmn/online.php?p=Q2TYV');
                      if (await launchUrl(url) && mounted) {
                        _showBanner = false;
                        context.read<ProjectLibrary>().neverShowSurveyAgain = true;
                        FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
                        setState(() {});
                      }
                    },
                    child: const Text('Fill out'),
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
                      icon: const Icon(Icons.close, color: ColorTheme.surfaceTint)),
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        backgroundColor: ColorTheme.surfaceBright,
        foregroundColor: ColorTheme.primary,
        leading: IconButton(
          key: _keyAddProjectButton,
          onPressed: () async {
            final newTitle = await showEditTextDialog(
              context: context,
              label: TIOMusicParams.newProjectTitle,
              value: getDateAndTimeNow(),
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
            builder: (BuildContext context, MenuController controller, Widget? child) {
              return IconButton(
                onPressed: () {
                  controller.isOpen ? controller.close() : controller.open();
                },
                icon: const Icon(Icons.more_vert),
              );
            },
            style: const MenuStyle(
              backgroundColor: WidgetStatePropertyAll(ColorTheme.surface),
              elevation: WidgetStatePropertyAll(0.0),
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
          FittedBox(
            fit: BoxFit.cover,
            child: Image.asset(
              "assets/images/tiomusic-bg.png",
            ),
          ),

          Column(
            children: [
              Expanded(
                child:
                    // list
                    Consumer<ProjectLibrary>(
                  builder: (context, projectLibrary, child) => projectLibrary.projects.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(40),
                          child: Text(
                            "Please click on '+' to create a new project.",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(
                              top: TIOMusicParams.bigSpaceAboveList, bottom: TIOMusicParams.bigSpaceAboveList / 2),
                          child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: projectLibrary.projects.length,
                              itemBuilder: (BuildContext context, int idx) {
                                return CardListTile(
                                  title: projectLibrary.projects[idx].title,
                                  subtitle: getDateAndTimeFormatted(projectLibrary.projects[idx].timeLastModified),
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
                              }),
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
                        _quickToolButton(blockTypeInfos[BlockType.metronome]!.icon, "Metronome", BlockType.metronome),
                        _quickToolButton(
                            blockTypeInfos[BlockType.mediaPlayer]!.icon, "Media Player", BlockType.mediaPlayer),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _quickToolButton(blockTypeInfos[BlockType.tuner]!.icon, "Tuner", BlockType.tuner),
                        _quickToolButton(blockTypeInfos[BlockType.piano]!.icon, "Piano", BlockType.piano),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // survey banner
          _showBanner ? _getSurveyBanner() : const SizedBox(),
        ],
      ),
    );
  }

  Widget _quickToolButton(dynamic icon, String label, BlockType block) {
    return Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: ColorTheme.primary90, width: 1),
            ),
            width: MediaQuery.of(context).size.width / 2 - TIOMusicParams.edgeInset,
            child: InkWell(
              onTap: () => _onQuickToolTapped(block),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    circleToolIcon(icon),
                    const SizedBox(width: 8.0),
                    Text(
                      label,
                      style: const TextStyle(color: ColorTheme.primary),
                    ),
                  ],
                ),
              ),
            )));
  }
}
