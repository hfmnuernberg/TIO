// Metronome User Interface

import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/main.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/models/rhythm_group.dart';
import 'package:tiomusic/pages/metronome/metronome_functions.dart';
import 'package:tiomusic/pages/metronome/metronome_utils.dart';
import 'package:tiomusic/pages/metronome/rhythm_segment.dart';
import 'package:tiomusic/pages/metronome/setting_bpm.dart';
import 'package:tiomusic/pages/metronome/setting_metronome_sound.dart';
import 'package:tiomusic/pages/metronome/setting_random_mute.dart';
import 'package:tiomusic/pages/metronome/setting_rhythm_parameters.dart';
import 'package:tiomusic/pages/parent_tool/parent_island_view.dart';
import 'package:tiomusic/pages/parent_tool/parent_tool.dart';
import 'package:tiomusic/pages/parent_tool/setting_volume_page.dart';
import 'package:tiomusic/pages/parent_tool/settings_tile.dart';
import 'package:tiomusic/pages/parent_tool/volume.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/src/rust/api/modules/metronome.dart';
import 'package:tiomusic/util/app_snackbar.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/util/walkthrough_util.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tiomusic/widgets/on_off_button.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:volume_controller/volume_controller.dart';

int calcMsUntilNextFlashOn({
  required int timestamp,
  required int eventTimestamp,
  required int eventDelayInMs,
  required int avgRenderTimeInMs,
}) => max(0, eventDelayInMs + eventTimestamp - timestamp - avgRenderTimeInMs);

int calcMsUntilNextFlashOff({required int msUntilNextFlashOn}) => msUntilNextFlashOn + MetronomeParams.flashDurationInMs;

class Metronome extends StatefulWidget {
  final bool isQuickTool;

  const Metronome({super.key, required this.isQuickTool});

  @override
  State<Metronome> createState() => _MetronomeState();
}

class _MetronomeState extends State<Metronome> with RouteAware {
  int _lastStateChange = DateTime.now().millisecondsSinceEpoch;
  final List<int> _lastRenderTimes = List.empty(growable: true);
  int _avgRenderTime = 0;
  bool _isStarted = false;
  bool _sound = true;
  bool _blink = MetronomeParams.defaultVisualMetronome;
  bool _isFlashOn = false;
  VolumeLevel _deviceVolumeLevel = VolumeLevel.normal;
  final List<RhythmSegment> _rhythmSegmentList = List.empty(growable: true);
  final List<RhythmSegment> _rhythmSegmentList2 = List.empty(growable: true);

  final ActiveBeatsModel _activeBeatsModel = ActiveBeatsModel();

  late Timer _beatDetection;
  late MetronomeBlock _metronomeBlock;

  bool _processingButtonClick = false;

  Color _listTileMaskColor = Colors.transparent;

  final List<MenuItemButton> _menuItems = List.empty(growable: true);

  final Walkthrough _walkthrough = Walkthrough();
  final GlobalKey _keyStartStop = GlobalKey();
  final GlobalKey _keySettings = GlobalKey();
  final GlobalKey _keyGroups = GlobalKey();
  final GlobalKey _keyAddSecondMetro = GlobalKey();

  StreamSubscription<AudioInterruptionEvent>? audioInterruptionListener;

  @override
  void initState() {
    super.initState();

    VolumeController.instance.addListener(handleVolumeChange);

    _menuItems.add(
      MenuItemButton(
        onPressed: _clearAllRhythms,
        child: const Text('Clear all rhythms', style: TextStyle(color: ColorTheme.primary)),
      ),
    );

    _metronomeBlock = Provider.of<ProjectBlock>(context, listen: false) as MetronomeBlock;
    _metronomeBlock.timeLastModified = getCurrentDateTime();

    // only allow portrait mode for this tool
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    metronomeSetVolume(volume: _metronomeBlock.volume);
    metronomeSetRhythm(
      bars: getRhythmAsMetroBar(_metronomeBlock.rhythmGroups),
      bars2: getRhythmAsMetroBar(_metronomeBlock.rhythmGroups2),
    );
    metronomeSetBpm(bpm: _metronomeBlock.bpm.toDouble());
    metronomeSetBeatMuteChance(muteChance: _metronomeBlock.randomMute.toDouble() / 100.0);

    _muteMetronome(!_sound);
    MetronomeUtils.loadSounds(_metronomeBlock);

    // Build rhythm list
    _clearAndRebuildRhythmSegments(false);
    _clearAndRebuildRhythmSegments(true);

    // Start beat detection timer
    _beatDetection = Timer.periodic(const Duration(milliseconds: MetronomeParams.beatDetectionDurationMillis), (
      t,
    ) async {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (!_isStarted) return;

      var event = await metronomePollBeatEventHappened();
      if (event != null) {
        _onBeatHappened(event);
        if (!mounted) return;
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<ProjectLibrary>().showMetronomeTutorial &&
          !context.read<ProjectLibrary>().showToolTutorial &&
          !context.read<ProjectLibrary>().showQuickToolTutorial &&
          !context.read<ProjectLibrary>().showIslandTutorial) {
        _createWalkthrough();
        _walkthrough.show(context);
      }
    });
  }

  void handleVolumeChange(double newVolume) {
    setState(() {
      _deviceVolumeLevel = getVolumeLevel(newVolume);
    });
  }

  void _createWalkthrough() {
    // add the targets here
    var targets = <CustomTargetFocus>[
      CustomTargetFocus(
        _keyStartStop,
        'Tap here to start and stop the metronome',
        alignText: ContentAlign.top,
        pointingDirection: PointingDirection.down,
      ),
      CustomTargetFocus(
        _keySettings,
        'Tap here to adjust the metronome settings',
        alignText: ContentAlign.top,
        pointingDirection: PointingDirection.down,
        buttonsPosition: ButtonsPosition.top,
        shape: ShapeLightFocus.RRect,
      ),
      CustomTargetFocus(
        _keyGroups,
        'Hold and drag sideways to relocate,\nswipe upwards to delete\nor tap to edit',
        alignText: ContentAlign.bottom,
        pointingDirection: PointingDirection.up,
        shape: ShapeLightFocus.RRect,
        pointerPosition: PointerPosition.left,
      ),
      CustomTargetFocus(
        _keyAddSecondMetro,
        'Tap here to add a second metronome',
        alignText: ContentAlign.left,
        pointingDirection: PointingDirection.right,
      ),
    ];
    _walkthrough.create(targets.map((e) => e.targetFocus).toList(), () {
      context.read<ProjectLibrary>().showMetronomeTutorial = false;
      FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    }, context);
  }

  @override
  void deactivate() {
    _stopMetronome();
    _beatDetection.cancel();
    super.deactivate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute? route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    VolumeController.instance.removeListener();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    VolumeController.instance.addListener(handleVolumeChange);
  }

  void _addRhythmSegment(bool isSecond) async {
    await _stopMetronome();

    int newIndex = isSecond ? _metronomeBlock.rhythmGroups2.length : _metronomeBlock.rhythmGroups.length;

    if (mounted) {
      openSettingPage(
        SetRhythmParameters(
          currentNoteKey: MetronomeParams.defaultNoteKey,
          currentBeats: MetronomeParams.defaultBeats,
          currentPolyBeats: MetronomeParams.defaultPolyBeats,
          isAddingNewBar: true,
          rhythmGroups: isSecond ? _metronomeBlock.rhythmGroups2 : _metronomeBlock.rhythmGroups,
          isSecondMetronome: isSecond,
          metronomeBlock: _metronomeBlock,
        ),
        context,
        _metronomeBlock,
        callbackOnReturn: (addingConfirmed) {
          setState(() {
            if (addingConfirmed != null && addingConfirmed) {
              var newRhythmSegment = RhythmSegment(
                activeBeatsNotifier: _activeBeatsModel,
                barIdx: newIndex,
                metronomeBlock: _metronomeBlock,
                isSecondary: isSecond,
                editFunction: () => _editRhythmSegment(newIndex, isSecond),
              );

              isSecond ? _rhythmSegmentList2.add(newRhythmSegment) : _rhythmSegmentList.add(newRhythmSegment);
            }

            metronomeSetRhythm(
              bars: getRhythmAsMetroBar(_metronomeBlock.rhythmGroups),
              bars2: getRhythmAsMetroBar(_metronomeBlock.rhythmGroups2),
            );
          });
        },
      );
    }
  }

  void _editRhythmSegment(int idx, bool isSecond) async {
    await _stopMetronome();

    var rhythmGroups = isSecond ? _metronomeBlock.rhythmGroups2 : _metronomeBlock.rhythmGroups;

    if (mounted) {
      openSettingPage(
        SetRhythmParameters(
          barIndex: idx,
          currentNoteKey: rhythmGroups[idx].noteKey,
          currentBeats: rhythmGroups[idx].beats,
          currentPolyBeats: rhythmGroups[idx].polyBeats,
          isAddingNewBar: false,
          rhythmGroups: rhythmGroups,
          isSecondMetronome: isSecond,
          metronomeBlock: _metronomeBlock,
        ),
        context,
        _metronomeBlock,
      ).then((value) {
        var newRhythmSegment = RhythmSegment(
          activeBeatsNotifier: _activeBeatsModel,
          metronomeBlock: _metronomeBlock,
          barIdx: idx,
          isSecondary: isSecond,
          editFunction: () => _editRhythmSegment(idx, isSecond),
        );

        isSecond ? _rhythmSegmentList2[idx] = newRhythmSegment : _rhythmSegmentList[idx] = newRhythmSegment;

        metronomeSetRhythm(
          bars: getRhythmAsMetroBar(_metronomeBlock.rhythmGroups),
          bars2: getRhythmAsMetroBar(_metronomeBlock.rhythmGroups2),
        );
        setState(() {});
      });
    }
  }

  void _deleteRhythmSegment(int index, bool isSecond) async {
    _stopMetronome().then((value) {
      isSecond ? _metronomeBlock.rhythmGroups2.removeAt(index) : _metronomeBlock.rhythmGroups.removeAt(index);

      _clearAndRebuildRhythmSegments(isSecond);

      metronomeSetRhythm(
        bars: getRhythmAsMetroBar(_metronomeBlock.rhythmGroups),
        bars2: getRhythmAsMetroBar(_metronomeBlock.rhythmGroups2),
      );
      if (mounted) {
        FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
        setState(() {});
      }
    });
  }

  void _reorderRythmSegments(int oldIndex, int newIndex, bool isSecond) {
    _stopMetronome();

    _metronomeBlock.changeRhythmOrder(
      oldIndex,
      newIndex,
      isSecond ? _metronomeBlock.rhythmGroups2 : _metronomeBlock.rhythmGroups,
    );

    _clearAndRebuildRhythmSegments(isSecond);

    metronomeSetRhythm(
      bars: getRhythmAsMetroBar(_metronomeBlock.rhythmGroups),
      bars2: getRhythmAsMetroBar(_metronomeBlock.rhythmGroups2),
    );
    FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    setState(() {});
  }

  void _clearAllRhythms() async {
    await _stopMetronome();

    _rhythmSegmentList.clear();
    _rhythmSegmentList2.clear();
    _metronomeBlock.rhythmGroups.clear();
    _metronomeBlock.rhythmGroups2.clear();

    _metronomeBlock.rhythmGroups.add(
      RhythmGroup(
        MetronomeParams.getNewKeyID(),
        MetronomeParams.defaultBeats,
        MetronomeParams.defaultPolyBeats,
        MetronomeParams.defaultNoteKey,
      ),
    );
    _rhythmSegmentList.add(
      RhythmSegment(
        activeBeatsNotifier: _activeBeatsModel,
        barIdx: 0,
        metronomeBlock: _metronomeBlock,
        isSecondary: false,
        editFunction: () => _editRhythmSegment(0, false),
      ),
    );

    metronomeSetRhythm(
      bars: getRhythmAsMetroBar(_metronomeBlock.rhythmGroups),
      bars2: getRhythmAsMetroBar(_metronomeBlock.rhythmGroups2),
    );
    if (mounted) {
      FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
      setState(() {});
    }
  }

  void _clearAndRebuildRhythmSegments(bool isSecond) {
    isSecond ? _rhythmSegmentList2.clear() : _rhythmSegmentList.clear();
    for (int i = 0; i < (isSecond ? _metronomeBlock.rhythmGroups2.length : _metronomeBlock.rhythmGroups.length); i++) {
      var newRhythmSegment = RhythmSegment(
        activeBeatsNotifier: _activeBeatsModel,
        barIdx: i,
        metronomeBlock: _metronomeBlock,
        isSecondary: isSecond,
        editFunction: () => _editRhythmSegment(i, isSecond),
      );
      isSecond ? _rhythmSegmentList2.add(newRhythmSegment) : _rhythmSegmentList.add(newRhythmSegment);
    }
    setState(() {});
  }

  // Additional widget to remove the segment background while dragging it
  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 6, animValue)!;
        return Material(elevation: elevation, color: Colors.transparent, shadowColor: Colors.transparent, child: child);
      },
      child: child,
    );
  }

  // Start/Stop Metronome
  void _onToggleButtonClicked() async {
    if (_processingButtonClick) return;
    setState(() => _processingButtonClick = true);

    if (_isStarted) {
      await _stopMetronome();
    } else {
      await _startMetronome();
    }

    await Future.delayed(const Duration(milliseconds: TIOMusicParams.millisecondsPlayPauseDebounce));
    setState(() => _processingButtonClick = false);
  }

  Future<void> _startMetronome() async {
    if (_sound && [VolumeLevel.muted, VolumeLevel.low].contains(_deviceVolumeLevel)) {
      showSnackbar(context: context, message: getVolumeInfoText(_deviceVolumeLevel))();
    }

    audioInterruptionListener = (await AudioSession.instance).interruptionEventStream.listen((event) {
      if (event.type == AudioInterruptionType.unknown) _stopMetronome();
    });

    await MetronomeFunctions.stop();
    final success = await MetronomeFunctions.start();
    if (!success) {
      debugPrint('failed to start metronome');
      return;
    }
    _isStarted = true;
  }

  Future<void> _stopMetronome() async {
    await audioInterruptionListener?.cancel();
    bool success = await metronomeStop();
    if (!success) debugPrint('failed to stop metronome');
    _isStarted = false;
  }

  // Turn off metronome sound
  void _muteMetronome(bool isMute) {
    metronomeSetMuted(muted: isMute);
  }

  // React to beat signal
  void _onBeatHappened(BeatHappenedEvent event) {
    if (!event.isRandomMute) {
      final timeStamp = DateTime.now().millisecondsSinceEpoch;
      final msUntilNextFlashOn = calcMsUntilNextFlashOn(
        timestamp: timeStamp,
        eventTimestamp: event.timestamp,
        eventDelayInMs: event.millisecondsBeforeStart,
        avgRenderTimeInMs: _avgRenderTime,
      );
      final msUntilNextFlashOff = calcMsUntilNextFlashOff(msUntilNextFlashOn: msUntilNextFlashOn);

      Timer(Duration(milliseconds: msUntilNextFlashOn), () {
        if (!mounted) return;
        _lastStateChange = DateTime.now().millisecondsSinceEpoch;
        setState(() {
          _isFlashOn = true;
          _activeBeatsModel.setBeatOnOff(true, event.barIndex, event.beatIndex, event.isPoly, event.isSecondary);
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final renderTime = DateTime.now().millisecondsSinceEpoch - _lastStateChange;
          _lastRenderTimes.add(renderTime);
          if (_lastRenderTimes.length > 5) _lastRenderTimes.removeAt(0);
          _avgRenderTime = _lastRenderTimes.reduce((a, b) => a + b) ~/ _lastRenderTimes.length;
        });
      });

      Timer(Duration(milliseconds: msUntilNextFlashOff), () {
        if (!mounted) return;
        setState(() {
          _isFlashOn = false;
          _activeBeatsModel.setBeatOnOff(false, event.barIndex, event.beatIndex, event.isPoly, event.isSecondary);
        });
      });
    }
  }

  Widget _rhythmGroup(int index, bool isSecond) {
    return DecoratedBox(
      key: index == 0 && !isSecond ? _keyGroups : null,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: _listTileMaskColor),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child:
        // Reordering handle with icon
        ReorderableDelayedDragStartListener(
          index: index,
          enabled: (isSecond ? _metronomeBlock.rhythmGroups2.length : _metronomeBlock.rhythmGroups.length) > 1,
          child: GestureDetector(
            onTap: () {
              _editRhythmSegment(index, isSecond);
            },
            child: isSecond ? _rhythmSegmentList2[index] : _rhythmSegmentList[index],
          ),
        ),
      ),
    );
  }

  Widget _rhythmRow({bool isSecondMetronome = false}) {
    return Column(
      children: [
        // rhythm groups and beats
        SizedBox(
          height: MetronomeParams.heightRhythmGroups,
          child: Padding(
            padding: const EdgeInsets.all(TIOMusicParams.edgeInset),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                // List of rhythm segments
                ReorderableListView.builder(
                  proxyDecorator: _proxyDecorator,
                  buildDefaultDragHandles: false,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: isSecondMetronome ? _rhythmSegmentList2.length : _rhythmSegmentList.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: Key(
                        isSecondMetronome
                            ? _metronomeBlock.rhythmGroups2[index].keyID
                            : _metronomeBlock.rhythmGroups[index].keyID,
                      ),
                      direction:
                          isSecondMetronome
                              ? DismissDirection.up
                              : _metronomeBlock.rhythmGroups.length > 1
                              ? DismissDirection.up
                              : DismissDirection.none,
                      onDismissed: (_) {
                        _deleteRhythmSegment(index, isSecondMetronome);
                      },
                      background: const Icon(Icons.delete_outlined, color: ColorTheme.primary),
                      child: _rhythmGroup(index, isSecondMetronome),
                    );
                  },
                  onReorderStart: (index) {
                    setState(() {
                      _listTileMaskColor = const Color.fromARGB(57, 47, 47, 47);
                    });
                  },
                  onReorderEnd: (index) {
                    setState(() {
                      _listTileMaskColor = Colors.transparent;
                    });
                  },
                  // Reorder rhythm segments
                  onReorder: (oldIndex, newIndex) {
                    _reorderRythmSegments(oldIndex, newIndex, isSecondMetronome);
                  },
                ),
                const SizedBox(width: 4),
                // Button to add more segments
                CircleAvatar(
                  radius: TIOMusicParams.rhythmPlusButtonSize,
                  backgroundColor: Colors.white,
                  child: Center(
                    child: IconButton(
                      iconSize: TIOMusicParams.rhythmPlusButtonSize,
                      onPressed: () => _addRhythmSegment(isSecondMetronome),
                      icon: const Icon(Icons.add, color: ColorTheme.surfaceTint),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Metronome row title
        Padding(
          padding: const EdgeInsets.only(left: TIOMusicParams.edgeInset, right: TIOMusicParams.edgeInset),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: ColorTheme.surface, width: 2),
                bottom: BorderSide(color: ColorTheme.surface, width: 2),
              ),
            ),
            height: TIOMusicParams.rhythmPlusButtonSize * 2.5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isSecondMetronome ? 'Metronome 2' : 'Metronome 1',
                  style: const TextStyle(color: ColorTheme.primary),
                ),
                // add second metronome button
                if (isSecondMetronome || _metronomeBlock.rhythmGroups2.isNotEmpty)
                  const SizedBox()
                else
                  IconButton(
                    key: _keyAddSecondMetro,
                    iconSize: TIOMusicParams.rhythmPlusButtonSize,
                    onPressed: () => _addRhythmSegment(true),
                    icon: const Icon(Icons.add, color: ColorTheme.primary),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ParentTool(
      barTitle: _metronomeBlock.title,
      isQuickTool: widget.isQuickTool,
      project: widget.isQuickTool ? null : Provider.of<Project>(context, listen: false),
      toolBlock: _metronomeBlock,
      menuItems: _menuItems,
      onParentWalkthroughFinished: () {
        if (context.read<ProjectLibrary>().showMetronomeTutorial) {
          _createWalkthrough();
          _walkthrough.show(context);
        }
      },
      island: ParentIslandView(
        project: widget.isQuickTool ? null : Provider.of<Project>(context, listen: false),
        toolBlock: _metronomeBlock,
      ),
      heightForCenterModule: _metronomeBlock.rhythmGroups2.isNotEmpty ? 400 : null,
      centerModule: Stack(
        children: <Widget>[
          // Black screen for visual metronome
          Visibility(
            visible: _blink && _isFlashOn,
            child: CustomPaint(size: MediaQuery.of(context).size, painter: FilledScreen(color: ColorTheme.surfaceTint)),
          ),
          Center(
            child: Column(
              children: [
                _rhythmRow(),
                if (_metronomeBlock.rhythmGroups2.isNotEmpty) _rhythmRow(isSecondMetronome: true) else const SizedBox(),

                const SizedBox(height: TIOMusicParams.edgeInset),

                // Metronome control
                Align(
                  alignment: const Alignment(0, -0.4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Button to set visual metronome
                      OnOffButton(
                        isActive: _blink,
                        onTap: () {
                          setState(() {
                            _blink = !_blink;
                          });
                        },
                        iconOff: Icons.visibility_off_outlined,
                        iconOn: Icons.visibility_outlined,
                        buttonSize: TIOMusicParams.sizeSmallButtons,
                      ),
                      // Button to start/stop Metronome
                      OnOffButton(
                        key: _keyStartStop,
                        isActive: _isStarted,
                        onTap: _onToggleButtonClicked,
                        iconOff: MetronomeParams.svgIconPath,
                        iconOn: TIOMusicParams.pauseIcon,
                        buttonSize: TIOMusicParams.sizeBigButtons,
                      ),
                      // Button to turn sound on/off
                      OnOffButton(
                        isActive: _sound,
                        onTap: () {
                          setState(() {
                            _sound = !_sound;
                            _muteMetronome(!_sound);
                          });
                        },
                        iconOff: Icons.volume_off_outlined,
                        iconOn: Icons.volume_up_outlined,
                        buttonSize: TIOMusicParams.sizeSmallButtons,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Setting Tiles
      keySettingsList: _keySettings,
      settingTiles: [
        // Volume
        SettingsTile(
          title: 'Volume',
          subtitle: _metronomeBlock.volume.toString(),
          leadingIcon: Icons.volume_up,
          settingPage: SetVolume(
            initialValue: _metronomeBlock.volume,
            onConfirm: (vol) {
              _metronomeBlock.volume = vol;
              metronomeSetVolume(volume: vol);
            },
            onUserChangedVolume: (vol) => metronomeSetVolume(volume: vol),
            onCancel: () => metronomeSetVolume(volume: _metronomeBlock.volume),
          ),
          block: _metronomeBlock,
          callOnReturn: (value) => setState(() {}),
          icon: getVolumeInfoIcon(_deviceVolumeLevel),
          onIconPressed: showSnackbar(context: context, message: getVolumeInfoText(_deviceVolumeLevel)),
        ),
        // BPM
        SettingsTile(
          title: 'BPM',
          subtitle: '${_metronomeBlock.bpm}',
          leadingIcon: Icons.speed,
          settingPage: const SetBPM(),
          block: _metronomeBlock,
          callOnReturn: (value) => setState(() {}),
        ),
        // Sounds
        SettingsTile(
          title: _metronomeBlock.rhythmGroups2.isEmpty ? 'Sound' : 'Sound 1',
          subtitle:
              'Main: ${_metronomeBlock.accSound}, ${_metronomeBlock.unaccSound}\nPoly: ${_metronomeBlock.polyAccSound}, ${_metronomeBlock.polyUnaccSound}',
          leadingIcon: Icons.library_music_outlined,
          settingPage: SetMetronomeSound(running: _sound && _isStarted),
          block: _metronomeBlock,
          callOnReturn: (value) => setState(() {}),
        ),
        if (_metronomeBlock.rhythmGroups2.isEmpty)
          const SizedBox()
        else
          SettingsTile(
            title: 'Sound 2',
            subtitle:
                'Main: ${_metronomeBlock.accSound2}, ${_metronomeBlock.unaccSound2}\nPoly: ${_metronomeBlock.polyAccSound2}, ${_metronomeBlock.polyUnaccSound2}',
            leadingIcon: Icons.library_music_outlined,
            settingPage: SetMetronomeSound(running: _sound && _isStarted, forSecondMetronome: true),
            block: _metronomeBlock,
            callOnReturn: (value) => setState(() {}),
          ),
        // Random mute
        SettingsTile(
          title: 'Random Mute',
          subtitle: '${_metronomeBlock.randomMute}%',
          leadingIcon: Icons.question_mark,
          settingPage: const SetRandomMute(),
          block: _metronomeBlock,
          callOnReturn: (value) => setState(() {}),
        ),
      ],
    );
  }
}

// Fills the whole screen with any color
class FilledScreen extends CustomPainter {
  FilledScreen({required this.color});
  Color color;

  @override
  void paint(Canvas canvas, Size size) {
    var paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
