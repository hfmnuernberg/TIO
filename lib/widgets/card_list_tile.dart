import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';

class CardListTile extends StatelessWidget {
  final String title;
  final Object? subtitle;

  // those three should be of the same type (IconButton or Icon), otherwise the spacing is problematic
  final IconButton trailingIcon;
  final IconButton? menuIconOne;
  final IconButton? menuIconTwo;

  final Object leadingPicture;
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
    this.menuIconOne,
    this.menuIconTwo,
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
          title: Semantics(
            excludeSemantics: true,
            child: Text(
              title,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
          ),
          subtitle: _CardListTileSubtitle(subtitle: subtitle, textColor: textColor),
          leading: _showPicture(leadingPicture),
          titleAlignment: ListTileTitleAlignment.titleHeight,
          trailing: Wrap(
            spacing: 2, // space between two icons
            children: <Widget>[menuIconTwo ?? const SizedBox(), menuIconOne ?? const SizedBox(), trailingIcon],
          ),
          onTap: onTapFunction,
        ),
      ),
    );
  }

  Widget _showPicture(Object picture) {
    if (picture is ImageProvider) {
      return AspectRatio(
        aspectRatio: 1,
        child: Image(image: picture, fit: BoxFit.cover),
      );
    } else if (picture is String) {
      return CircleAvatar(
        backgroundColor: ColorTheme.surface,
        child: SvgPicture.asset(picture, colorFilter: ColorFilter.mode(leadingIconColor, BlendMode.srcIn)),
      );
    } else {
      return CircleAvatar(backgroundColor: ColorTheme.surface, child: picture as Widget?);
    }
  }
}

class _CardListTileSubtitle extends StatelessWidget {
  final Object? subtitle;
  final Color textColor;

  const _CardListTileSubtitle({required this.subtitle, required this.textColor});

  @override
  Widget build(BuildContext context) {
    switch (subtitle) {
      case final String text:
        return Text(text, style: TextStyle(color: textColor));
      case ImageProvider image:
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 56,
              height: 56,
              child: Image(image: image, fit: BoxFit.cover),
            ),
          ),
        );
      default:
        return Text('', style: TextStyle(color: textColor));
    }
  }
}
