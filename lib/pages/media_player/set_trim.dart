import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/media_player/markers/waveform.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/domain/audio/player.dart';
import 'package:tiomusic/pages/media_player/markers/zoom_rms_helper.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/tutorial/tutorial_util.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class SetTrim extends StatefulWidget {
  final MediaPlayerBlock mediaPlayerBlock;
  final Float32List rmsValues;
  final Player player;

  const SetTrim({super.key, required this.mediaPlayerBlock, required this.rmsValues, required this.player});

  @override
  State<SetTrim> createState() => _SetTrimState();
}

class _SetTrimState extends State<SetTrim> {
  MediaPlayerBlock get block => widget.mediaPlayerBlock;
  Player get player => widget.player;
  late RangeValues rangeValues;
  late Float32List rmsValues;
  late int targetVisibleBins;
  late ProjectRepository projectRepo;

  final Tutorial tutorial = Tutorial();
  final GlobalKey keyWaveform = GlobalKey();

  @override
  void initState() {
    super.initState();

    projectRepo = context.read<ProjectRepository>();
    rangeValues = RangeValues(block.rangeStart, block.rangeEnd);
    rmsValues = widget.rmsValues;
    targetVisibleBins = widget.rmsValues.length;

    showTutorial();
  }

  @override
  void dispose() {
    tutorial.dispose();
    super.dispose();
  }

  void showTutorial() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final projectLibrary = context.read<ProjectLibrary>();

      if (projectLibrary.showMediaPlayerSetTrimTutorial) {
        projectLibrary.showMediaPlayerSetTrimTutorial = false;
        await context.read<ProjectRepository>().saveLibrary(projectLibrary);
        createTutorial();
        if (!mounted) return;
        tutorial.show(context);
      }
    });
  }

  void createTutorial() {
    final l10n = context.l10n;
    final targets = <CustomTargetFocus>[
      CustomTargetFocus(
        keyWaveform,
        l10n.mediaPlayerSetTrimTutorialTap,
        alignText: ContentAlign.bottom,
        pointingDirection: PointingDirection.up,
        shape: ShapeLightFocus.RRect,
        buttonsPosition: ButtonsPosition.top,
      ),
    ];

    targets.first.hideBack = true;
    tutorial.create(targets.map((e) => e.targetFocus).toList(), () async {
      context.read<ProjectLibrary>().showMediaPlayerSetTrimTutorial = false;
      await projectRepo.saveLibrary(context.read<ProjectLibrary>());
    }, context);
  }

  Future<void> handleChange(RangeValues values) async {
    setState(() => rangeValues = values);
    if (rangeValues.start < rangeValues.end) await player.setTrim(rangeValues.start, rangeValues.end);
  }

  Future<void> handleWaveformPositionChange(double relative) async {
    double start = rangeValues.start;
    double end = rangeValues.end;

    const double minDelta = 0.001;

    final bool isRangeStartMoved = (relative - start).abs() <= (relative - end).abs();
    if (isRangeStartMoved) {
      start = relative;
      if (start > end - minDelta) {
        start = (end - minDelta).clamp(0.0, 1.0);
      }
    } else {
      end = relative;
      if (end < start + minDelta) {
        end = (start + minDelta).clamp(0.0, 1.0);
      }
    }

    start = start.clamp(0.0, 1.0);
    end = end.clamp(0.0, 1.0);

    await handleChange(RangeValues(start, end));
  }

  Future<void> handleConfirm() async {
    block.rangeStart = rangeValues.start;
    block.rangeEnd = rangeValues.end;
    await player.setTrim(rangeValues.start, rangeValues.end);

    if (mounted) await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> handleCancel() async {
    await player.setTrim(block.rangeStart, block.rangeEnd);
    if (mounted) Navigator.pop(context);
  }

  Future<void> handleReset() async => handleChange(const RangeValues(0, 1));

  Future<void> handleZoomChanged(double viewStart, double viewEnd) async {
    final Float32List? newRms = await recalculateRmsForZoom(
      player: widget.player,
      targetVisibleBins: targetVisibleBins,
      viewStart: viewStart,
      viewEnd: viewEnd,
      currentBinCount: rmsValues.length,
    );
    if (!mounted || newRms == null) return;
    setState(() => rmsValues = newRms);
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: context.l10n.mediaPlayerSetTrim,
      confirm: handleConfirm,
      reset: handleReset,
      cancel: handleCancel,
      customWidget: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Waveform(
            key: keyWaveform,
            rmsValues: rmsValues,
            position: null,
            rangeStart: rangeValues.start,
            rangeEnd: rangeValues.end,
            fileDuration: player.fileDuration,
            markerPositions: const [],
            selectedMarkerPosition: null,
            onPositionChange: handleWaveformPositionChange,
            onZoomChanged: handleZoomChanged,
          ),
        ],
      ),
    );
  }
}
