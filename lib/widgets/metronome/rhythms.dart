import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/app.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/models/rhythm_group.dart';
import 'package:tiomusic/pages/metronome/complex_rhythm_group_select.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/tutorial_util.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tiomusic/widgets/metronome/current_beat.dart';
import 'package:tiomusic/widgets/metronome/rhythm_row.dart';
import 'package:tiomusic/widgets/metronome/simple_rhythm_group_select.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class Rhythms extends StatefulWidget {
  final bool isSimpleModeOn;
  final CurrentBeat currentPrimaryBeat;
  final CurrentBeat currentSecondaryBeat;
  final void Function() onUpdate;

  const Rhythms({
    super.key,
    required this.isSimpleModeOn,
    required this.currentPrimaryBeat,
    required this.currentSecondaryBeat,
    required this.onUpdate,
  });

  @override
  State<Rhythms> createState() => _RhythmsState();
}

class _RhythmsState extends State<Rhythms> with RouteAware {
  late ProjectRepository projectRepo;
  late MetronomeBlock metronomeBlock;

  // final ActiveBeatsModel activeBeatsModel = ActiveBeatsModel();

  final Tutorial tutorial = Tutorial();
  final GlobalKey keyGroups = GlobalKey();
  final GlobalKey keyAddSecondMetro = GlobalKey();

  @override
  void initState() {
    super.initState();

    projectRepo = context.read<ProjectRepository>();

    metronomeBlock = Provider.of<ProjectBlock>(context, listen: false) as MetronomeBlock;
    metronomeBlock.timeLastModified = getCurrentDateTime();

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

  void _createTutorial() {
    final l10n = context.l10n;
    final targets = <CustomTargetFocus>[
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
    if (route is PageRoute) routeObserver.subscribe(this, route);
  }

  void _handleAddRhythmGroup(bool isSecondary) async {
    widget.onUpdate();
    openSettingPage(
      ComplexRhythmGroupSelect(
        metronomeBlock: metronomeBlock,
        rhythmGroups: isSecondary ? metronomeBlock.rhythmGroups2 : metronomeBlock.rhythmGroups,
        currentNoteKey: MetronomeParams.defaultNoteKey,
        currentMainBeats: MetronomeParams.defaultBeats,
        currentPolyBeats: MetronomeParams.defaultPolyBeats,
        isAddingNewRhythmGroup: true,
        isSecondMetronome: isSecondary,
      ),
      context,
      metronomeBlock,
      callbackOnReturn: (addingConfirmed) {
        if (addingConfirmed != true) return;
        setState(() {});
        widget.onUpdate();
      },
    );
  }

  Future<void> _handleEditRhythmGroup(int index, bool isSecondary) async {
    widget.onUpdate();
    final rhythmGroups = isSecondary ? metronomeBlock.rhythmGroups2 : metronomeBlock.rhythmGroups;

    await openSettingPage(
      ComplexRhythmGroupSelect(
        metronomeBlock: metronomeBlock,
        rhythmGroups: rhythmGroups,
        rhythmGroupIndex: index,
        currentNoteKey: rhythmGroups[index].noteKey,
        currentMainBeats: rhythmGroups[index].beats,
        currentPolyBeats: rhythmGroups[index].polyBeats,
        isAddingNewRhythmGroup: false,
        isSecondMetronome: isSecondary,
      ),
      context,
      metronomeBlock,
      callbackOnReturn: (editingConfirmed) {
        if (editingConfirmed != true) return;
        setState(() {});
        widget.onUpdate();
      },
    );
  }

  void _handleUpdateRhythmGroup(RhythmGroup rhythmGroup) async {
    metronomeBlock.rhythmGroups
      ..clear()
      ..add(rhythmGroup);
    metronomeBlock.resetSecondaryMetronome();
    setState(() {});
    widget.onUpdate();
  }

  void _handleReorderRhythmSegments(int oldIndex, int newIndex, bool isSecondary) async {
    metronomeBlock.changeRhythmOrder(
      oldIndex,
      newIndex,
      isSecondary ? metronomeBlock.rhythmGroups2 : metronomeBlock.rhythmGroups,
    );
    setState(() {});
    widget.onUpdate();
  }

  void _handleDeleteRhythmGroup(int index, bool isSecondary) async {
    isSecondary ? metronomeBlock.rhythmGroups2.removeAt(index) : metronomeBlock.rhythmGroups.removeAt(index);
    setState(() {});
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          if (widget.isSimpleModeOn)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              child: SimpleRhythmGroupSelect(
                rhythmGroup: metronomeBlock.rhythmGroups[0],
                onUpdate: _handleUpdateRhythmGroup,
              ),
            )
          else ...[
            RhythmRow(
              rhythmGroups: metronomeBlock.rhythmGroups,
              highlightedSegmentIndex: widget.currentPrimaryBeat.segmentIndex,
              highlightedMainBeatIndex: widget.currentPrimaryBeat.mainBeatIndex,
              highlightedPolyBeatIndex: widget.currentPrimaryBeat.polyBeatIndex,
              label: context.l10n.metronomePrimary,
              canDeleteLastSegment: false,
              onAdd: () => _handleAddRhythmGroup(false),
              onDelete: (index) => _handleDeleteRhythmGroup(index, false),
              onEdit: (index) => _handleEditRhythmGroup(index, false),
              onReorder: (oldIndex, newIndex) => _handleReorderRhythmSegments(oldIndex, newIndex, false),
              addSecondaryAction:
                  metronomeBlock.rhythmGroups2.isEmpty
                      ? IconButton(
                        key: keyAddSecondMetro,
                        iconSize: TIOMusicParams.rhythmPlusButtonSize,
                        onPressed: () => _handleAddRhythmGroup(true),
                        icon: const Icon(Icons.add, color: ColorTheme.primary),
                      )
                      : const SizedBox(),
            ),
            if (metronomeBlock.rhythmGroups2.isNotEmpty)
              RhythmRow(
                rhythmGroups: metronomeBlock.rhythmGroups2,
                highlightedSegmentIndex: widget.currentSecondaryBeat.segmentIndex,
                highlightedMainBeatIndex: widget.currentSecondaryBeat.mainBeatIndex,
                highlightedPolyBeatIndex: widget.currentSecondaryBeat.polyBeatIndex,
                label: context.l10n.metronomeSecondary,
                canDeleteLastSegment: true,
                onAdd: () => _handleAddRhythmGroup(true),
                onDelete: (index) => _handleDeleteRhythmGroup(index, true),
                onEdit: (index) => _handleEditRhythmGroup(index, true),
                onReorder: (oldIndex, newIndex) => _handleReorderRhythmSegments(oldIndex, newIndex, true),
                addSecondaryAction: const SizedBox(),
              ),
          ],
        ],
      ),
    );
  }
}
