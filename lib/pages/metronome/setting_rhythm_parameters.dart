// Setting page for rhythm segments
// Called when a new rhythm segment is initialized and when an existing one is tapped

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/models/rhythm_group.dart';
import 'package:tiomusic/pages/metronome/beat_button.dart';
import 'package:tiomusic/pages/metronome/metronome_functions.dart';
import 'package:tiomusic/pages/metronome/metronome_utils.dart';
import 'package:tiomusic/pages/metronome/rhythm_segment.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/pages/metronome/rhythm_generator_setting_list_item.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/rust_api/ffi.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:circular_widgets/circular_widgets.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/util/walkthrough_util.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tiomusic/widgets/on_off_button.dart';
import 'package:tiomusic/widgets/small_num_input.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class SetRhythmParameters extends StatefulWidget {
  final int? barIndex;
  final String currentNoteKey;
  final List<BeatType> currentBeats;
  final List<BeatTypePoly> currentPolyBeats;
  final bool isAddingNewBar;
  final List<RhythmGroup> rhythmGroups;
  final bool isSecondMetronome;
  final MetronomeBlock metronomeBlock;

  const SetRhythmParameters({
    super.key,
    this.barIndex,
    required this.currentNoteKey,
    required this.currentBeats,
    required this.currentPolyBeats,
    required this.isAddingNewBar,
    required this.rhythmGroups,
    required this.isSecondMetronome,
    required this.metronomeBlock,
  });

  @override
  State<SetRhythmParameters> createState() => _SetRhythmParametersState();
}

class _SetRhythmParametersState extends State<SetRhythmParameters> {
  late SmallNumInput _numBeatsInput;
  late SmallNumInput _numPolyBeatsInput;

  final int _minNumberOfBeats = 1;
  final int _minNumberOfPolyBeats = 0;

  late String _noteKey;
  final List<BeatType> _beats = List.empty(growable: true);
  final List<BeatTypePoly> _polyBeats = List.empty(growable: true);

  bool _isPlaying = false;
  bool _processingButtonClick = false;

  late Timer _beatDetection;
  final ActiveBeatsModel _activeBeatsModel = ActiveBeatsModel();

  final Walkthrough _walkthrough = Walkthrough();
  final GlobalKey _keyToggleBeats = GlobalKey();

  @override
  void initState() {
    super.initState();

    // we need to use the first metronome, because the first metronome cannot have no beats
    // so if we edit a beat of the second metronome, we just load the sounds of the second metronome into the first metronome
    if (widget.isSecondMetronome) {
      MetronomeUtils.loadMetro2SoundsIntoMetro1(widget.metronomeBlock);
    }

    for (var beat in widget.currentBeats) {
      _beats.add(beat);
    }
    for (var beat in widget.currentPolyBeats) {
      _polyBeats.add(beat);
    }

    _noteKey = widget.currentNoteKey;

    _numBeatsInput = SmallNumInput(
      maxValue: MetronomeParams.maxNumBeats,
      minValue: _minNumberOfBeats,
      defaultValue: widget.currentBeats.length,
      countingValue: 1,
      displayText: TextEditingController(),
      descriptionText: "Number of Beats",
      buttonRadius: MetronomeParams.popupButtonRadius,
      textFontSize: MetronomeParams.popupTextFontSize,
    );

    _numPolyBeatsInput = SmallNumInput(
      maxValue: MetronomeParams.maxNumBeats,
      minValue: _minNumberOfPolyBeats,
      defaultValue: widget.currentPolyBeats.length,
      countingValue: 1,
      displayText: TextEditingController(),
      descriptionText: "Number of Poly Beats",
      buttonRadius: MetronomeParams.popupButtonRadius,
      textFontSize: MetronomeParams.popupTextFontSize,
    );

    // Start beat detection timer
    _beatDetection =
        Timer.periodic(const Duration(milliseconds: MetronomeParams.beatDetectionDurationMillis), (Timer t) async {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (!_isPlaying) return;

      var event = await rustApi.metronomePollBeatEventHappened();
      if (event != null) {
        _onBeatHappened(event);
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _numBeatsInput.displayText.addListener(_onNumBeatsChanged);
      _numPolyBeatsInput.displayText.addListener(_onNumPolyBeatsChanged);

      if (context.read<ProjectLibrary>().showBeatToggleTip) {
        _createWalkthrough();
        _walkthrough.show(context);
      }
    });
  }

  @override
  void deactivate() {
    _stopBeat();
    _beatDetection.cancel();
    super.deactivate();
  }

  // React to beat signal
  void _onBeatHappened(BeatHappenedEvent event) {
    Timer(Duration(milliseconds: event.millisecondsBeforeStart), () {
      setState(() {
        _activeBeatsModel.setBeatOnOff(true, event.barIndex, event.beatIndex, event.isPoly, event.isSecondary);
      });
    });

    Timer(Duration(milliseconds: event.millisecondsBeforeStart + MetronomeParams.blackScreenDurationMs), () {
      if (!mounted) return;
      setState(() {
        _activeBeatsModel.setBeatOnOff(false, event.barIndex, event.beatIndex, event.isPoly, event.isSecondary);
      });
    });
  }

  void _createWalkthrough() {
    // add the targets here
    var targets = <CustomTargetFocus>[
      CustomTargetFocus(
        _keyToggleBeats,
        "Tap a beat to switch between accented, unaccented and muted",
        alignText: ContentAlign.bottom,
        pointingDirection: PointingDirection.up,
      ),
    ];
    _walkthrough.create(
      targets.map((e) => e.targetFocus).toList(),
      () {
        context.read<ProjectLibrary>().showBeatToggleTip = false;
        FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
      },
      context,
    );
  }

  // Handle beat changes
  void _onNumBeatsChanged() {
    setState(() {
      if (_numBeatsInput.displayText.value.text != '') {
        int newNumberOfBeats = int.parse(_numBeatsInput.displayText.value.text);
        if (newNumberOfBeats >= _minNumberOfBeats && newNumberOfBeats <= MetronomeParams.maxNumBeats) {
          if (newNumberOfBeats > _beats.length) {
            _beats.addAll(List.filled(newNumberOfBeats - _beats.length, BeatType.Unaccented));
          } else if (newNumberOfBeats < _beats.length) {
            _beats.removeRange(newNumberOfBeats, _beats.length);
          }

          var bars = getRhythmAsMetroBar([RhythmGroup("", _beats, _polyBeats, _noteKey)]);
          rustApi.metronomeSetRhythm(bars: bars, bars2: []);
        }
      }
    });
  }

  void _onNumPolyBeatsChanged() {
    setState(() {
      if (_numPolyBeatsInput.displayText.value.text != '') {
        int newNumberOfBeats = int.parse(_numPolyBeatsInput.displayText.value.text);
        if (newNumberOfBeats >= _minNumberOfPolyBeats && newNumberOfBeats <= MetronomeParams.maxNumBeats) {
          if (newNumberOfBeats > _polyBeats.length) {
            _polyBeats.addAll(List.filled(newNumberOfBeats - _polyBeats.length, BeatTypePoly.Unaccented));
          } else if (newNumberOfBeats < _polyBeats.length) {
            _polyBeats.removeRange(newNumberOfBeats, _polyBeats.length);
          }

          var bars = getRhythmAsMetroBar([RhythmGroup("", _beats, _polyBeats, _noteKey)]);
          rustApi.metronomeSetRhythm(bars: bars, bars2: []);
        }
      }
    });
  }

  // Select the currently chosen icon
  void _selectIcon(String chosenNoteKey) {
    setState(() {
      _noteKey = chosenNoteKey;
      var bars = getRhythmAsMetroBar([RhythmGroup("", _beats, _polyBeats, _noteKey)]);
      rustApi.metronomeSetRhythm(bars: bars, bars2: []);
    });
  }

  Widget _getNoteTable() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Table(
        border: const TableBorder(horizontalInside: BorderSide(color: ColorTheme.primary80)),
        children: <TableRow>[
          TableRow(
            children: <Widget>[
              _getNoteButton(NoteValues.whole),
              const SizedBox(),
              const SizedBox(),
              const SizedBox(),
              const SizedBox(),
            ],
          ),
          TableRow(
            children: <Widget>[
              _getNoteButton(NoteValues.half),
              _getNoteButton(NoteValues.halfDotted),
              _getNoteButton(NoteValues.tuplet3Half),
              const SizedBox(),
              const SizedBox(),
            ],
          ),
          TableRow(
            children: <Widget>[
              _getNoteButton(NoteValues.quarter),
              _getNoteButton(NoteValues.quarterDotted),
              _getNoteButton(NoteValues.tuplet3Quarter),
              const SizedBox(),
              const SizedBox(),
            ],
          ),
          TableRow(
            children: <Widget>[
              _getNoteButton(NoteValues.eighth),
              _getNoteButton(NoteValues.eighthDotted),
              _getNoteButton(NoteValues.tuplet3Eighth),
              const SizedBox(),
              const SizedBox(),
            ],
          ),
          TableRow(
            children: <Widget>[
              _getNoteButton(NoteValues.sixteenth),
              _getNoteButton(NoteValues.sixteenthDotted),
              _getNoteButton(NoteValues.tuplet5Sixteenth),
              _getNoteButton(NoteValues.tuplet6Sixteenth),
              _getNoteButton(NoteValues.tuplet7Sixteenth),
            ],
          ),
          TableRow(
            children: <Widget>[
              _getNoteButton(NoteValues.thirtySecond),
              _getNoteButton(NoteValues.thirtySecondDotted),
              const SizedBox(),
              const SizedBox(),
              const SizedBox(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getNoteButton(String noteKey) {
    bool isSelected = false;
    if (_noteKey == noteKey) {
      isSelected = true;
    }
    return Padding(
      padding: const EdgeInsets.all(8),
      child: RhythmGeneratorSettingListItem(
        noteKey: noteKey,
        onTap: () => _selectIcon(noteKey),
        hasBorder: isSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: "Set Beat",
      confirm: _onConfirm,
      reset: _reset,
      cancel: _onCancel,
      mustBeScrollable: true,
      customWidget: Padding(
        padding: const EdgeInsets.all(TIOMusicParams.edgeInset),
        child: Column(
          children: [
            // planets
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                _beatCircle(
                  MediaQuery.of(context).size.width / 3,
                  TIOMusicParams.beatButtonSizeBig,
                  beats: _beats,
                  ColorTheme.surfaceTint,
                ),
                _beatCircle(
                  MediaQuery.of(context).size.width / 5,
                  TIOMusicParams.beatButtonSizeSmall,
                  polyBeats: _polyBeats,
                  ColorTheme.primary60,
                  noInnerBorder: false,
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Set number of beats
                _numBeatsInput,

                // Set number of poly beats
                _numPolyBeatsInput,
              ],
            ),

            // Show all note values
            _getNoteTable(),
          ],
        ),
      ),
    );
  }

  void _onConfirm() {
    _stopBeat();

    if (widget.isAddingNewBar) {
      widget.rhythmGroups.add(RhythmGroup(MetronomeParams.getNewKeyID(), _beats, _polyBeats, _noteKey));
    } else if (widget.barIndex != null) {
      widget.rhythmGroups[widget.barIndex!].beats.clear();
      for (var beat in _beats) {
        widget.rhythmGroups[widget.barIndex!].beats.add(beat);
      }
      widget.rhythmGroups[widget.barIndex!].polyBeats.clear();
      for (var beat in _polyBeats) {
        widget.rhythmGroups[widget.barIndex!].polyBeats.add(beat);
      }
      widget.rhythmGroups[widget.barIndex!].noteKey = _noteKey;
      widget.rhythmGroups[widget.barIndex!].beatLen = NoteHandler.getBeatLength(_noteKey);
    }

    MetronomeUtils.loadSounds(widget.metronomeBlock);

    FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    Navigator.of(context).pop(true);
  }

  void _reset() {
    _selectIcon(MetronomeParams.defaultNoteKey);
    _numBeatsInput.displayText.value =
        _numBeatsInput.displayText.value.copyWith(text: MetronomeParams.defaultBeats.length.toString());
    _numPolyBeatsInput.displayText.value =
        _numPolyBeatsInput.displayText.value.copyWith(text: MetronomeParams.defaultPolyBeats.length.toString());

    for (var i = 0; i < _beats.length; i++) {
      _beats[i] = MetronomeParams.defaultBeats[i];
    }

    var bars = getRhythmAsMetroBar([RhythmGroup("", _beats, _polyBeats, _noteKey)]);
    rustApi.metronomeSetRhythm(bars: bars, bars2: []);
  }

  void _onCancel() {
    _stopBeat();
    MetronomeUtils.loadSounds(widget.metronomeBlock);
    Navigator.pop(context);
  }

  Widget _beatCircle(double centerWidgetRadius, double buttonSize, Color beatButtonColor,
      {List<BeatType>? beats, List<BeatTypePoly>? polyBeats, bool noInnerBorder = true}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ColorTheme.primary80),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: CircularWidgets(
          itemBuilder: (context, index) {
            return ListenableBuilder(
              listenable: _activeBeatsModel,
              builder: (BuildContext context, Widget? child) {
                var highlight = false;
                if (beats != null && index == _activeBeatsModel.mainBeat) {
                  highlight = _activeBeatsModel.mainBeatOn;
                } else if (polyBeats != null && index == _activeBeatsModel.polyBeat) {
                  highlight = _activeBeatsModel.polyBeatOn;
                }

                return BeatButton(
                  key: beats != null && index == 0 ? _keyToggleBeats : null,
                  color: beatButtonColor,
                  beatTypes: beats != null ? getBeatButtonsFromBeats(beats) : getBeatButtonsFromBeatsPoly(polyBeats!),
                  beatTypeIndex: index,
                  buttonSize: buttonSize,
                  beatHighlighted: highlight,
                  onTap: () {
                    setState(() {
                      if (beats != null) {
                        beats[index] = _getBeatTypeOnTap(beats[index]);
                      } else {
                        polyBeats![index] = _getBeatTypePolyOnTap(polyBeats[index]);
                      }

                      var bars = getRhythmAsMetroBar([RhythmGroup("", _beats, _polyBeats, _noteKey)]);
                      rustApi.metronomeSetRhythm(bars: bars, bars2: []);
                    });
                  },
                );
              },
            );
          },
          itemsLength: beats != null ? beats.length : polyBeats!.length,
          config: CircularWidgetConfig(
            itemRadius: 16,
            centerWidgetRadius: centerWidgetRadius,
          ),
          centerWidgetBuilder: (context) {
            return noInnerBorder
                ? Container()
                : Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: ColorTheme.primary80),
                    ),
                    child: OnOffButton(
                      isActive: _isPlaying,
                      onTap: _startStopBeatPlayback,
                      iconOff: Icons.play_arrow,
                      iconOn: TIOMusicParams.pauseIcon,
                      buttonSize: TIOMusicParams.sizeBigButtons,
                    ),
                  );
          },
        ),
      ),
    );
  }

  void _startStopBeatPlayback() async {
    if (_processingButtonClick) return;
    setState(() => _processingButtonClick = true);

    if (_isPlaying) {
      await _stopBeat();
    } else {
      await _startBeat();
    }

    await Future.delayed(const Duration(milliseconds: TIOMusicParams.millisecondsPlayPauseDebounce));
    setState(() => _processingButtonClick = false);
  }

  Future<void> _startBeat() async {
    // set beat in rust
    var bars = getRhythmAsMetroBar([RhythmGroup("", _beats, _polyBeats, _noteKey)]);
    rustApi.metronomeSetRhythm(bars: bars, bars2: []);

    await MetronomeFunctions.stop();
    final success = await MetronomeFunctions.start();
    if (!success) {
      debugPrint('failed to start metronome');
      return;
    }
    _isPlaying = true;
  }

  Future<void> _stopBeat() async {
    await rustApi.metronomeStop();
    _isPlaying = false;
  }

  BeatType _getBeatTypeOnTap(BeatType currentType) {
    if (currentType == BeatType.Accented) {
      return BeatType.Muted;
    } else if (currentType == BeatType.Unaccented) {
      return BeatType.Accented;
    } else {
      return BeatType.Unaccented;
    }
  }

  BeatTypePoly _getBeatTypePolyOnTap(BeatTypePoly currentType) {
    if (currentType == BeatTypePoly.Accented) {
      return BeatTypePoly.Muted;
    } else if (currentType == BeatTypePoly.Unaccented) {
      return BeatTypePoly.Accented;
    } else {
      return BeatTypePoly.Unaccented;
    }
  }
}
