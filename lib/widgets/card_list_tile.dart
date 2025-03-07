import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';

class CardListTile extends StatelessWidget {
  final String title;
  final String? subtitle;

  // those three should be of the same type (IconButton or Icon), otherwise the spacing is problematic
  final IconButton trailingIcon;
  final String? trailingLabel;
  final IconButton? menuIconOne;
  final String? menuLabelOne;
  final IconButton? menuIconTwo;
  final String? menuLabelTwo;

  final dynamic leadingPicture;
  final GestureTapCallback onTapFunction;
  final bool disableTap;

  final Color? highlightColor;

  final Color textColor;
  final Color leadingIconColor;

  const CardListTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.trailingIcon,
    this.trailingLabel,
    this.menuIconOne,
    this.menuLabelOne,
    this.menuIconTwo,
    this.menuLabelTwo,
    required this.leadingPicture,
    required this.onTapFunction,
    this.highlightColor,
    this.disableTap = false,
    this.textColor = ColorTheme.surfaceTint,
    this.leadingIconColor = ColorTheme.surfaceTint,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: title,
      child: Card(
        color: highlightColor ?? ColorTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        margin: const EdgeInsets.fromLTRB(TIOMusicParams.edgeInset, 0, TIOMusicParams.edgeInset, 8),
        elevation: 0,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: ListTile(
          enabled: !disableTap,
          title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
          subtitle: Text(subtitle ?? '', style: TextStyle(color: textColor)),
          leading: _showPicture(leadingPicture),
          titleAlignment: ListTileTitleAlignment.titleHeight,
          trailing: Wrap(
            spacing: 2, // space between two icons
            children: <Widget>[
              if (menuIconTwo == null)
                const SizedBox()
              else if (menuLabelTwo == null)
                menuIconTwo!
              else
                Semantics(container: true, label: menuLabelTwo, child: menuIconTwo),

              if (menuIconOne == null)
                const SizedBox()
              else if (menuLabelOne == null)
                menuIconOne!
              else
                Semantics(container: true, label: menuLabelOne, child: menuIconOne),

              Semantics(container: true, label: trailingLabel ?? 'Details', child: trailingIcon),
            ],
          ),
          onTap: onTapFunction,
        ),
      ),
    );
  }

  Widget _showPicture(picture) {
    if (picture is ImageProvider) {
      // if picture is an image provider
      return AspectRatio(aspectRatio: 1, child: Image(image: picture, fit: BoxFit.cover));
    } else if (picture is String) {
      // if picture is a string to an svg file
      return CircleAvatar(
        backgroundColor: ColorTheme.surface,
        child: SvgPicture.asset(picture, colorFilter: ColorFilter.mode(leadingIconColor, BlendMode.srcIn)),
      );
    } else {
      // if picture is an icon or icon button
      return CircleAvatar(child: picture, backgroundColor: ColorTheme.surface);
    }
  }
}
