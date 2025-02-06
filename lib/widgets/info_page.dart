import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';

class InfoPage extends StatelessWidget {
  final String appBarTitle;
  final List<Widget> textSections;

  const InfoPage({
    required this.appBarTitle, required this.textSections, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: ColorTheme.surfaceBright,
        foregroundColor: ColorTheme.primary,
      ),
      backgroundColor: ColorTheme.primary92,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: textSections,
          ),
        ),
      ),
    );
  }
}

enum SectionType { headline1, headline2, headline3, text }

class TextSection extends StatelessWidget {
  final String content;
  final SectionType? sectionType;

  const TextSection({required this.content, super.key, this.sectionType});

  @override
  Widget build(BuildContext context) {
    double fontSize = 14;
    double topSpacing = 2;
    double bottomSpacing = 2;

    if (sectionType == SectionType.headline1) {
      fontSize = 32;
      topSpacing = 16;
    } else if (sectionType == SectionType.headline2) {
      fontSize = 24;
      topSpacing = 16;
    } else if (sectionType == SectionType.headline3) {
      fontSize = 18;
      topSpacing = 8;
    }

    return Padding(
      padding: EdgeInsets.only(top: topSpacing, bottom: bottomSpacing),
      child: Text(
        content,
        style: TextStyle(
          color: ColorTheme.surfaceTint,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
