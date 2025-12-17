import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/domain/piano/piano.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/piano_block.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/models/sound_font.dart';
import 'package:tiomusic/pages/parent_tool/setting_volume_page.dart';
import 'package:tiomusic/pages/piano/choose_sound.dart';
import 'package:tiomusic/pages/piano/set_concert_pitch.dart';
import 'package:tiomusic/services/audio_session.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/app_orientation.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants/constants.dart';
import 'package:tiomusic/util/constants/piano_constants.dart';
import 'package:tiomusic/util/l10n/sound_font_extensions.dart';
import 'package:tiomusic/util/tool_navigation_utils.dart';
import 'package:tiomusic/util/tutorial/tutorial_util.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/card_list_tile.dart';
import 'package:tiomusic/widgets/common_buttons.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tiomusic/widgets/input/flat_edit_text_dialog.dart';
import 'package:tiomusic/widgets/parent_tool/parent_island_view.dart';
import 'package:tiomusic/widgets/piano/keyboard.dart';
import 'package:tiomusic/widgets/piano/piano_navigation_bar.dart';
import 'package:tiomusic/widgets/piano/piano_tool_navigation_bar.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class PianoPage extends StatefulWidget {
  final bool isQuickTool;
  final bool withoutInitAndStart;

  const PianoPage({super.key, required this.isQuickTool, this.withoutInitAndStart = false});

  @override
  State<PianoPage> createState() => _PianoPageState();
}

class _PianoPageState extends State<PianoPage> {
  late FileSystem _fs;
  late ProjectRepository _projectRepo;

  late final Piano piano;

  bool _isHolding = false;

  late PianoBlock _pianoBlock;

  Icon _bookmarkIcon = const Icon(Icons.bookmark_add_outlined);
  Color? _highlightColorOnSave;

  final TextEditingController _newToolTitle = TextEditingController();
  final TextEditingController _newProjectTitle = TextEditingController();
  late FocusNode _toolTitleFieldFocus;

  bool _showSavingPage = false;
  OverlayEntry? _entry;

  final Tutorial _tutorial = Tutorial();
  final GlobalKey _keyOctaveSwitch = GlobalKey();
  final GlobalKey _keySettings = GlobalKey();
  final GlobalKey _keyIsland = GlobalKey();
  final GlobalKey _keyBookmarkSave = GlobalKey();
  final GlobalKey _keyChangeTitle = GlobalKey();
  final GlobalKey _keyBookmarkShare = GlobalKey();

  bool _dontStopOnLeave = false;

  @override
  void initState() {
    super.initState();

    _projectRepo = context.read<ProjectRepository>();
    _fs = context.read<FileSystem>();

    _toolTitleFieldFocus = FocusNode();

    _pianoBlock = Provider.of<ProjectBlock>(context, listen: false) as PianoBlock;
    _pianoBlock.timeLastModified = getCurrentDateTime();

    var projectLibrary = Provider.of<ProjectLibrary>(context, listen: false);
    projectLibrary.visitedToolsCounter++;

    unawaited(_projectRepo.saveLibrary(projectLibrary));

    piano = Piano(context.read<AudioSystem>(), context.read<AudioSession>(), context.read<FileSystem>());

    if (widget.withoutInitAndStart) {
      piano.restart();
    } else {
      piano.setVolume(_pianoBlock.volume);
      piano.setConcertPitch(_pianoBlock.concertPitch);
      piano.setSoundFont(SoundFont.values[_pianoBlock.soundFontIndex]);
      piano.start();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppOrientation.set(context, policy: OrientationPolicy.phoneLandscape);
      _createTutorial();
      _tutorial.show(context);
    });
  }

  void _createTutorial() {
    final l10n = context.l10n;
    final targets = <CustomTargetFocus>[
      if (context.read<ProjectLibrary>().showQuickToolTutorial && widget.isQuickTool)
        CustomTargetFocus(
          _keyBookmarkSave,
          l10n.toolTutorialSave,
          alignText: ContentAlign.custom,
          customTextPosition: CustomTargetContentPosition(
            left: MediaQuery.of(context).size.width / 3,
            right: MediaQuery.of(context).size.width / 3,
          ),
          pointingDirection: PointingDirection.right,
          pointerOffset: -25,
        ),
      if (context.read<ProjectLibrary>().showToolTutorial && !widget.isQuickTool)
        CustomTargetFocus(
          _keyBookmarkShare,
          l10n.appTutorialToolSave,
          alignText: ContentAlign.custom,
          customTextPosition: CustomTargetContentPosition(
            left: MediaQuery.of(context).size.width / 3,
            right: MediaQuery.of(context).size.width / 3,
          ),
          pointingDirection: PointingDirection.right,
          pointerOffset: -5,
        ),
      if (context.read<ProjectLibrary>().showPianoTutorial)
        CustomTargetFocus(
          _keyChangeTitle,
          l10n.toolTutorialEditTitle,
          alignText: ContentAlign.right,
          pointingDirection: PointingDirection.left,
          shape: ShapeLightFocus.RRect,
        ),
      if (context.read<ProjectLibrary>().showPianoTutorial)
        CustomTargetFocus(
          _keyOctaveSwitch,
          l10n.pianoTutorialChangeKeyOrOctave,
          alignText: ContentAlign.right,
          pointingDirection: PointingDirection.left,
          shape: ShapeLightFocus.RRect,
        ),
      if (context.read<ProjectLibrary>().showPianoTutorial)
        CustomTargetFocus(
          _keySettings,
          l10n.pianoTutorialAdjust,
          alignText: ContentAlign.custom,
          customTextPosition: CustomTargetContentPosition(
            top: MediaQuery.of(context).size.height / 5,
            left: MediaQuery.of(context).size.width / 3,
            right: MediaQuery.of(context).size.width / 3,
          ),
          pointingDirection: PointingDirection.up,
          shape: ShapeLightFocus.RRect,
          buttonsPosition: ButtonsPosition.bottomright,
        ),
      if (context.read<ProjectLibrary>().showPianoIslandTutorial && !widget.isQuickTool)
        CustomTargetFocus(
          _keyIsland,
          l10n.pianoTutorialIslandTool,
          // hideBack: true,
          alignText: ContentAlign.custom,
          customTextPosition: CustomTargetContentPosition(
            top: MediaQuery.of(context).size.height / 8,
            left: MediaQuery.of(context).size.width / 6,
            right: MediaQuery.of(context).size.width / 3,
          ),
          pointingDirection: PointingDirection.up,
          pointerOffset: 120,
          shape: ShapeLightFocus.RRect,
          buttonsPosition: ButtonsPosition.bottomright,
        ),
    ];

    if (targets.isEmpty) {
      return;
    } else {
      targets.first.hideBack = true;
    }
    _tutorial.create(targets.map((e) => e.targetFocus).toList(), () async {
      if (context.read<ProjectLibrary>().showPianoTutorial) {
        context.read<ProjectLibrary>().showPianoTutorial = false;
      }

      if (context.read<ProjectLibrary>().showQuickToolTutorial && widget.isQuickTool) {
        context.read<ProjectLibrary>().showQuickToolTutorial = false;
      }

      if (context.read<ProjectLibrary>().showToolTutorial && !widget.isQuickTool) {
        context.read<ProjectLibrary>().showToolTutorial = false;
      }

      if (context.read<ProjectLibrary>().showPianoIslandTutorial && !widget.isQuickTool) {
        context.read<ProjectLibrary>().showPianoIslandTutorial = false;
      }

      await _projectRepo.saveLibrary(context.read<ProjectLibrary>());
    }, context);
  }

  @override
  void deactivate() {
    // don't stop if we save or copy the piano
    if (!_dontStopOnLeave) piano.stop();
    super.deactivate();
  }

  @override
  void dispose() {
    _toolTitleFieldFocus.dispose();
    piano.stop();
    _tutorial.dispose();
    super.dispose();
  }

  Future<void> handleOnOpenPitch() async {
    await openSettingPage(
      SetConcertPitch(),
      context,
      _pianoBlock,
      callbackOnReturn: (_) => piano.setConcertPitch(_pianoBlock.concertPitch),
    );
    setState(() {});
  }

  Future<void> handleOnOpenVolume() async {
    await openSettingPage(
      SetVolume(
        initialVolume: _pianoBlock.volume,
        onConfirm: (vol) {
          _pianoBlock.volume = vol;
          piano.setVolume(vol);
        },
        onChange: (vol) => piano.setVolume(vol),
        onCancel: () => piano.setVolume(_pianoBlock.volume),
      ),
      context,
      _pianoBlock,
      callbackOnReturn: (_) => setState(() {}),
    );
  }

  Future<void> handleOnOpenSound() async {
    await openSettingPage(
      const ChooseSound(),
      context,
      _pianoBlock,
      callbackOnReturn: (_) async {
        await piano.setSoundFont(SoundFont.values[_pianoBlock.soundFontIndex]);
        if (mounted) setState(() {});
      },
    );
  }

  void handleToggleHold() => setState(() => _isHolding = !_isHolding);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorTheme.primary92,
      body: _showSavingPage ? _buildSavingPage() : _buildPianoMainPage(context),
    );
  }

  Widget _buildPianoMainPage(BuildContext context) {
    final Project? project = widget.isQuickTool ? null : context.read<Project>();
    final islandWidth = MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width / 1.9);
    final l10n = context.l10n;
    final double deviceEdgeInset = Platform.isAndroid ? 8 : 0;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(right: deviceEdgeInset, bottom: deviceEdgeInset),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BackButton(
                  color: ColorTheme.primary,
                  onPressed: () async {
                    final navigator = Navigator.of(context);

                    if (widget.isQuickTool && !blockValuesSameAsDefaultBlock(_pianoBlock, l10n)) {
                      final save = await askForSavingQuickTool(context);
                      if (!context.mounted) return;
                      if (save == null) return;

                      if (save) {
                        setState(() {
                          _showSavingPage = true;
                        });
                        return;
                      }

                      AppOrientation.set(context, policy: OrientationPolicy.phonePortrait);
                      navigator.pop();
                      return;
                    }

                    AppOrientation.set(context, policy: OrientationPolicy.phonePortrait);
                    navigator.pop();
                  },
                ),

                // title
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final newTitle = await showFlatEditTextDialog(
                        context: context,
                        label: l10n.toolNewTitle,
                        value: _pianoBlock.title,
                      );
                      if (newTitle == null) return;
                      _pianoBlock.title = newTitle;
                      if (context.mounted) {
                        await _projectRepo.saveLibrary(context.read<ProjectLibrary>());
                      }
                      setState(() {});
                    },
                    child: Column(
                      key: _keyChangeTitle,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _pianoBlock.title,
                          style: const TextStyle(color: ColorTheme.primary, fontSize: TIOMusicParams.titleFontSize),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: const TextStyle(color: ColorTheme.primary),
                            children: [
                              TextSpan(
                                text: '${l10n.formatNumber(piano.concertPitch)} Hz – ${piano.soundFont.getLabel(l10n)}',
                              ),
                              if (piano.soundFont.canHold)
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 2),
                                    child: SvgPicture.asset(
                                      PianoParams.pedalIcon,
                                      height: 14,
                                      width: 14,
                                      colorFilter: const ColorFilter.mode(ColorTheme.primary, BlendMode.srcIn),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // island
                SizedBox(
                  key: _keyIsland,
                  height: ParentToolParams.islandHeight,
                  width: islandWidth,
                  child: ParentIslandView(project: project, toolBlock: _pianoBlock),
                ),
                Row(
                  children: [
                    // save button
                    IconButton(
                      key: widget.isQuickTool ? _keyBookmarkSave : _keyBookmarkShare,
                      onPressed: () {
                        setState(() {
                          _showSavingPage = true;
                        });
                      },
                      icon: Icon(
                        widget.isQuickTool ? Icons.bookmark_outline : Icons.bookmark_add_outlined,
                        color: ColorTheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (widget.isQuickTool)
                      PianoNavigationBar(
                        keyOctaveSwitch: _keyOctaveSwitch,
                        keySettings: _keySettings,
                        isHolding: _isHolding,
                        onOctaveDown: _pianoBlock.octaveDown,
                        onToneDown: _pianoBlock.toneDown,
                        onToneUp: _pianoBlock.toneUp,
                        onOctaveUp: _pianoBlock.octaveUp,
                        onOpenPitch: handleOnOpenPitch,
                        onOpenVolume: handleOnOpenVolume,
                        onOpenSound: handleOnOpenSound,
                        onToggleHold: piano.soundFont.canHold ? handleToggleHold : null,
                      )
                    else
                      PianoToolNavigationBar(
                        project: project!,
                        keyOctaveSwitch: _keyOctaveSwitch,
                        keySettings: _keySettings,
                        isHolding: _isHolding,
                        toolBlock: _pianoBlock,
                        onOctaveDown: _pianoBlock.octaveDown,
                        onToneDown: _pianoBlock.toneDown,
                        onToneUp: _pianoBlock.toneUp,
                        onOctaveUp: _pianoBlock.octaveUp,
                        onOpenPitch: handleOnOpenPitch,
                        onOpenVolume: handleOnOpenVolume,
                        onOpenSound: handleOnOpenSound,
                        onToggleHold: piano.soundFont.canHold ? handleToggleHold : null,
                      ),

                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      top: 52,
                      child: Container(
                        decoration: BoxDecoration(
                          color: ColorTheme.primaryFixedDim,
                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Consumer<ProjectBlock>(
                          builder: (context, projectBlock, child) {
                            final pianoBlock = projectBlock as PianoBlock;
                            return Keyboard(
                              lowestNote: pianoBlock.keyboardPosition,
                              isHolding: _isHolding,
                              onPlay: piano.playNote,
                              onRelease: piano.releaseNote,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // this is to replace the bottom sheet like the other tools are using it for saving
  Widget _buildSavingPage() {
    final l10n = context.l10n;

    return SafeArea(
      child: Consumer<ProjectLibrary>(
        builder: (context, projectLibrary, child) {
          return Column(
            children: [
              ColoredBox(
                color: ColorTheme.surface,
                child: Column(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: CardListTile(
                            title: _pianoBlock.title,
                            subtitle: formatSettingValues(_pianoBlock.getSettingsFormatted(l10n)),
                            trailingIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _showSavingPage = false;
                                });
                              },
                              icon: const Icon(Icons.close, color: ColorTheme.primary),
                            ),
                            leadingPicture: circleToolIcon(_pianoBlock.icon),
                            onTapFunction: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ColoredBox(
                  color: ColorTheme.primary80,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 32),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: widget.isQuickTool
                              ? Text(l10n.toolSaveIn, style: TextStyle(fontSize: 18, color: ColorTheme.surfaceTint))
                              : Text(l10n.toolSaveCopy, style: TextStyle(fontSize: 18, color: ColorTheme.surfaceTint)),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: TIOMusicParams.smallSpaceAboveList),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: projectLibrary.projects.length,
                            itemBuilder: (context, index) {
                              return StatefulBuilder(
                                builder: (context, setTileState) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    child: CardListTile(
                                      title: projectLibrary.projects[index].title,
                                      subtitle: l10n.formatDateAndTime(projectLibrary.projects[index].timeLastModified),
                                      highlightColor: _highlightColorOnSave,
                                      trailingIcon: IconButton(
                                        onPressed: () => _buildTextInputOverlay(setTileState, index),
                                        icon: _bookmarkIcon,
                                        color: ColorTheme.surfaceTint,
                                      ),
                                      leadingPicture: projectLibrary.projects[index].thumbnailPath.isEmpty
                                          ? const AssetImage(TIOMusicParams.tiomusicIconPath)
                                          : FileImage(
                                              File(
                                                _fs.toAbsoluteFilePath(projectLibrary.projects[index].thumbnailPath),
                                              ),
                                            ),
                                      onTapFunction: () => _buildTextInputOverlay(setTileState, index),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      TIOFlatButton(
                        // creating a new project to save the tool in it
                        onPressed: _buildTwoTextInputOverlay,
                        text: l10n.toolSaveInNewProject,
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _buildTextInputOverlay(StateSetter setTileState, int index) {
    final l10n = context.l10n;
    final overlay = Overlay.of(context);

    _newToolTitle.text = '${_pianoBlock.title} - ${l10n.toolTitleCopy}';
    _newToolTitle.selection = TextSelection(baseOffset: 0, extentOffset: _newToolTitle.text.length);

    _entry = OverlayEntry(
      builder: (context) => Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: ColorTheme.primary92,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(TIOMusicParams.edgeInset),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  // textfield for new tool title
                  child: TextField(
                    controller: _newToolTitle,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: '',
                      border: OutlineInputBorder(borderSide: BorderSide(color: ColorTheme.primary)),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorTheme.primary)),
                      label: Text('${l10n.toolNewTitle}:', style: TextStyle(color: ColorTheme.surfaceTint)),
                    ),
                    style: const TextStyle(color: ColorTheme.primary),
                    onSubmitted: (newText) {
                      _newToolTitle.text = newText;
                      // close
                      _hideTextInputOverlay(true, setTileState, index);
                    },
                  ),
                ),
                // close button
                TextButton(
                  onPressed: () => _hideTextInputOverlay(false, setTileState, index),
                  child: Text(l10n.commonCancel),
                ),
                TIOFlatButton(
                  onPressed: () => _hideTextInputOverlay(true, setTileState, index),
                  text: l10n.commonSubmit,
                  boldText: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(_entry!);
  }

  void _buildTwoTextInputOverlay() {
    final l10n = context.l10n;
    final overlay = Overlay.of(context);

    _newToolTitle.text = '${_pianoBlock.title} - ${l10n.toolTitleCopy}';
    _newToolTitle.selection = TextSelection(baseOffset: 0, extentOffset: _newToolTitle.text.length);

    _newProjectTitle.text = l10n.formatDateAndTime(DateTime.now());
    _newProjectTitle.selection = TextSelection(baseOffset: 0, extentOffset: _newProjectTitle.text.length);

    _entry = OverlayEntry(
      builder: (context) => Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: ColorTheme.primary92,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(TIOMusicParams.edgeInset),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // textfield for new project title
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3.5,
                  child: TextField(
                    controller: _newProjectTitle,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: '',
                      border: OutlineInputBorder(borderSide: BorderSide(color: ColorTheme.primary)),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorTheme.primary)),
                      label: Text('${l10n.toolNewProjectTitle}:', style: TextStyle(color: ColorTheme.surfaceTint)),
                    ),
                    style: const TextStyle(color: ColorTheme.primary),
                    onSubmitted: (newText) {
                      _newProjectTitle.text = newText;
                      // focus next text field
                      _toolTitleFieldFocus.requestFocus();
                    },
                  ),
                ),
                // textfield for new tool title
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3.5,
                  child: TextField(
                    controller: _newToolTitle,
                    focusNode: _toolTitleFieldFocus,
                    decoration: InputDecoration(
                      hintText: '',
                      border: OutlineInputBorder(borderSide: BorderSide(color: ColorTheme.primary)),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorTheme.primary)),
                      label: Text('${l10n.toolNewTitle}:', style: TextStyle(color: ColorTheme.surfaceTint)),
                    ),
                    style: const TextStyle(color: ColorTheme.primary),
                    onSubmitted: (newText) {
                      _newToolTitle.text = newText;
                      // close
                      _hideTwoTextInputOverlay(true);
                    },
                  ),
                ),

                TextButton(onPressed: () => _hideTwoTextInputOverlay(false), child: Text(l10n.commonCancel)),
                TIOFlatButton(onPressed: () => _hideTwoTextInputOverlay(true), text: l10n.commonSubmit, boldText: true),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(_entry!);
  }

  void _hideTextInputOverlay(bool submitted, StateSetter setTileState, int index) async {
    _entry?.remove();
    _entry = null;

    if (submitted) {
      // this little delay is necessary to make the highlighting work, without the delay all list tiles are highlighted
      await Future.delayed(const Duration(milliseconds: 500));

      // highlight tile and change icon to get a tick mark
      setTileState(() {
        _bookmarkIcon = const Icon(Icons.bookmark_added_outlined);
        _highlightColorOnSave = ColorTheme.primaryFixedDim;
      });
      await Future.delayed(const Duration(seconds: 2));
      // saving the tool in a project
      if (mounted) {
        _dontStopOnLeave = true;
        await saveToolInProject(
          context,
          index,
          _pianoBlock,
          widget.isQuickTool,
          _newToolTitle.text,
          pianoAlreadyOn: true,
        );
      }
    }
  }

  void _hideTwoTextInputOverlay(bool submitted) {
    _entry?.remove();
    _entry = null;

    if (submitted) {
      _dontStopOnLeave = true;
      saveToolInNewProject(
        context,
        _pianoBlock,
        widget.isQuickTool,
        _newProjectTitle.text,
        _newToolTitle.text,
        pianoAlreadyOn: true,
      );
    }
  }
}
