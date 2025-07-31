import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/piano_block.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/models/sound_font.dart';
import 'package:tiomusic/services/audio_session.dart';
import 'package:tiomusic/widgets/parent_tool/parent_island_view.dart';
import 'package:tiomusic/pages/parent_tool/setting_volume_page.dart';
import 'package:tiomusic/pages/piano/choose_sound.dart';
import 'package:tiomusic/pages/piano/set_concert_pitch.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/l10n/sound_font_extensions.dart';
import 'package:tiomusic/util/tutorial_util.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/card_list_tile.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tiomusic/widgets/input/flat_edit_text_dialog.dart';
import 'package:tiomusic/widgets/piano/keyboard.dart';
import 'package:tiomusic/widgets/piano/piano_navigation_bar.dart';
import 'package:tiomusic/widgets/piano/piano_tool_navigation_bar.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class Piano extends StatefulWidget {
  final bool isQuickTool;
  final bool withoutInitAndStart;

  const Piano({super.key, required this.isQuickTool, this.withoutInitAndStart = false});

  @override
  State<Piano> createState() => _PianoState();
}

class _PianoState extends State<Piano> {
  late AudioSystem _as;
  late AudioSession _audioSession;
  late FileSystem _fs;
  late ProjectRepository _projectRepo;

  bool _isHolding = false;

  late PianoBlock _pianoBlock;
  late double _concertPitch = _pianoBlock.concertPitch;
  late SoundFont _soundFont = SoundFont.values[_pianoBlock.soundFontIndex];

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

  AudioSessionInterruptionListenerHandle? _audioSessionInterruptionListenerHandle;
  bool _isPlaying = false;

  bool _dontStopOnLeave = false;

  @override
  void initState() {
    super.initState();

    _as = context.read<AudioSystem>();
    _audioSession = context.read<AudioSession>();
    _fs = context.read<FileSystem>();
    _projectRepo = context.read<ProjectRepository>();

    // lock screen to only use landscape
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);

    _toolTitleFieldFocus = FocusNode();

    _pianoBlock = Provider.of<ProjectBlock>(context, listen: false) as PianoBlock;
    _pianoBlock.timeLastModified = getCurrentDateTime();

    var projectLibrary = Provider.of<ProjectLibrary>(context, listen: false);
    projectLibrary.visitedToolsCounter++;

    unawaited(_projectRepo.saveLibrary(projectLibrary));

    if (widget.withoutInitAndStart) {
      _isPlaying = true;
    } else {
      _pianoStart();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<ProjectLibrary>().showPianoTutorial) {
        _createTutorial();
        _tutorial.show(context);
      }
    });
  }

  void _playNoteOn(int note) => _as.pianoNoteOn(note: note);

  void _playNoteOff(int note) => _as.pianoNoteOff(note: note);

  Future<void> _pianoStart() async {
    if (_isPlaying) return;
    _audioSessionInterruptionListenerHandle = await _audioSession.registerInterruptionListener(_pianoStop);

    bool initSuccess = await _initPiano(SoundFont.values[_pianoBlock.soundFontIndex].file);
    await _audioSession.preparePlayback();
    if (!initSuccess) return;

    _pianoSetConcertPitch(_pianoBlock.concertPitch);

    bool success = await _as.pianoStart();
    _isPlaying = success;
  }

  Future<void> _pianoStop() async {
    if (_audioSessionInterruptionListenerHandle != null) {
      _audioSession.unregisterInterruptionListener(_audioSessionInterruptionListenerHandle!);
      _audioSessionInterruptionListenerHandle = null;
    }
    if (_isPlaying) {
      await _as.pianoStop();
    }
    _isPlaying = false;
  }

  Future<void> _pianoSetConcertPitch(double concertPitch) async {
    bool success = await _as.pianoSetConcertPitch(newConcertPitch: concertPitch);

    if (!success) {
      throw 'Rust library failed to update new concert pitch: $concertPitch';
    }
  }

  void _createTutorial() {
    var targets = <CustomTargetFocus>[
      CustomTargetFocus(
        _keyOctaveSwitch,
        context.l10n.pianoTutorialChangeKeyOrOctave,
        alignText: ContentAlign.right,
        pointingDirection: PointingDirection.left,
        shape: ShapeLightFocus.RRect,
        pointerPosition: PointerPosition.left,
        buttonsPosition: ButtonsPosition.bottomright,
      ),
      CustomTargetFocus(
        _keySettings,
        context.l10n.pianoTutorialAdjust,
        alignText: ContentAlign.left,
        pointingDirection: PointingDirection.right,
        shape: ShapeLightFocus.RRect,
        buttonsPosition: ButtonsPosition.bottomright,
      ),
    ];
    _tutorial.create(targets.map((e) => e.targetFocus).toList(), () async {
      context.read<ProjectLibrary>().showPianoTutorial = false;
      await _projectRepo.saveLibrary(context.read<ProjectLibrary>());
    }, context);
  }

  @override
  void deactivate() {
    // don't stop if we save or copy the piano
    if (!_dontStopOnLeave) {
      _pianoStop();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _toolTitleFieldFocus.dispose();
    super.dispose();
  }

  Future<bool> _initPiano(String soundFontPath) async {
    // rust cannot access asset files which are not really files on disk, so we need to copy to a temp file
    final tempSoundFontPath = '${_fs.tmpFolderPath}/sound_font.sf2';
    final byteData = await rootBundle.load(soundFontPath);
    final bytes = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    await _fs.saveFileAsBytes(tempSoundFontPath, bytes);
    return _as.pianoSetup(soundFontPath: tempSoundFontPath);
  }

  Future<void> handleOnOpenPitch() async {
    await openSettingPage(
      SetConcertPitch(),
      callbackOnReturn: (_) => _pianoSetConcertPitch(_pianoBlock.concertPitch),
      context,
      _pianoBlock,
    );
    setState(() => _concertPitch = _pianoBlock.concertPitch);
  }

  Future<void> handleOnOpenVolume() async {
    await openSettingPage(
      SetVolume(
        initialValue: _pianoBlock.volume,
        onConfirm: (vol) {
          _pianoBlock.volume = vol;
          _as.pianoSetVolume(volume: vol);
        },
        onChange: (vol) => _as.pianoSetVolume(volume: vol),
        onCancel: () => _as.pianoSetVolume(volume: _pianoBlock.volume),
      ),
      callbackOnReturn: (_) => setState(() {}),
      context,
      _pianoBlock,
    );
  }

  Future<void> handleOnOpenSound() async {
    await openSettingPage(const ChooseSound(), context, _pianoBlock);
    _initPiano(SoundFont.values[_pianoBlock.soundFontIndex].file);
    setState(() => _soundFont = SoundFont.values[_pianoBlock.soundFontIndex]);
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

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // close button
              BackButton(
                color: ColorTheme.primary,
                onPressed: () async {
                  // if quick tool and values have been changed: ask for saving
                  if (widget.isQuickTool && !blockValuesSameAsDefaultBlock(_pianoBlock, l10n)) {
                    final save = await askForSavingQuickTool(context);

                    // if user taps outside the dialog, we dont want to exit the quick tool and we dont want to save
                    if (save == null) return;

                    if (save) {
                      setState(() {
                        _showSavingPage = true;
                      });
                    } else {
                      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                      if (context.mounted) Navigator.of(context).pop();
                    }
                  } else {
                    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                    Navigator.of(context).pop();
                  }
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _pianoBlock.title,
                        style: const TextStyle(color: ColorTheme.primary, fontSize: TIOMusicParams.titleFontSize),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${l10n.formatNumber(_concertPitch)} Hz – ${_soundFont.getLabel(l10n)}',
                        style: const TextStyle(color: ColorTheme.primary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              // island
              SizedBox(
                height: ParentToolParams.islandHeight,
                width: islandWidth,
                child: ParentIslandView(project: project, toolBlock: _pianoBlock),
              ),
              Row(
                children: [
                  // save button
                  IconButton(
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
                      onToggleHold: _soundFont.canHold ? handleToggleHold : null,
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
                      onToggleHold: _soundFont.canHold ? handleToggleHold : null,
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
                            onPlay: _playNoteOn,
                            onRelease: _playNoteOff,
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
                        CardListTile(
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
                          child:
                              widget.isQuickTool
                                  ? Text(l10n.toolSave, style: TextStyle(fontSize: 18, color: ColorTheme.surfaceTint))
                                  : Text(
                                    l10n.toolSaveCopy,
                                    style: TextStyle(fontSize: 18, color: ColorTheme.surfaceTint),
                                  ),
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
                                  return CardListTile(
                                    title: projectLibrary.projects[index].title,
                                    subtitle: l10n.formatDateAndTime(projectLibrary.projects[index].timeLastModified),
                                    highlightColor: _highlightColorOnSave,
                                    trailingIcon: IconButton(
                                      onPressed: () => _buildTextInputOverlay(setTileState, index),
                                      icon: _bookmarkIcon,
                                      color: ColorTheme.surfaceTint,
                                    ),
                                    leadingPicture:
                                        projectLibrary.projects[index].thumbnailPath.isEmpty
                                            ? const AssetImage(TIOMusicParams.tiomusicIconPath)
                                            : FileImage(
                                              File(
                                                _fs.toAbsoluteFilePath(projectLibrary.projects[index].thumbnailPath),
                                              ),
                                            ),
                                    onTapFunction: () => _buildTextInputOverlay(setTileState, index),
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
      builder:
          (context) => Scaffold(
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
      builder:
          (context) => Scaffold(
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
                    TIOFlatButton(
                      onPressed: () => _hideTwoTextInputOverlay(true),
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
