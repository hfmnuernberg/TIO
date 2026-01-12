import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/tutorial/tutorial_util.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class MediaPlayerTutorial {
  final ProjectRepository projectRepo;
  final bool Function() isQuickTool;

  final GlobalKey keyStartStop;
  final GlobalKey keyRepeat;
  final GlobalKey keySettings;
  final GlobalKey keyWaveform;
  final GlobalKey islandToolTutorialKey;

  final Tutorial _tutorial = Tutorial();
  bool _didShowWaveformTutorial = false;

  MediaPlayerTutorial({
    required this.projectRepo,
    required this.isQuickTool,
    required this.keyStartStop,
    required this.keyRepeat,
    required this.keySettings,
    required this.keyWaveform,
    required this.islandToolTutorialKey,
  });

  void dispose() {
    _tutorial.dispose();
  }

  void show(BuildContext context, {required bool playerLoaded}) {
    _create(context, playerLoaded: playerLoaded);
    _tutorial.show(context);
  }

  void maybeShowWaveformTutorial(BuildContext context, {required bool playerLoaded}) {
    if (!context.mounted) return;

    if (_didShowWaveformTutorial) return;
    if (!playerLoaded) return;

    final lib = context.read<ProjectLibrary>();

    final shouldShowAnything =
        lib.showWaveformTip || lib.showMediaPlayerTutorial || (lib.showMediaPlayerIslandTutorial && !isQuickTool());

    if (!shouldShowAnything) return;

    _didShowWaveformTutorial = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      if (!playerLoaded) return;

      final lib = context.read<ProjectLibrary>();
      final shouldShowAnything =
          lib.showWaveformTip || lib.showMediaPlayerTutorial || (lib.showMediaPlayerIslandTutorial && !isQuickTool());
      if (!shouldShowAnything) return;

      _create(context, playerLoaded: playerLoaded);
      _tutorial.show(context);
    });
  }

  void _create(BuildContext context, {required bool playerLoaded}) {
    final l10n = context.l10n;
    final lib = context.read<ProjectLibrary>();

    final targets = <CustomTargetFocus>[
      if (lib.showMediaPlayerTutorial)
        CustomTargetFocus(
          keyStartStop,
          l10n.mediaPlayerTutorialStartStop,
          alignText: ContentAlign.top,
          pointingDirection: PointingDirection.down,
          buttonsPosition: ButtonsPosition.top,
        ),
      if (lib.showWaveformTip && playerLoaded)
        CustomTargetFocus(
          keyRepeat,
          l10n.mediaPlayerTutorialRepeat,
          alignText: ContentAlign.top,
          pointingDirection: PointingDirection.down,
        ),
      if (lib.showMediaPlayerTutorial)
        CustomTargetFocus(
          keySettings,
          l10n.mediaPlayerTutorialAdjust,
          alignText: ContentAlign.top,
          pointingDirection: PointingDirection.down,
          buttonsPosition: ButtonsPosition.top,
          shape: ShapeLightFocus.RRect,
        ),
      if (lib.showMediaPlayerIslandTutorial && !isQuickTool())
        CustomTargetFocus(
          islandToolTutorialKey,
          l10n.mediaPlayerTutorialIslandTool,
          pointingDirection: PointingDirection.up,
          alignText: ContentAlign.bottom,
          shape: ShapeLightFocus.RRect,
        ),
      if (lib.showWaveformTip && playerLoaded)
        CustomTargetFocus(
          keyWaveform,
          l10n.mediaPlayerTutorialWaveform,
          pointingDirection: PointingDirection.up,
          shape: ShapeLightFocus.RRect,
          buttonsPosition: ButtonsPosition.top,
          alignText: ContentAlign.custom,
          customTextPosition: CustomTargetContentPosition(top: MediaQuery.of(context).size.height / 1.6),
        ),
      if (lib.showWaveformTip && playerLoaded)
        CustomTargetFocus(
          keyWaveform,
          l10n.mediaPlayerTutorialWaveformZoom,
          pointingDirection: PointingDirection.up,
          shape: ShapeLightFocus.RRect,
          buttonsPosition: ButtonsPosition.top,
          alignText: ContentAlign.custom,
          customTextPosition: CustomTargetContentPosition(top: MediaQuery.of(context).size.height / 1.6),
        ),
      if (lib.showWaveformTip && playerLoaded)
        CustomTargetFocus(
          keyWaveform,
          l10n.mediaPlayerTutorialWaveformPan,
          pointingDirection: PointingDirection.up,
          shape: ShapeLightFocus.RRect,
          buttonsPosition: ButtonsPosition.top,
          alignText: ContentAlign.custom,
          customTextPosition: CustomTargetContentPosition(top: MediaQuery.of(context).size.height / 1.6),
        ),
      if (lib.showWaveformTip && playerLoaded)
        CustomTargetFocus(
          keyWaveform,
          l10n.mediaPlayerTutorialWaveformTap,
          pointingDirection: PointingDirection.up,
          shape: ShapeLightFocus.RRect,
          buttonsPosition: ButtonsPosition.top,
          alignText: ContentAlign.custom,
          customTextPosition: CustomTargetContentPosition(top: MediaQuery.of(context).size.height / 1.6),
        ),
    ];

    if (targets.isEmpty) return;
    targets.first.hideBack = true;

    _tutorial.create(targets.map((e) => e.targetFocus).toList(), () async {
      if (lib.showMediaPlayerTutorial) lib.showMediaPlayerTutorial = false;
      if (lib.showMediaPlayerIslandTutorial && !isQuickTool()) lib.showMediaPlayerIslandTutorial = false;
      if (lib.showWaveformTip && playerLoaded) lib.showWaveformTip = false;

      await projectRepo.saveLibrary(lib);
    }, context);
  }
}
