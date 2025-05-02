// Setting page for rhythm segments
// Called when a new rhythm segment is initialized and when an existing one is tapped

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/models/rhythm_group.dart';
import 'package:tiomusic/pages/metronome/beat_button.dart';
import 'package:tiomusic/pages/metronome/metronome_functions.dart';
import 'package:tiomusic/pages/metronome/metronome_utils.dart';
import 'package:tiomusic/pages/metronome/rhythm_segment.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/src/rust/api/modules/metronome.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/pages/metronome/rhythm_generator_setting_list_item.dart';
import 'package:provider/provider.dart';
import 'package:circular_widgets/circular_widgets.dart';
import 'package:tiomusic/util/log.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/util/tutorial_util.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tiomusic/widgets/input/small_number_input_int.dart';
import 'package:tiomusic/widgets/on_off_button.dart';
import 'package:tiomusic/widgets/small_icon_button.dart';
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
  // TODO: extract beat circle widget
  // TODO: remove understores
  // TODO: add tests for helper functions
  static final _logger = createPrefixLogger('SetRhythmParameters');

  late FileSystem _fs;

  int beatCount = 0;
  int polyBeatCount = 0;

  final int _minNumberOfBeats = 1;
  final int _minNumberOfPolyBeats = 0;

  late String _noteKey;
  final List<BeatType> _beats = List.empty(growable: true);
  final List<BeatTypePoly> _polyBeats = List.empty(growable: true);

  bool _isPlaying = false;
  bool _processingButtonClick = false;
  bool _isSimpleModeOn = false;

  late Timer _beatDetection;
  final ActiveBeatsModel _activeBeatsModel = ActiveBeatsModel();

  final Tutorial _tutorial = Tutorial();
  final GlobalKey _keyToggleBeats = GlobalKey();

  @override
  void initState() {
    super.initState();

    _fs = context.read<FileSystem>();

    // we need to use the first metronome, because the first metronome cannot have no beats
    // so if we edit a beat of the second metronome, we just load the sounds of the second metronome into the first metronome
    if (widget.isSecondMetronome) {
      MetronomeUtils.loadMetro2SoundsIntoMetro1(_fs, widget.metronomeBlock);
    }

    _beats.addAll(widget.currentBeats);
    _polyBeats.addAll(widget.currentPolyBeats);
    _noteKey = widget.currentNoteKey;

    beatCount = _beats.length;
    polyBeatCount = _polyBeats.length;

    _beatDetection = Timer.periodic(const Duration(milliseconds: MetronomeParams.beatDetectionDurationMillis), (
      t,
    ) async {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (!_isPlaying) return;

      var event = await metronomePollBeatEventHappened();
      if (event != null) {
        _onBeatHappened(event);
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<ProjectLibrary>().showBeatToggleTip) {
        _createTutorial();
        _tutorial.show(context);
      }
    });
  }

  @override
  void dispose() {
    _stopBeat();
    _beatDetection.cancel();
    super.dispose();
  }

  @override
  void deactivate() {
    _stopBeat();
    _beatDetection.cancel();
    super.deactivate();
  }

  void _toggleSimpleMode() {
    setState(() {
      _isSimpleModeOn = !_isSimpleModeOn;
      if (_isSimpleModeOn) _onPolyBeatCountChange(beatCount);
    });
  }

  // React to beat signal
  void _onBeatHappened(BeatHappenedEvent event) {
    Timer(Duration(milliseconds: event.millisecondsBeforeStart), () {
      setState(() {
        _activeBeatsModel.setBeatOnOff(true, event.barIndex, event.beatIndex, event.isPoly, event.isSecondary);
      });
    });

    Timer(Duration(milliseconds: event.millisecondsBeforeStart + MetronomeParams.flashDurationInMs), () {
      if (!mounted) return;
      setState(() {
        _activeBeatsModel.setBeatOnOff(false, event.barIndex, event.beatIndex, event.isPoly, event.isSecondary);
      });
    });
  }

  void _createTutorial() {
    // add the targets here
    var targets = <CustomTargetFocus>[
      CustomTargetFocus(
        _keyToggleBeats,
        context.l10n.metronomeTutorialEditBeats,
        alignText: ContentAlign.bottom,
        pointingDirection: PointingDirection.up,
      ),
    ];
    _tutorial.create(targets.map((e) => e.targetFocus).toList(), () async {
      context.read<ProjectLibrary>().showBeatToggleTip = false;
      await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
    }, context);
  }

  int getNextPolyBeatCount(int beatCount, int polyBeatCount) {
    var next = polyBeatCount + 1;
    while (beatCount > polyBeatCount ? beatCount % next != 0 : next % beatCount != 0) {
      next++;
    }
    return next;
  }

  int getPrevPolyBeatCount(int beatCount, int polyBeatCount) {
    var prev = polyBeatCount - 1;
    if (prev == 0) return 0;
    while (beatCount >= polyBeatCount ? beatCount % prev != 0 : prev % beatCount != 0) {
      prev--;
    }
    return prev;
  }

  int getIncrementStepForPolyBeat(int beatCount, int polyBeatCount) =>
      getNextPolyBeatCount(beatCount, polyBeatCount) - polyBeatCount;

  int getDecrementStepForPolyBeat(int beatCount, int polyBeatCount) =>
      polyBeatCount - getPrevPolyBeatCount(beatCount, polyBeatCount);

  void _onBeatCountChange(int newBeatCount) {
    setState(() {
      beatCount = newBeatCount;
      if (_isSimpleModeOn) polyBeatCount = newBeatCount;

      if (newBeatCount > _beats.length) {
        _beats.addAll(List.filled(newBeatCount - _beats.length, BeatType.Unaccented));
      } else if (newBeatCount < _beats.length) {
        _beats.removeRange(newBeatCount, _beats.length);
      }

      refreshRhythm();
    });
  }

  void _onPolyBeatCountChange(int newPolyBeatCount) {
    setState(() {
      polyBeatCount = newPolyBeatCount;

      if (newPolyBeatCount > _polyBeats.length) {
        _polyBeats.addAll(List.filled(newPolyBeatCount - _polyBeats.length, BeatTypePoly.Unaccented));
      } else if (newPolyBeatCount < _polyBeats.length) {
        _polyBeats.removeRange(newPolyBeatCount, _polyBeats.length);
      }

      refreshRhythm();
    });
  }

  void _selectIcon(String chosenNoteKey) {
    setState(() {
      _noteKey = chosenNoteKey;
      refreshRhythm();
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
      child: RhythmGeneratorSettingListItem(noteKey: noteKey, onTap: () => _selectIcon(noteKey), hasBorder: isSelected),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ParentSettingPage(
      title: l10n.metronomeSetBpm,
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
                Positioned(
                  top: 0,
                  right: 0,
                  child: SmallIconButton(
                    icon: Icon(
                      _isSimpleModeOn ? Icons.music_note : Icons.music_note_outlined,
                      color: ColorTheme.tertiary,
                    ),
                    onPressed: _toggleSimpleMode,
                  ),
                ),
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
                SmallNumberInputInt(
                  value: beatCount,
                  onChange: _onBeatCountChange,
                  min: _minNumberOfBeats,
                  max: MetronomeParams.maxBeatCount,
                  step: 1,
                  label: l10n.metronomeNumberOfBeats,
                  buttonRadius: MetronomeParams.popupButtonRadius,
                  textFontSize: MetronomeParams.popupTextFontSize,
                ),
                SmallNumberInputInt(
                  value: polyBeatCount,
                  onChange: _onPolyBeatCountChange,
                  min: _minNumberOfPolyBeats,
                  max: MetronomeParams.maxBeatCount,
                  decrementStep: _isSimpleModeOn ? getDecrementStepForPolyBeat(beatCount, polyBeatCount) : 1,
                  incrementStep: _isSimpleModeOn ? getIncrementStepForPolyBeat(beatCount, polyBeatCount) : 1,
                  label: l10n.metronomeNumberOfPolyBeats,
                  buttonRadius: MetronomeParams.popupButtonRadius,
                  textFontSize: MetronomeParams.popupTextFontSize,
                ),
              ],
            ),

            // Show all note values
            if (!_isSimpleModeOn) _getNoteTable(),
          ],
        ),
      ),
    );
  }

  Future<void> _onConfirm() async {
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

    MetronomeUtils.loadSounds(_fs, widget.metronomeBlock);

    await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  void _reset() {
    _selectIcon(MetronomeParams.defaultNoteKey);
    beatCount = MetronomeParams.defaultBeats.length;
    polyBeatCount = MetronomeParams.defaultPolyBeats.length;

    for (var i = 0; i < _beats.length; i++) {
      _beats[i] = MetronomeParams.defaultBeats[i];
    }

    refreshRhythm();
  }

  void _onCancel() {
    _stopBeat();
    MetronomeUtils.loadSounds(_fs, widget.metronomeBlock);
    Navigator.pop(context);
  }

  Widget _beatCircle(
    double centerWidgetRadius,
    double buttonSize,
    Color beatButtonColor, {
    List<BeatType>? beats,
    List<BeatTypePoly>? polyBeats,
    bool noInnerBorder = true,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ColorTheme.primary80)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: CircularWidgets(
          itemBuilder: (context, index) {
            return ListenableBuilder(
              listenable: _activeBeatsModel,
              builder: (context, child) {
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
                      refreshRhythm();
                    });
                  },
                );
              },
            );
          },
          itemsLength: beats != null ? beats.length : polyBeats!.length,
          config: CircularWidgetConfig(itemRadius: 16, centerWidgetRadius: centerWidgetRadius),
          centerWidgetBuilder: (context) {
            return noInnerBorder
                ? Container()
                : DecoratedBox(
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ColorTheme.primary80)),
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
    refreshRhythm();

    await MetronomeFunctions.stop();
    final success = await MetronomeFunctions.start();
    if (!success) {
      _logger.e('Unable to start metronome.');
      return;
    }
    _isPlaying = true;
  }

  Future<void> _stopBeat() async {
    await metronomeStop();
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

  void refreshRhythm() {
    final bars = getRhythmAsMetroBar([RhythmGroup('', _beats, _polyBeats, _noteKey)]);
    metronomeSetRhythm(bars: bars, bars2: []);
  }
}
