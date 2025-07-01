import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/models/rhythm_group.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/tutorial_util.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tiomusic/widgets/metronome/group/editable_group.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class Groups extends StatefulWidget {
  final List<RhythmGroup> rhythmGroups;
  final int? highlightedSegmentIndex;
  final int? highlightedMainBeatIndex;
  final int? highlightedPolyBeatIndex;

  final String label;
  final bool canDeleteLastSegment;
  final Widget addSecondaryAction;

  final Function() onAdd;
  final Function(int index) onDelete;
  final Function(int index) onEdit;
  final Function(int oldIndex, int newIndex) onReorder;

  const Groups({
    super.key,
    required this.rhythmGroups,
    required this.highlightedSegmentIndex,
    required this.highlightedMainBeatIndex,
    required this.highlightedPolyBeatIndex,
    required this.label,
    required this.canDeleteLastSegment,
    required this.onAdd,
    required this.onDelete,
    required this.onEdit,
    required this.onReorder,
    required this.addSecondaryAction,
  });

  @override
  State<Groups> createState() => _GroupsState();
}

class _GroupsState extends State<Groups> with RouteAware {
  bool isReordering = false;

  late ProjectRepository projectRepo;

  final Tutorial tutorial = Tutorial();
  final GlobalKey keyGroups = GlobalKey();
  final GlobalKey keyAddSecondMetro = GlobalKey();

  int? _getHighlightedMainBeatIndex(int segmentIndex) =>
      widget.highlightedSegmentIndex == segmentIndex ? widget.highlightedMainBeatIndex : null;

  int? _getHighlightedPolyBeatIndex(int segmentIndex) =>
      widget.highlightedSegmentIndex == segmentIndex ? widget.highlightedPolyBeatIndex : null;

  @override
  void initState() {
    super.initState();

    projectRepo = context.read<ProjectRepository>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<ProjectLibrary>().showRhythmTutorial) {
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
  Widget build(BuildContext context) {
    return Column(
      key: keyGroups,
      children: [
        SizedBox(
          height: MetronomeParams.heightRhythmGroups,
          child: Padding(
            padding: const EdgeInsets.all(TIOMusicParams.edgeInset),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                ReorderableListView.builder(
                  proxyDecorator:
                      (child, index, animation) => AnimatedBuilder(
                        animation: animation,
                        builder: (context, child) {
                          final double animValue = Curves.easeInOut.transform(animation.value);
                          final double elevation = lerpDouble(0, 6, animValue)!;
                          return Material(
                            elevation: elevation,
                            color: Colors.transparent,
                            shadowColor: Colors.transparent,
                            child: child,
                          );
                        },
                        child: child,
                      ),
                  buildDefaultDragHandles: false,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: widget.rhythmGroups.length,
                  itemBuilder:
                      (context, index) => Dismissible(
                        key: Key(widget.rhythmGroups[index].keyID),
                        direction:
                            widget.canDeleteLastSegment || widget.rhythmGroups.length > 1
                                ? DismissDirection.up
                                : DismissDirection.none,
                        onDismissed: (_) => widget.onDelete(index),
                        background: const Icon(Icons.delete_outlined, color: ColorTheme.primary),
                        child: EditableGroup(
                          index: index,
                          highlightedMainBeatIndex: _getHighlightedMainBeatIndex(index),
                          highlightedPolyBeatIndex: _getHighlightedPolyBeatIndex(index),
                          rhythmGroup: widget.rhythmGroups[index],
                          canReorder: widget.rhythmGroups.length > 1,
                          isReordering: isReordering,
                          onEdit: () => widget.onEdit(index),
                        ),
                      ),
                  onReorderStart: (_) => setState(() => isReordering = true),
                  onReorderEnd: (_) => setState(() => isReordering = false),
                  onReorder: widget.onReorder,
                ),
                const SizedBox(width: 4),
                CircleAvatar(
                  radius: TIOMusicParams.rhythmPlusButtonSize,
                  backgroundColor: Colors.white,
                  child: Center(
                    child: IconButton(
                      iconSize: TIOMusicParams.rhythmPlusButtonSize,
                      onPressed: () => widget.onAdd(),
                      icon: const Icon(Icons.add, color: ColorTheme.surfaceTint),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

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
                Text(widget.label, style: const TextStyle(color: ColorTheme.primary)),
                Container(key: keyAddSecondMetro, child: widget.addSecondaryAction),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
