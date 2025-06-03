import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/app.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/models/rhythm_group.dart';
import 'package:tiomusic/pages/metronome/rhythm/rhythm_segment.dart';
import 'package:tiomusic/pages/metronome/rhythm/set_rhythm_parameters.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/tutorial_util.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tiomusic/widgets/metronome/rhythm_preset.dart';
import 'package:tiomusic/widgets/metronome/set_rhythm_parameters_simple.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class Rhythm extends StatefulWidget {
  final bool isFlashOn;
  final Function onUpdate;

  const Rhythm({super.key, required this.isFlashOn, required this.onUpdate});

  @override
  State<Rhythm> createState() => _RhythmState();
}

class _RhythmState extends State<Rhythm> with RouteAware {
  late ProjectRepository projectRepo;
  late MetronomeBlock metronomeBlock;

  bool isSimpleModeOn = true;
  bool isReordering = false;

  final List<RhythmSegment> rhythmSegmentList = List.empty(growable: true);
  final List<RhythmSegment> rhythmSegmentList2 = List.empty(growable: true);

  final ActiveBeatsModel activeBeatsModel = ActiveBeatsModel();

  final Tutorial tutorial = Tutorial();
  final GlobalKey keyGroups = GlobalKey();
  final GlobalKey keyAddSecondMetro = GlobalKey();

  @override
  void initState() {
    super.initState();

    projectRepo = context.read<ProjectRepository>();

    metronomeBlock = Provider.of<ProjectBlock>(context, listen: false) as MetronomeBlock;
    metronomeBlock.timeLastModified = getCurrentDateTime();
    isSimpleModeOn =
        RhythmPreset.fromProperties(
              beats: metronomeBlock.rhythmGroups[0].beats,
              polyBeats: metronomeBlock.rhythmGroups[0].polyBeats,
              noteKey: metronomeBlock.rhythmGroups[0].noteKey,
            ) !=
            null &&
        metronomeBlock.rhythmGroups.length == 1 &&
        metronomeBlock.rhythmGroups2.isEmpty;

    _clearAndRebuildRhythmSegments(false);
    _clearAndRebuildRhythmSegments(true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<ProjectLibrary>().showMetronomeTutorial &&
          !context.read<ProjectLibrary>().showToolTutorial &&
          !context.read<ProjectLibrary>().showQuickToolTutorial &&
          !context.read<ProjectLibrary>().showIslandTutorial) {
        _createTutorial();
        tutorial.show(context);
      }
    });
  }

  void _toggleSimpleMode() {
    setState(() {
      isSimpleModeOn = !isSimpleModeOn;

      if (isSimpleModeOn) {
        final rhythmGroup = metronomeBlock.rhythmGroups[0];
        final presetKey =
            RhythmPreset.fromProperties(
              beats: rhythmGroup.beats,
              polyBeats: rhythmGroup.polyBeats,
              noteKey: rhythmGroup.noteKey,
            ) ??
            RhythmPresetKey.oneFourth;
        final preset = RhythmPreset.fromKey(presetKey);

        _handleUpdateRhythm(RhythmGroup('', preset.beats, preset.polyBeats, preset.noteKey));
      }
    });
  }

  void _createTutorial() {
    final l10n = context.l10n;
    var targets = <CustomTargetFocus>[
      CustomTargetFocus(
        keyGroups,
        l10n.metronomeTutorialRelocate,
        alignText: ContentAlign.bottom,
        pointingDirection: PointingDirection.up,
        shape: ShapeLightFocus.RRect,
        pointerPosition: PointerPosition.left,
      ),
      CustomTargetFocus(
        keyAddSecondMetro,
        l10n.metronomeTutorialAddNew,
        alignText: ContentAlign.left,
        pointingDirection: PointingDirection.right,
      ),
    ];
    tutorial.create(targets.map((e) => e.targetFocus).toList(), () async {
      context.read<ProjectLibrary>().showMetronomeTutorial = false;
      await projectRepo.saveLibrary(context.read<ProjectLibrary>());
    }, context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute? route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  void _addRhythmSegment(bool isSecond) async {
    int newIndex = isSecond ? metronomeBlock.rhythmGroups2.length : metronomeBlock.rhythmGroups.length;

    openSettingPage(
      SetRhythmParameters(
        currentNoteKey: MetronomeParams.defaultNoteKey,
        currentBeats: MetronomeParams.defaultBeats,
        currentPolyBeats: MetronomeParams.defaultPolyBeats,
        isAddingNewBar: true,
        rhythmGroups: isSecond ? metronomeBlock.rhythmGroups2 : metronomeBlock.rhythmGroups,
        isSecondMetronome: isSecond,
        metronomeBlock: metronomeBlock,
      ),
      context,
      metronomeBlock,
      callbackOnReturn: (addingConfirmed) {
        setState(() {
          if (addingConfirmed != null && addingConfirmed) {
            var newRhythmSegment = RhythmSegment(
              activeBeatsNotifier: activeBeatsModel,
              barIdx: newIndex,
              metronomeBlock: metronomeBlock,
              isSecondary: isSecond,
              editFunction: () => _editRhythmSegment(newIndex, isSecond),
            );

            isSecond ? rhythmSegmentList2.add(newRhythmSegment) : rhythmSegmentList.add(newRhythmSegment);
          }
          widget.onUpdate(); // stop metronome
        });
      },
    );
  }

  void _editRhythmSegment(int idx, bool isSecond) async {
    var rhythmGroups = isSecond ? metronomeBlock.rhythmGroups2 : metronomeBlock.rhythmGroups;

    openSettingPage(
      SetRhythmParameters(
        barIndex: idx,
        currentNoteKey: rhythmGroups[idx].noteKey,
        currentBeats: rhythmGroups[idx].beats,
        currentPolyBeats: rhythmGroups[idx].polyBeats,
        isAddingNewBar: false,
        rhythmGroups: rhythmGroups,
        isSecondMetronome: isSecond,
        metronomeBlock: metronomeBlock,
      ),
      context,
      metronomeBlock,
    ).then((value) { // TODO: await instad of then
      var newRhythmSegment = RhythmSegment(
        activeBeatsNotifier: activeBeatsModel,
        metronomeBlock: metronomeBlock,
        barIdx: idx,
        isSecondary: isSecond,
        editFunction: () => _editRhythmSegment(idx, isSecond),
      );

      isSecond ? rhythmSegmentList2[idx] = newRhythmSegment : rhythmSegmentList[idx] = newRhythmSegment;

      widget.onUpdate(); // stop metronome
      setState(() {});
    });
  }

  void _handleUpdateRhythm(RhythmGroup rhythmGroup) async {
    metronomeBlock.rhythmGroups
      ..clear()
      ..add(rhythmGroup);

    metronomeBlock.resetSecondaryMetronome();

    _clearAndRebuildRhythmSegments(false);
    _clearAndRebuildRhythmSegments(true);

    setState(() {});
    await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
  }

  void _deleteRhythmSegment(int index, bool isSecond) async {
    isSecond ? metronomeBlock.rhythmGroups2.removeAt(index) : metronomeBlock.rhythmGroups.removeAt(index);

    _clearAndRebuildRhythmSegments(isSecond);

    widget.onUpdate(); // stop metronome
    setState(() {});
  }

  void _reorderRhythmSegments(int oldIndex, int newIndex, bool isSecond) async {
    metronomeBlock.changeRhythmOrder(
      oldIndex,
      newIndex,
      isSecond ? metronomeBlock.rhythmGroups2 : metronomeBlock.rhythmGroups,
    );

    _clearAndRebuildRhythmSegments(isSecond);

    widget.onUpdate(); // stop metronome
    setState(() {});
  }

  void _clearAllRhythms() async {
    rhythmSegmentList.clear();
    rhythmSegmentList2.clear();
    metronomeBlock.resetPrimaryMetronome();
    metronomeBlock.rhythmGroups[0].keyID = MetronomeParams.getNewKeyID();
    metronomeBlock.resetSecondaryMetronome();

    rhythmSegmentList.add(
      RhythmSegment(
        activeBeatsNotifier: activeBeatsModel,
        barIdx: 0,
        metronomeBlock: metronomeBlock,
        isSecondary: false,
        editFunction: () => _editRhythmSegment(0, false),
      ),
    );

    widget.onUpdate(); // stop metronome
    setState(() {});
  }

  void _clearAndRebuildRhythmSegments(bool isSecond) {
    isSecond ? rhythmSegmentList2.clear() : rhythmSegmentList.clear();
    for (int i = 0; i < (isSecond ? metronomeBlock.rhythmGroups2.length : metronomeBlock.rhythmGroups.length); i++) {
      var newRhythmSegment = RhythmSegment(
        activeBeatsNotifier: activeBeatsModel,
        barIdx: i,
        metronomeBlock: metronomeBlock,
        isSecondary: isSecond,
        editFunction: () => _editRhythmSegment(i, isSecond),
      );
      isSecond ? rhythmSegmentList2.add(newRhythmSegment) : rhythmSegmentList.add(newRhythmSegment);
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

  Widget _rhythmGroup(int index, bool isSecond) {
    return DecoratedBox(
      key: index == 0 && !isSecond ? keyGroups : null,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: isReordering ? const Color.fromARGB(57, 47, 47, 47) : Colors.transparent),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child:
        // Reordering handle with icon
        ReorderableDelayedDragStartListener(
          index: index,
          enabled: (isSecond ? metronomeBlock.rhythmGroups2.length : metronomeBlock.rhythmGroups.length) > 1,
          child: GestureDetector(
            onTap: () {
              _editRhythmSegment(index, isSecond);
            },
            child: isSecond ? rhythmSegmentList2[index] : rhythmSegmentList[index],
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
                  itemCount: isSecondMetronome ? rhythmSegmentList2.length : rhythmSegmentList.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: Key(
                        isSecondMetronome
                            ? metronomeBlock.rhythmGroups2[index].keyID
                            : metronomeBlock.rhythmGroups[index].keyID,
                      ),
                      direction:
                          isSecondMetronome
                              ? DismissDirection.up
                              : metronomeBlock.rhythmGroups.length > 1
                              ? DismissDirection.up
                              : DismissDirection.none,
                      onDismissed: (_) {
                        _deleteRhythmSegment(index, isSecondMetronome);
                      },
                      background: const Icon(Icons.delete_outlined, color: ColorTheme.primary),
                      child: _rhythmGroup(index, isSecondMetronome),
                    );
                  },
                  onReorderStart: (_) => setState(() => isReordering = true),
                  onReorderEnd: (_) => setState(() => isReordering = false),
                  onReorder: (oldIndex, newIndex) => _reorderRhythmSegments(oldIndex, newIndex, isSecondMetronome),
                ),
                const SizedBox(width: 4),
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
                  isSecondMetronome ? context.l10n.metronomeSecondary : context.l10n.metronomePrimary,
                  style: const TextStyle(color: ColorTheme.primary),
                ),
                // add second metronome button
                if (isSecondMetronome || metronomeBlock.rhythmGroups2.isNotEmpty)
                  const SizedBox()
                else
                  IconButton(
                    key: keyAddSecondMetro,
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
    return Stack(
        children: <Widget>[
          Visibility(
            visible: widget.isFlashOn,
            child: CustomPaint(size: MediaQuery.of(context).size, painter: FilledScreen(color: ColorTheme.surfaceTint)),
          ),
          Center(
            child: Column(
              children: [
                if (isSimpleModeOn)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    child: SetRhythmParametersSimple(
                      rhythmGroup: metronomeBlock.rhythmGroups[0],
                      onUpdate: _handleUpdateRhythm,
                    ),
                  )
                else ...[
                  _rhythmRow(),
                  if (metronomeBlock.rhythmGroups2.isNotEmpty) _rhythmRow(isSecondMetronome: true),
                ],
              ],
            ),
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
