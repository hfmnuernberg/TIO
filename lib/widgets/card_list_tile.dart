import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';

class CardListTile extends StatelessWidget {
  final String title;
  final String? subtitle;

  // those three should be of the same type (IconButton or Icon), otherwise the spacing is problematic
  final IconButton trailingIcon;
  final IconButton? menuIconOne;
  final IconButton? menuIconTwo;

  final dynamic leadingPicture;
  final Function onTapFunction;

  final Color? highlightColor;

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
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: highlightColor ?? ColorTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
      ),
      margin: const EdgeInsets.fromLTRB(TIOMusicParams.edgeInset, 0, TIOMusicParams.edgeInset, 8),
      elevation: 0.0,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(color: ColorTheme.surfaceTint, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle ?? "",
          style: const TextStyle(color: ColorTheme.surfaceTint),
        ),
        leading: _showPicture(leadingPicture),
        titleAlignment: ListTileTitleAlignment.titleHeight,
        trailing: Wrap(
          spacing: 2, // space between two icons
          children: <Widget>[
            menuIconTwo ?? const SizedBox(),
            menuIconOne ?? const SizedBox(),
            trailingIcon,
          ],
        ),
        onTap: () {
          onTapFunction();
        },
      ),
    );
  }

  Widget _showPicture(dynamic picture) {
    if (picture is ImageProvider) {
      // if picture is an image provider
      return AspectRatio(
        aspectRatio: 1,
        child: Image(
          image: picture,
          fit: BoxFit.cover,
        ),
      );
    } else if (picture is String) {
      // if picture is a string to an svg file
      return CircleAvatar(
        backgroundColor: ColorTheme.surface,
        child: SvgPicture.asset(
          picture,
          colorFilter: const ColorFilter.mode(ColorTheme.primary, BlendMode.srcIn),
        ),
      );
    } else {
      // if picture is an icon or icon button
      return CircleAvatar(
        child: picture,
        backgroundColor: ColorTheme.surface,
      );
    }
  }
}
