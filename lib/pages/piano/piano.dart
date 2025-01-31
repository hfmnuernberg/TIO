import 'dart:async';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/blocks/piano_block.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/parent_tool/parent_island_view.dart';
import 'package:tiomusic/pages/parent_tool/setting_volume_page.dart';
import 'package:tiomusic/pages/piano/choose_sound.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/util/audio_util.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/util/util_midi.dart';
import 'package:tiomusic/util/walkthrough_util.dart';
import 'package:tiomusic/widgets/card_list_tile.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tiomusic/widgets/input/edit_text_dialog.dart';
import 'package:tonic/tonic.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class Piano extends StatefulWidget {
  final bool isQuickTool;
  final bool withoutInitAndStart;

  const Piano({super.key, required this.isQuickTool, this.withoutInitAndStart = false});

  @override
  State<Piano> createState() => _PianoState();
}

class _PianoState extends State<Piano> {
  late PianoBlock _pianoBlock;

  Icon _bookmarkIcon = const Icon(Icons.bookmark_add_outlined);
  Color? _highlightColorOnSave;

  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _newToolTitle = TextEditingController();
  final TextEditingController _newProjectTitle = TextEditingController();
  late FocusNode _toolTitleFieldFocus;

  bool _showSavingPage = false;
  OverlayEntry? _entry;

  final Walkthrough _walkthrough = Walkthrough();
  final GlobalKey _keyOctaveSwitch = GlobalKey();
  final GlobalKey _keySettings = GlobalKey();

  StreamSubscription<AudioInterruptionEvent>? audioInterruptionListener;
  bool _isPlaying = false;

  bool _dontStopOnLeave = false;

  @override
  void initState() {
    super.initState();

    // lock screen to only use landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    _toolTitleFieldFocus = FocusNode();

    _pianoBlock = Provider.of<ProjectBlock>(context, listen: false) as PianoBlock;
    _pianoBlock.timeLastModified = getCurrentDateTime();

    _titleController.text = _pianoBlock.title;

    var projectLibrary = Provider.of<ProjectLibrary>(context, listen: false);
    projectLibrary.visitedToolsCounter++;

    FileIO.saveProjectLibraryToJson(projectLibrary);

    if (widget.withoutInitAndStart) {
      _isPlaying = true;
    } else {
      _pianoStart();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<ProjectLibrary>().showPianoTutorial) {
        _createWalkthrough();
        _walkthrough.show(context);
      }
    });
  }

  Future<void> _pianoStart() async {
    if (_isPlaying) return;
    audioInterruptionListener = (await AudioSession.instance).interruptionEventStream.listen((event) {
      if (event.type == AudioInterruptionType.unknown) _pianoStop();
    });

    bool initSuccess = await _initPiano(PianoParams.soundFontPaths[_pianoBlock.soundFontIndex]);
    await configureAudioSession(AudioSessionType.playback);
    if (!initSuccess) return;
    bool success = await pianoStart();
    _isPlaying = success;
  }

  Future<void> _pianoStop() async {
    await audioInterruptionListener?.cancel();
    if (_isPlaying) {
      await pianoStop();
    }
    _isPlaying = false;
  }

  void _createWalkthrough() {
    // add the targets here
    var targets = <CustomTargetFocus>[
      CustomTargetFocus(
        _keyOctaveSwitch,
        "Tap the left or right arrows to move up or down per key or per octave",
        alignText: ContentAlign.right,
        pointingDirection: PointingDirection.left,
        shape: ShapeLightFocus.RRect,
        pointerPosition: PointerPosition.left,
        buttonsPosition: ButtonsPosition.bottomright,
      ),
      CustomTargetFocus(
        _keySettings,
        "Tap here to adjust sound and volume",
        alignText: ContentAlign.top,
        pointingDirection: PointingDirection.down,
        shape: ShapeLightFocus.RRect,
        buttonsPosition: ButtonsPosition.bottomright,
      ),
    ];
    _walkthrough.create(
      targets.map((e) => e.targetFocus).toList(),
      () {
        context.read<ProjectLibrary>().showPianoTutorial = false;
        FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
      },
      context,
    );
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
    Directory tempDir = await getTemporaryDirectory();
    String tempSoundFontPath = "${tempDir.path}/sound_font.sf2";
    // rust cannot access asset files which are not really files on disk, so we need to copy to a temp file
    final byteData = await rootBundle.load(soundFontPath);
    final file = File(tempSoundFontPath);
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return await pianoSetup(soundFontPath: tempSoundFontPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorTheme.primary92,
      body: _showSavingPage ? _buildSavingPage() : _buildPianoMainPage(context),
    );
  }

  Widget _buildPianoMainPage(BuildContext context) {
    final islandWidth = MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width / 1.9);

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // close button
              IconButton(
                  onPressed: () async {
                    // if quick tool and values have been changed: ask for saving
                    if (widget.isQuickTool && !blockValuesSameAsDefaultBlock(_pianoBlock)) {
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
                  icon: const Icon(
                    Icons.arrow_back,
                    color: ColorTheme.primary,
                  )),

              // title
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final newTitle = await showEditTextDialog(
                      context: context,
                      label: PianoParams.displayName,
                      value: _pianoBlock.title,
                    );
                    if (newTitle == null || newTitle.isEmpty) return;
                    _pianoBlock.title = newTitle;
                    if (context.mounted) FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
                    setState(() {});
                  },
                  child: Text(
                    _pianoBlock.title,
                    style: const TextStyle(color: ColorTheme.primary, fontSize: TIOMusicParams.titleFontSize),
                  ),
                ),
              ),

              // island
              SizedBox(
                height: ParentToolParams.islandHeight,
                width: islandWidth,
                child: ParentIslandView(
                  project: widget.isQuickTool ? null : Provider.of<Project>(context, listen: false),
                  toolBlock: _pianoBlock,
                ),
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
          // piano
          Expanded(
            child: Container(
                decoration: const BoxDecoration(
                  color: ColorTheme.primaryFixedDim,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // settings row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          key: _keyOctaveSwitch,
                          children: [
                            // octave down button
                            IconButton(
                              onPressed: _pianoBlock.octaveDown,
                              icon: const Icon(Icons.keyboard_double_arrow_left, color: ColorTheme.primary),
                            ),

                            IconButton(
                              onPressed: _pianoBlock.toneDown,
                              icon: const Icon(Icons.keyboard_arrow_left, color: ColorTheme.primary),
                            ),
                          ],
                        ),
                        Row(
                          key: _keySettings,
                          children: [
                            // sound button
                            IconButton(
                              onPressed: () async {
                                await openSettingPage(const ChooseSound(), context, _pianoBlock);

                                _initPiano(PianoParams.soundFontPaths[_pianoBlock.soundFontIndex]);
                              },
                              icon: const CircleAvatar(
                                backgroundColor: ColorTheme.primary50,
                                child: Icon(
                                  Icons.library_music_outlined,
                                  color: ColorTheme.onPrimary,
                                ),
                              ),
                            ),

                            // volume button
                            IconButton(
                              onPressed: () async {
                                await openSettingPage(
                                  SetVolume(
                                    initialValue: _pianoBlock.volume,
                                    onConfirm: (vol) {
                                      _pianoBlock.volume = vol;
                                      pianoSetVolume(volume: vol);
                                    },
                                    onUserChangedVolume: (vol) => pianoSetVolume(volume: vol),
                                    onCancel: () => pianoSetVolume(volume: _pianoBlock.volume),
                                  ),
                                  callbackOnReturn: (value) => setState(() {}),
                                  context,
                                  _pianoBlock,
                                );
                              },
                              icon: const CircleAvatar(
                                backgroundColor: ColorTheme.primary50,
                                child: Icon(
                                  Icons.volume_up,
                                  color: ColorTheme.onPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // octave up button
                            IconButton(
                              onPressed: _pianoBlock.toneUp,
                              icon: const Icon(Icons.keyboard_arrow_right, color: ColorTheme.primary),
                            ),

                            IconButton(
                              onPressed: _pianoBlock.octaveUp,
                              icon: const Icon(Icons.keyboard_double_arrow_right, color: ColorTheme.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // keys
                    Consumer<ProjectBlock>(
                      builder: (context, projectBlock, child) {
                        var pianoBlock = projectBlock as PianoBlock;
                        return Expanded(
                          child: LayoutBuilder(
                            builder: (BuildContext context, BoxConstraints constraints) {
                              const double spaceBetweenKeys = 8;
                              final keyWidth = constraints.maxWidth / 12 - spaceBetweenKeys;
                              final keyHeight = constraints.maxHeight;
                              return _keyboard(pianoBlock.keyboardPosition, keyWidth, keyHeight);
                            },
                          ),
                        );
                      },
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget _keyboard(int lowestKey, double keyWidth, double keyHeight) {
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _buildWhiteKeyRow(lowestKey, keyWidth, keyHeight),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _buildBlackKeyRow(lowestKey, keyWidth, keyHeight),
        ),
      ],
    );
  }

  List<Widget> _buildWhiteKeyRow(int lowestKey, double keyWidth, double keyHeight) {
    var keys = <Widget>[];
    var midi = lowestKey;
    for (int i = 0; i < PianoParams.numberOfWhiteKeys; i++) {
      if (midiToName(midi).length > 1) {
        midi++;
      }
      keys.add(_whiteKey(midi, keyWidth, keyHeight));
      midi++;
    }
    return keys;
  }

  List<Widget> _buildBlackKeyRow(int lowestKey, double keyWidth, double keyHeight) {
    var keys = <Widget>[];
    var midi = lowestKey;
    keys.add(_spacingKey(keyWidth, keyHeight, true));

    for (int i = 0; i < PianoParams.numberOfWhiteKeys - 1; i++) {
      if (midiToName(midi).length > 1) {
        midi++;
      }
      if (midiToName(midi + 1).length > 1) {
        keys.add(_blackKey(midi + 1, keyWidth, keyHeight));
      } else {
        keys.add(_spacingKey(keyWidth, keyHeight, false));
      }
      midi++;
    }

    keys.add(_spacingKey(keyWidth, keyHeight, true));
    return keys;
  }

  Widget _blackKey(int midi, double width, double height) {
    return SizedBox(
      width: width,
      height: height / 2,
      child: Stack(
        children: [
          Container(
            color: ColorTheme.tertiary,
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
            child: Container(
              color: ColorTheme.onTertiaryFixed,
            ),
          ),
          Semantics(
            button: true,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onTapDown: (_) async {
                  if (!_isPlaying) _pianoStart();
                  await pianoNoteOn(note: midi);
                },
                onTapUp: (_) async => await pianoNoteOff(note: midi),
                onTapCancel: () async => await pianoNoteOff(note: midi),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: _showLabelOnC(midi),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _whiteKey(int midi, double width, double height) {
    return SizedBox(
      width: width,
      child: Semantics(
        button: true,
        child: Material(
          color: Colors.white,
          child: InkWell(
            splashColor: ColorTheme.secondaryContainer,
            highlightColor: ColorTheme.secondaryContainer,
            onTapDown: (_) async {
              if (!_isPlaying) _pianoStart();
              await pianoNoteOn(note: midi);
            },
            onTapUp: (_) async => await pianoNoteOff(note: midi),
            onTapCancel: () async => await pianoNoteOff(note: midi),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _showLabelOnC(midi),
            ),
          ),
        ),
      ),
    );
  }

  Widget _spacingKey(double width, double height, bool half) {
    return SizedBox(
      width: half ? width / 2 : width,
    );
  }

  Widget _showLabelOnC(int midi) {
    if (midi % 12 == 0) {
      return _getPitchText(midi);
    } else {
      return Container();
    }
  }

  Widget _getPitchText(int midi) {
    final pitchName = Pitch.fromMidiNumber(midi).toString();
    return Text(
      pitchName,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: ColorTheme.primaryFixedDim,
        fontSize: 20,
      ),
    );
  }

  // this is to replace the bottom sheet like the other tools are using it for saving
  Widget _buildSavingPage() {
    return SafeArea(
      child: Consumer<ProjectLibrary>(
        builder: (context, projectLibrary, child) {
          return Column(
            children: [
              Container(
                color: ColorTheme.surface,
                child: Column(
                  children: [
                    Column(
                      children: [
                        CardListTile(
                          title: _pianoBlock.title,
                          subtitle: formatSettingValues(_pianoBlock.getSettingsFormatted()),
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
                child: Container(
                  color: ColorTheme.primary80,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 32),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: widget.isQuickTool
                              ? const Text(
                                  "Save in ...",
                                  style: TextStyle(fontSize: 18, color: ColorTheme.surfaceTint),
                                )
                              : const Text(
                                  "Save copy in ...",
                                  style: TextStyle(fontSize: 18, color: ColorTheme.surfaceTint),
                                ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: TIOMusicParams.smallSpaceAboveList),
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: projectLibrary.projects.length,
                            itemBuilder: (BuildContext context, int index) {
                              return StatefulBuilder(
                                builder: (BuildContext context, StateSetter setTileState) {
                                  return CardListTile(
                                    title: projectLibrary.projects[index].title,
                                    subtitle: getDateAndTimeFormatted(projectLibrary.projects[index].timeLastModified),
                                    highlightColor: _highlightColorOnSave,
                                    trailingIcon: IconButton(
                                      onPressed: () => _buildTextInputOverlay(setTileState, index),
                                      icon: _bookmarkIcon,
                                      color: ColorTheme.surfaceTint,
                                    ),
                                    leadingPicture: projectLibrary.projects[index].thumbnail,
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
                        text: "Save in a new project",
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
    final overlay = Overlay.of(context);

    _newToolTitle.text = "${_pianoBlock.title} - copy";
    _newToolTitle.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _newToolTitle.text.length,
    );

    _entry = OverlayEntry(
      builder: (context) => Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: ColorTheme.primary92,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(TIOMusicParams.edgeInset),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  // textfield for new tool title
                  child: TextField(
                    controller: _newToolTitle,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: "",
                      border: OutlineInputBorder(borderSide: BorderSide(color: ColorTheme.primary)),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorTheme.primary)),
                      label: Text("Tool title:", style: TextStyle(color: ColorTheme.surfaceTint)),
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
                  child: const Text('Cancel'),
                ),
                TIOFlatButton(
                  onPressed: () => _hideTextInputOverlay(true, setTileState, index),
                  text: 'Submit',
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
    final overlay = Overlay.of(context);

    _newToolTitle.text = "${_pianoBlock.title} - copy";
    _newToolTitle.selection = TextSelection(baseOffset: 0, extentOffset: _newToolTitle.text.length);

    _newProjectTitle.text = getDateAndTimeNow();
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // textfield for new project title
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3.5,
                  child: TextField(
                    controller: _newProjectTitle,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: "",
                      border: OutlineInputBorder(borderSide: BorderSide(color: ColorTheme.primary)),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorTheme.primary)),
                      label: Text("Project title:", style: TextStyle(color: ColorTheme.surfaceTint)),
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
                    decoration: const InputDecoration(
                      hintText: "",
                      border: OutlineInputBorder(borderSide: BorderSide(color: ColorTheme.primary)),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorTheme.primary)),
                      label: Text("Tool title:", style: TextStyle(color: ColorTheme.surfaceTint)),
                    ),
                    style: const TextStyle(color: ColorTheme.primary),
                    onSubmitted: (newText) {
                      _newToolTitle.text = newText;
                      // close
                      _hideTwoTextInputOverlay(true);
                    },
                  ),
                ),

                TextButton(
                  onPressed: () => _hideTwoTextInputOverlay(false),
                  child: const Text('Cancel'),
                ),
                TIOFlatButton(
                  onPressed: () => _hideTwoTextInputOverlay(true),
                  text: 'Submit',
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
        saveToolInProject(context, index, _pianoBlock, widget.isQuickTool, _newToolTitle.text, pianoAlreadyOn: true);
      }
    }
  }

  void _hideTwoTextInputOverlay(bool submitted) {
    _entry?.remove();
    _entry = null;

    if (submitted) {
      _dontStopOnLeave = true;
      saveToolInNewProject(context, _pianoBlock, widget.isQuickTool, _newProjectTitle.text, _newToolTitle.text,
          pianoAlreadyOn: true);
    }
  }
}
