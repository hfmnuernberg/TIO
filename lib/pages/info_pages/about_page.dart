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

  Widget _showAppVersion() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_packageInfo == null) return TextSection(content: context.l10n.appAboutVersionError);
    return TextSection(content: '${_packageInfo!.version} (${_packageInfo!.buildNumber})');
  }

  @override
  Widget build(BuildContext context) {
    const double spacing = 12;
    final l10n = context.l10n;

    return InfoPage(
      appBarTitle: l10n.appAboutTitle,
      textSections: [
        TextSection(content: l10n.appAboutParagraphOne),
        TextSection(content: l10n.appAboutFeatures, sectionType: SectionType.headline2),
        TextSection(content: l10n.projectsAbout, sectionType: SectionType.headline3),
        TextSection(content: l10n.projectsAboutExplanation),
        TextSection(content: l10n.tunerAbout, sectionType: SectionType.headline3),
        TextSection(content: l10n.tunerAboutExplanation),
        TextSection(content: l10n.metronomeAbout, sectionType: SectionType.headline3),
        TextSection(content: l10n.metronomeAboutExplanation),
        TextSection(content: l10n.mediaPlayerAbout, sectionType: SectionType.headline3),
        TextSection(content: l10n.mediaPlayerAboutExplanation),
        TextSection(content: l10n.pianoAbout, sectionType: SectionType.headline3),
        TextSection(content: l10n.pianoAboutExplanation),
        TextSection(content: l10n.imageAbout, sectionType: SectionType.headline3),
        TextSection(content: l10n.imageAboutExplanation),
        TextSection(content: l10n.textAbout, sectionType: SectionType.headline3),
        TextSection(content: l10n.textAboutExplanation),
        const SizedBox(height: spacing),
        TextSection(content: l10n.appAboutParagraphTwo),
        const SizedBox(height: spacing),
        TextSection(content: l10n.appAboutParagraphThree),
        TextSection(content: l10n.appAboutImprint, sectionType: SectionType.headline2),
        TextSection(content: l10n.appAboutEditor, sectionType: SectionType.text),
        InkWell(
          child: const Text('https://www.hfm-nuernberg.de/', style: TextStyle(color: ColorTheme.tertiary)),
          onTap: () async {
            final Uri url = Uri.parse('https://www.hfm-nuernberg.de/');
            await launchUrl(url);
          },
        ),
        const SizedBox(height: spacing),
        TextSection(content: l10n.appAboutDeveloperOne, sectionType: SectionType.text),
        InkWell(
          child: const Text('https://cultivate.software/', style: TextStyle(color: ColorTheme.tertiary)),
          onTap: () async {
            final Uri url = Uri.parse('https://cultivate.software/');
            await launchUrl(url);
          },
        ),
        const SizedBox(height: spacing),
        TextSection(content: l10n.appAboutDeveloperTwo, sectionType: SectionType.text),
        InkWell(
          child: const Text('https://studiofluffy.de/', style: TextStyle(color: ColorTheme.tertiary)),
          onTap: () async {
            final Uri url = Uri.parse('https://studiofluffy.de/');
            await launchUrl(url);
          },
        ),
        TextSection(content: l10n.appAboutDataProtection, sectionType: SectionType.headline2),
        TextSection(content: l10n.appAboutDataProtectionExplanation),
        TextSection(content: l10n.appAboutVersion, sectionType: SectionType.headline2),
        _showAppVersion(),
      ],
    );
  }
}
