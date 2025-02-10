import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';

class ConfirmButton extends StatelessWidget {
  final Function() onTap;

  const ConfirmButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(TIOMusicParams.edgeInset),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: TIOMusicParams.sizeBigButtons,
        child: IconButton(
          onPressed: onTap,
          iconSize: TIOMusicParams.sizeBigButtons,
          icon: const Icon(Icons.check, color: ColorTheme.tertiary),
        ),
      ),
    );
  }
}

class CancelButton extends StatelessWidget {
  final Function() onTap;

  const CancelButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(TIOMusicParams.edgeInset),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: TIOMusicParams.sizeSmallButtons,
        child: IconButton(
          onPressed: onTap,
          iconSize: TIOMusicParams.sizeSmallButtons,
          icon: const Icon(Icons.close, color: ColorTheme.primary),
        ),
      ),
    );
  }
}

class TIOTextButton extends StatelessWidget {
  final String text;
  final Icon? icon;
  final Color? backgroundColor;
  final Function() onTap;

  const TIOTextButton({
    super.key,
    required this.text,
    required this.onTap,
    this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    var elevation = 0.0;

    var style = ElevatedButton.styleFrom(
      elevation: elevation,
      backgroundColor: backgroundColor ?? ColorTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MetronomeParams.t2tCornerRadius)),
      padding: const EdgeInsets.all(MetronomeParams.t2tButtonPadding),
    );

    return icon == null
        ? ElevatedButton(
            onPressed: onTap,
            style: style,
            child: Text(text),
          )
        : ElevatedButton.icon(
            onPressed: onTap,
            style: style,
            icon: icon!,
            label: Text(text),
          );
  }
}

class TIOFlatButton extends StatelessWidget {
  final String? text;
  final Icon? icon;
  final Function()? onPressed;
  final bool boldText;
  final ButtonStyle? customStyle;

  const TIOFlatButton({
    super.key,
    this.text,
    this.icon,
    required this.onPressed,
    this.boldText = false,
    this.customStyle,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = const SizedBox();
    if (text != null) {
      child = Text(text!, style: TextStyle(fontWeight: boldText ? FontWeight.bold : FontWeight.normal));
    } else if (icon != null) {
      child = icon!;
    }

    return ElevatedButton(
      style: customStyle ?? ElevatedButton.styleFrom(elevation: 0, backgroundColor: ColorTheme.surface),
      onPressed: onPressed,
      child: child,
    );
  }
}
