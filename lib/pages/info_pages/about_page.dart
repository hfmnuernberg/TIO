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
    if (_packageInfo == null) return TextSection(content: context.l10n.aboutAppVersionError);
    return TextSection(content: '${_packageInfo!.version} (${_packageInfo!.buildNumber})');
  }

  @override
  Widget build(BuildContext context) {
    const double spacing = 12;
    final l10n = context.l10n;

    return InfoPage(
      appBarTitle: l10n.aboutTitle,
      textSections: [
        TextSection(content: l10n.aboutFirstParagraph),
        TextSection(content: l10n.aboutFeatures, sectionType: SectionType.headline2),
        TextSection(content: l10n.aboutProjects, sectionType: SectionType.headline3),
        TextSection(content: l10n.aboutProjectsExplanation),
        TextSection(content: l10n.aboutTuner, sectionType: SectionType.headline3),
        TextSection(content: l10n.aboutTunerExplanation),
        TextSection(content: l10n.aboutMetronome, sectionType: SectionType.headline3),
        TextSection(content: l10n.aboutMetronomeExplanation),
        TextSection(content: l10n.aboutMediaPlayer, sectionType: SectionType.headline3),
        TextSection(content: l10n.aboutMediaPlayerExplanation),
        TextSection(content: l10n.aboutPiano, sectionType: SectionType.headline3),
        TextSection(content: l10n.aboutPianoExplanation),
        TextSection(content: l10n.aboutImage, sectionType: SectionType.headline3),
        TextSection(content: l10n.aboutImageExplanation),
        TextSection(content: l10n.aboutText, sectionType: SectionType.headline3),
        TextSection(content: l10n.aboutTextExplanation),
        const SizedBox(height: spacing),
        TextSection(content: l10n.aboutSecondParagraph),
        const SizedBox(height: spacing),
        TextSection(content: l10n.aboutThirdParagraph),
        TextSection(content: l10n.aboutImprint, sectionType: SectionType.headline2),
        TextSection(content: l10n.aboutEditor, sectionType: SectionType.text),
        InkWell(
          child: const Text('https://www.hfm-nuernberg.de/', style: TextStyle(color: ColorTheme.tertiary)),
          onTap: () async {
            final Uri url = Uri.parse('https://www.hfm-nuernberg.de/');
            await launchUrl(url);
          },
        ),
        const SizedBox(height: spacing),
        TextSection(content: l10n.aboutDeveloper, sectionType: SectionType.text),
        InkWell(
          child: const Text('https://studiofluffy.de/', style: TextStyle(color: ColorTheme.tertiary)),
          onTap: () async {
            final Uri url = Uri.parse('https://studiofluffy.de/');
            await launchUrl(url);
          },
        ),
        TextSection(content: l10n.aboutDataProtection, sectionType: SectionType.headline2),
        TextSection(content: l10n.aboutDataProtectionExplanation),
        TextSection(content: l10n.aboutAppVersion, sectionType: SectionType.headline2),
        _showAppVersion(),
      ],
    );
  }
}
