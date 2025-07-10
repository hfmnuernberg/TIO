import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/app.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/rhythm_group.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/metronome_beat.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/metronome/group/groups.dart';
import 'package:tiomusic/widgets/metronome/simple_rhythm_group_editor.dart';

class Rhythms extends StatefulWidget {
  final bool isSimpleModeOn;
  final MetronomeBeat currentPrimaryBeat;
  final MetronomeBeat currentSecondaryBeat;
  final void Function() onUpdate;
  final void Function(bool isSecondary, int rhythmGroupIndex) onEditRhythmGroup;
  final void Function(bool isSecondary) onAddRhythmGroup;

  const Rhythms({
    super.key,
    required this.isSimpleModeOn,
    required this.currentPrimaryBeat,
    required this.currentSecondaryBeat,
    required this.onUpdate,
    required this.onEditRhythmGroup,
    required this.onAddRhythmGroup,
  });

  @override
  State<Rhythms> createState() => _RhythmsState();
}

class _RhythmsState extends State<Rhythms> with RouteAware {
  late ProjectRepository projectRepo;
  late MetronomeBlock metronomeBlock;

  @override
  void initState() {
    super.initState();

    projectRepo = context.read<ProjectRepository>();

    metronomeBlock = Provider.of<ProjectBlock>(context, listen: false) as MetronomeBlock;
    metronomeBlock.timeLastModified = getCurrentDateTime();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute? route = ModalRoute.of(context);
    if (route is PageRoute) routeObserver.subscribe(this, route);
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
              child: SimpleRhythmGroupEditor(
                rhythmGroup: metronomeBlock.rhythmGroups[0],
                onUpdate: _handleUpdateRhythmGroup,
              ),
            )
          else ...[
            Groups(
              rhythmGroups: metronomeBlock.rhythmGroups,
              highlightedSegmentIndex: widget.currentPrimaryBeat.segmentIndex,
              highlightedMainBeatIndex: widget.currentPrimaryBeat.mainBeatIndex,
              highlightedPolyBeatIndex: widget.currentPrimaryBeat.polyBeatIndex,
              label: context.l10n.metronomePrimary,
              canDeleteLastSegment: false,
              onAdd: () => widget.onAddRhythmGroup(false),
              onDelete: (index) => _handleDeleteRhythmGroup(index, false),
              onEdit: (index) => widget.onEditRhythmGroup(false, index),
              onReorder: (oldIndex, newIndex) => _handleReorderRhythmSegments(oldIndex, newIndex, false),
              addSecondaryAction:
                  metronomeBlock.rhythmGroups2.isEmpty
                      ? IconButton(
                        iconSize: TIOMusicParams.rhythmPlusButtonSize,
                        onPressed: () => widget.onAddRhythmGroup(true),
                        icon: const Icon(Icons.add, color: ColorTheme.primary),
                      )
                      : const SizedBox(),
            ),
            if (metronomeBlock.rhythmGroups2.isNotEmpty)
              Groups(
                rhythmGroups: metronomeBlock.rhythmGroups2,
                highlightedSegmentIndex: widget.currentSecondaryBeat.segmentIndex,
                highlightedMainBeatIndex: widget.currentSecondaryBeat.mainBeatIndex,
                highlightedPolyBeatIndex: widget.currentSecondaryBeat.polyBeatIndex,
                label: context.l10n.metronomeSecondary,
                canDeleteLastSegment: true,
                onAdd: () => widget.onAddRhythmGroup(true),
                onDelete: (index) => _handleDeleteRhythmGroup(index, true),
                onEdit: (index) => widget.onEditRhythmGroup(true, index),
                onReorder: (oldIndex, newIndex) => _handleReorderRhythmSegments(oldIndex, newIndex, true),
                addSecondaryAction: const SizedBox(),
              ),
          ],
        ],
      ),
    );
  }
}
