import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants/constants.dart';
import 'package:tiomusic/util/log.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class Tutorial {
  static final _logger = createPrefixLogger('Tutorial');

  TutorialCoachMark? _tutorialCoachMark;
  bool _isDisposing = false;

  Tutorial();

  static const backgroundColor = ColorTheme.primary50;
  static const backgroundOpacity = 0.8;

  void show(BuildContext context) {
    // showing tutorial delayed to avoid misplaced tooltips when new page is animated in from the side
    Future.delayed(const Duration(milliseconds: 400), () {
      if (context.mounted) _tutorialCoachMark?.show(context: context);
    });
  }

  void create(List<TargetFocus> targets, Function() onFinish, BuildContext context, FutureOr<void> Function() onSkip) {
    _tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: backgroundColor,
      hideSkip: true,
      pulseEnable: false,
      onFinish: () {
        _tutorialCoachMark = null;
        if (!_isDisposing) onFinish();
      },
      onSkip: () {
        _tutorialCoachMark = null;
        if (_isDisposing) return true;

        final result = onSkip.call();
        if (result is Future) unawaited(result);
        return true;
      },
    );
  }

  void dispose() {
    try {
      _isDisposing = true;
      _tutorialCoachMark?.finish();
    } catch (error) {
      _logger.e('Unable to finish tutorial.', error: error);
    } finally {
      _tutorialCoachMark = null;
      _isDisposing = false;
    }
  }
}

class CustomTargetFocus {
  late TargetFocus targetFocus;

  CustomTargetFocus(
    GlobalKey? key, // set key to null to cover whole screen without specific target (and provide context!)
    String description, {
    BuildContext?
    context, // context should be provided if using ButtonsPosition left or right and if setting key to null
    ContentAlign? alignText,
    CustomTargetContentPosition? customTextPosition,
    PointingDirection? pointingDirection,
    ButtonsPosition? buttonsPosition, // left and right not useable in landscape mode
    ShapeLightFocus? shape,
    double pointerOffset = 0,
    PointerPosition pointerPosition = PointerPosition.center,
  }) {
    final mediaQuery = (context != null) ? MediaQuery.of(context) : null;
    final safeTop = mediaQuery?.viewPadding.top ?? 0;
    final safeBottom = mediaQuery?.viewPadding.bottom ?? 0;
    final safeHeight = mediaQuery != null ? mediaQuery.size.height - safeTop - safeBottom : 0;
    const edgeSpace = 8.0;
    CustomTargetContentPosition positionNextButton;
    CrossAxisAlignment buttonsColumnCrossAlign = CrossAxisAlignment.center;

    switch (buttonsPosition) {
      case ButtonsPosition.top:
        positionNextButton = CustomTargetContentPosition(top: edgeSpace + safeTop);
        buttonsColumnCrossAlign = CrossAxisAlignment.center;
      case ButtonsPosition.bottom:
        positionNextButton = CustomTargetContentPosition(bottom: edgeSpace + safeBottom);
        buttonsColumnCrossAlign = CrossAxisAlignment.center;
      case ButtonsPosition.left:
        positionNextButton = context == null
            ? CustomTargetContentPosition(left: edgeSpace, top: 100)
            : CustomTargetContentPosition(
                left: edgeSpace,
                top: safeTop + safeHeight / 2 - TIOMusicParams.sizeBigButtons,
              );
        buttonsColumnCrossAlign = CrossAxisAlignment.start;
      case ButtonsPosition.right:
        positionNextButton = context == null
            ? CustomTargetContentPosition(right: edgeSpace, top: 100)
            : CustomTargetContentPosition(
                right: edgeSpace,
                top: safeTop + safeHeight / 2 - TIOMusicParams.sizeBigButtons,
              );
        buttonsColumnCrossAlign = CrossAxisAlignment.end;
      case ButtonsPosition.bottomright:
        positionNextButton = CustomTargetContentPosition(bottom: edgeSpace + safeBottom);
        buttonsColumnCrossAlign = CrossAxisAlignment.end;
      default:
        positionNextButton = CustomTargetContentPosition(bottom: edgeSpace + safeBottom);
        buttonsColumnCrossAlign = CrossAxisAlignment.center;
    }

    var contents = List<TargetContent>.empty(growable: true);
    if (key == null) {
      contents.add(
        TargetContent(
          align: ContentAlign.custom,
          customPosition: CustomTargetContentPosition(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
          ), // this covers the whole screen
          padding: EdgeInsets.zero,
          child: ColoredBox(color: Tutorial.backgroundColor.withValues(alpha: Tutorial.backgroundOpacity)),
        ),
      );
    }
    contents.add(
      TargetContent(
        align: alignText ?? (customTextPosition != null ? ContentAlign.custom : ContentAlign.bottom),
        customPosition: customTextPosition,
        builder: (context, controller) {
          return SafeArea(
            minimum: EdgeInsets.only(left: edgeSpace, right: edgeSpace, top: edgeSpace, bottom: edgeSpace),
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: MessageBorder(
                  pointingDirection: pointingDirection,
                  pointerOffset: pointerOffset,
                  pointerPosition: pointerPosition,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  description,
                  style: const TextStyle(color: ColorTheme.tertiary, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
    contents.add(
      TargetContent(
        align: ContentAlign.custom,
        customPosition: positionNextButton,
        builder: (context, controller) {
          return SafeArea(
            minimum: EdgeInsets.only(bottom: edgeSpace, left: edgeSpace, right: edgeSpace, top: edgeSpace),
            child: Column(
              crossAxisAlignment: buttonsColumnCrossAlign,
              children: [
                // NEXT
                SizedBox(
                  width: 110,
                  child: Center(
                    child: CircleAvatar(
                      backgroundColor: ColorTheme.primary,
                      radius: 50,
                      child: TextButton(
                        onPressed: () => controller.next(),
                        child: Text(
                          context.l10n.commonNext,
                          style: TextStyle(color: ColorTheme.onPrimary, fontSize: 24),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // CANCEL
                SizedBox(
                  width: 110,
                  child: Center(
                    child: TextButton(
                      onPressed: () => controller.skip(),
                      child: Text(
                        context.l10n.commonCancel,
                        style: TextStyle(color: ColorTheme.onPrimary, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    targetFocus = TargetFocus(
      keyTarget: key,
      targetPosition: key == null ? TargetPosition(MediaQuery.sizeOf(context!), Offset.zero) : null,
      enableTargetTab: false,
      shape: shape ?? ShapeLightFocus.Circle,
      contents: contents,
    );
  }
}

enum ButtonsPosition { top, bottom, left, right, bottomright }
