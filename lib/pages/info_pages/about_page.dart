import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/info_page.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  PackageInfo? _packageInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        _packageInfo = info;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _showAppVersion() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_packageInfo == null) return TextSection(content: context.l10n.aboutPageAppVersionError);
    return TextSection(content: '${_packageInfo!.version} (${_packageInfo!.buildNumber})');
  }

  @override
  Widget build(BuildContext context) {
    const double spacing = 12;
    final l10n = context.l10n;

    return InfoPage(
      appBarTitle: l10n.aboutPageTitle,
      textSections: [
        TextSection(
          content: l10n.aboutPageFirstParagraph,
        ),
        TextSection(content: l10n.aboutPageFeatures, sectionType: SectionType.headline2),
        TextSection(content: l10n.aboutPageProjects, sectionType: SectionType.headline3),
        TextSection(
          content:
          l10n.aboutPageProjectsExplanation,
        ),
        TextSection(content: l10n.aboutPageTuner, sectionType: SectionType.headline3),
        TextSection(
          content:
              l10n.aboutPageTunerExplanation,
        ),
        TextSection(content: l10n.aboutPageMetronome, sectionType: SectionType.headline3),
        TextSection(
          content:
          l10n.aboutPageMetronomeExplanation,
        ),
        TextSection(content: l10n.aboutPageMediaPlayer, sectionType: SectionType.headline3),
        TextSection(
          content:
          l10n.aboutPageMediaPlayerExplanation,
        ),
        TextSection(content: l10n.aboutPagePiano, sectionType: SectionType.headline3),
        TextSection(
          content:
          l10n.aboutPagePianoExplanation,
        ),
        TextSection(content: l10n.aboutPageImage, sectionType: SectionType.headline3),
        TextSection(
          content: l10n.aboutPageImageExplanation,
        ),
        TextSection(content: l10n.aboutPageText, sectionType: SectionType.headline3),
        TextSection(
          content:
          l10n.aboutPageTextExplanation,
        ),
        const SizedBox(height: spacing),
        TextSection(
          content: l10n.aboutPageSecondParagraph,
        ),
        const SizedBox(height: spacing),
        TextSection(
          content:
              l10n.aboutPageThirdParagraph,
        ),
        TextSection(content: l10n.aboutPageImprint, sectionType: SectionType.headline2),
        TextSection(content: l10n.aboutPageEditor, sectionType: SectionType.text),
        InkWell(
          child: const Text('https://www.hfm-nuernberg.de/', style: TextStyle(color: ColorTheme.tertiary)),
          onTap: () async {
            final Uri url = Uri.parse('https://www.hfm-nuernberg.de/');
            await launchUrl(url);
          },
        ),
        const SizedBox(height: spacing),
        TextSection(content: l10n.aboutPageDeveloper, sectionType: SectionType.text),
        InkWell(
          child: const Text('https://studiofluffy.de/', style: TextStyle(color: ColorTheme.tertiary)),
          onTap: () async {
            final Uri url = Uri.parse('https://studiofluffy.de/');
            await launchUrl(url);
          },
        ),
        TextSection(content: l10n.aboutPageDataProtection, sectionType: SectionType.headline2),
        TextSection(
          content:
          l10n.aboutPageDataProtectionExplanation,
        ),
        TextSection(content: l10n.aboutPageAppVersion, sectionType: SectionType.headline2),
        _showAppVersion(),
      ],
    );
  }
}
