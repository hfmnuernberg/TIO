import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class Walkthrough {
  TutorialCoachMark? _tutorialCoachMark;

  Walkthrough();

  static const backgroundColor = ColorTheme.primary50;
  static const backgroundOpacity = 0.8;

  void show(BuildContext context) {
    // showing walkthrough delayed to avoid misplaced tooltips when new page is animated in from the side
    Future.delayed(const Duration(milliseconds: 400), () {
      _tutorialCoachMark?.show(context: context);
    });
  }

  // onSkip will cancel all walkthroughs
  void create(List<TargetFocus> targets, Function() onFinish, BuildContext context) {
    _tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: backgroundColor,
      hideSkip: true,
      paddingFocus: 10,
      opacityShadow: backgroundOpacity,
      pulseEnable: false,
      onFinish: () {
        onFinish();
      },
      onSkip: () {
        context.read<ProjectLibrary>().dismissAllTutorials();
        FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
        return true;
      },
    );
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
    var edgeSpace = 8.0;
    CustomTargetContentPosition positionNextButton;
    CrossAxisAlignment buttonsColumnCrossAlign = CrossAxisAlignment.center;

    switch (buttonsPosition) {
      case ButtonsPosition.top:
        positionNextButton = CustomTargetContentPosition(top: edgeSpace);
        break;
      case ButtonsPosition.bottom:
        positionNextButton = CustomTargetContentPosition(bottom: edgeSpace);
        break;
      case ButtonsPosition.left:
        positionNextButton = context == null
            ? CustomTargetContentPosition(left: edgeSpace, top: 100)
            : CustomTargetContentPosition(
                left: edgeSpace, top: MediaQuery.of(context).size.height / 2 - TIOMusicParams.sizeBigButtons);
        buttonsColumnCrossAlign = CrossAxisAlignment.start;
        break;
      case ButtonsPosition.right:
        positionNextButton = context == null
            ? CustomTargetContentPosition(right: edgeSpace, top: 100)
            : CustomTargetContentPosition(
                right: edgeSpace, top: MediaQuery.of(context).size.height / 2 - TIOMusicParams.sizeBigButtons);
        buttonsColumnCrossAlign = CrossAxisAlignment.end;
        break;
      case ButtonsPosition.bottomright:
        positionNextButton = CustomTargetContentPosition(bottom: edgeSpace);
        buttonsColumnCrossAlign = CrossAxisAlignment.end;
      default:
        positionNextButton = CustomTargetContentPosition(bottom: edgeSpace);
    }

    var contents = List<TargetContent>.empty(growable: true);
    if (key == null) {
      contents.add(TargetContent(
          align: ContentAlign.custom,
          customPosition:
              CustomTargetContentPosition(left: 0, right: 0, top: 0, bottom: 0), // this covers the whole screen
          padding: EdgeInsets.zero,
          child: ColoredBox(
            color: Walkthrough.backgroundColor.withOpacity(Walkthrough.backgroundOpacity),
          )));
    }
    contents.add(TargetContent(
      align: alignText ?? (customTextPosition != null ? ContentAlign.custom : ContentAlign.bottom),
      customPosition: customTextPosition,
      builder: (context, controller) {
        return Container(
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
              style: const TextStyle(
                color: ColorTheme.tertiary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    ));
    contents.add(TargetContent(
      align: ContentAlign.custom,
      customPosition: positionNextButton,
      builder: (context, controller) {
        return Column(
          crossAxisAlignment: buttonsColumnCrossAlign,
          children: [
            // NEXT
            CircleAvatar(
              backgroundColor: ColorTheme.primary,
              radius: TIOMusicParams.sizeBigButtons,
              child: TextButton(
                onPressed: () {
                  controller.next();
                },
                child: const Text("Next", style: TextStyle(color: ColorTheme.onPrimary, fontSize: 24)),
              ),
            ),
            const SizedBox(height: 10),
            // CANCEL
            TextButton(
              onPressed: () {
                controller.skip();
              },
              child: const Text("Cancel", style: TextStyle(color: ColorTheme.onPrimary, fontSize: 16)),
            ),
          ],
        );
      },
    ));

    targetFocus = TargetFocus(
      keyTarget: key,
      targetPosition: key == null ? TargetPosition(MediaQuery.sizeOf(context!), Offset.zero) : null,
      enableOverlayTab: false,
      enableTargetTab: false,
      shape: shape ?? ShapeLightFocus.Circle,
      contents: contents,
    );
  }
}

enum ButtonsPosition { top, bottom, left, right, bottomright }