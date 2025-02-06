// A start/stop button with changing play/pause symbol

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';

class OnOffButton extends StatefulWidget {
  final bool isActive;
  final Function() onTap;
  final double buttonSize;
  final dynamic iconOff;
  final dynamic iconOn;
  final bool isDisabled;

  const OnOffButton({
    super.key,
    required this.isActive,
    required this.onTap,
    required this.iconOff,
    required this.iconOn,
    this.buttonSize = 70,
    this.isDisabled = false,
  });

  @override
  State<OnOffButton> createState() => _OnOffButtonState();
}

class _OnOffButtonState extends State<OnOffButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(TIOMusicParams.paddingOnOffButtons, 0, TIOMusicParams.paddingOnOffButtons, 0),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Visibility(
          visible: !widget.isDisabled,
          maintainAnimation: true,
          maintainSize: true,
          maintainState: true,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: widget.buttonSize,
            child: IconButton(
              onPressed: widget.isDisabled
                  ? null
                  : () {
                      widget.onTap();
                    },
              iconSize: widget.buttonSize,
              icon: widget.isActive ? _getIconOn() : _getIconOff(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getIconOn() {
    if (widget.iconOn is IconData) {
      return Icon(
        widget.iconOn,
        color: ColorTheme.tertiary,
      );
    } else if (widget.iconOn is SvgPicture) {
      return SvgPicture.asset(
        widget.iconOn,
        height: widget.buttonSize,
        width: widget.buttonSize,
        colorFilter: const ColorFilter.mode(ColorTheme.tertiary, BlendMode.srcIn),
      );
    } else {
      return const Icon(Icons.abc);
    }
  }

  Widget _getIconOff() {
    if (widget.iconOff is IconData) {
      return Icon(
        widget.iconOff,
        color: ColorTheme.tertiary,
      );
    } else if (widget.iconOff is String) {
      return SvgPicture.asset(
        widget.iconOff,
        height: widget.buttonSize,
        width: widget.buttonSize,
        colorFilter: const ColorFilter.mode(ColorTheme.tertiary, BlendMode.srcIn),
      );
    } else {
      return const Icon(Icons.abc);
    }
  }
}

class PlaceholderButton extends StatelessWidget {
  final double buttonSize;

  const PlaceholderButton({super.key, required this.buttonSize});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(TIOMusicParams.paddingOnOffButtons, 0, TIOMusicParams.paddingOnOffButtons, 0),
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: buttonSize,
      ),
    );
  }
}
