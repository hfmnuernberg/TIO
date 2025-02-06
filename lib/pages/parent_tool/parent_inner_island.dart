import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';

class ParentInnerIsland extends StatefulWidget {
  final Function onMainIconPressed;
  final dynamic mainIcon;
  final String parameterText;
  final dynamic centerView; // this can be any widget or a CustomPainter
  final GlobalKey? customPaintKey;
  final double textSpaceWidth;
  final bool mainButtonIsDisabled;

  const ParentInnerIsland({
    super.key,
    required this.onMainIconPressed,
    required this.mainIcon,
    required this.parameterText,
    required this.textSpaceWidth,
    this.centerView,
    this.customPaintKey,
    this.mainButtonIsDisabled = false,
  });

  @override
  State<ParentInnerIsland> createState() => _ParentInnerIslandState();
}

class _ParentInnerIslandState extends State<ParentInnerIsland> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Visibility(
              visible: !widget.mainButtonIsDisabled,
              maintainAnimation: true,
              maintainSize: true,
              maintainState: true,
              child: CircleAvatar(
                child: IconButton(
                  onPressed: () => widget.onMainIconPressed(),
                  icon: widget.mainIcon,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
              child: widget.centerView is CustomPainter
                  ? CustomPaint(
                      key: widget.customPaintKey,
                      painter: widget.centerView,
                      size: Size.infinite,
                    )
                  : widget.centerView,
            ),
          ),
          SizedBox(
            width: widget.textSpaceWidth,
            child: Text(widget.parameterText, style: const TextStyle(color: ColorTheme.primary)),
          ),
        ],
      ),
    );
  }
}
