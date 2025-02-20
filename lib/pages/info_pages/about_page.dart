import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tiomusic/util/app_snackbar.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/info_page.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
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
        _isLoading = false;
      });
    } catch (_) {
      showSnackbar(context: context, message: 'Could not load app version.');
      setState(() {
        _isLoading = false;
      });
    }
  }

  _showAppVersion() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_packageInfo == null) return const TextSection(content: 'Could not load app version.');
    return TextSection(content: 'Version ${_packageInfo!.version} (${_packageInfo!.buildNumber})');
  }

  @override
  Widget build(BuildContext context) {
    const double spacing = 12;

    return InfoPage(
      appBarTitle: "About",
      textSections: [
        const TextSection(
          content:
              "TIO Music integrates numerous tools (tuner, metronome, media player, piano, image notes and text notes) in one app and enables the combined use of the individual tools. By creating projects, it is possible to save different configurations and thus make practicing and making music easier. The tools can also be used individually, for quick tuning of instruments or for recording samples. TIO Music was developed by musicians for musicians of all levels of experience, for amateurs and professionals. The app is and will remain completely free of charge and ad-free.",
        ),
        const TextSection(content: "Features", sectionType: SectionType.headline2),
        const TextSection(content: "Projects", sectionType: SectionType.headline3),
        const TextSection(
          content:
              "You can create projects and save the required settings there (settings for instrument tuning, metronome settings, etc.), so you can access them whenever you want.",
        ),
        const TextSection(content: "Tuner", sectionType: SectionType.headline3),
        const TextSection(
          content:
              "You can tune your instruments to any concert pitch, play reference tones, save your individual configuration and combine the tuner with the metronome and media player.",
        ),
        const TextSection(content: "Metronome", sectionType: SectionType.headline3),
        const TextSection(
          content:
              "The metronome allows you to save and recall your individual configurations (tempo, time signature, polyrhythms, random mute, sounds). You can also combine the metronome with the tuner and the media player.",
        ),
        const TextSection(content: "Media player", sectionType: SectionType.headline3),
        const TextSection(
          content:
              "You can record, load and edit audio files and save configurations. In doing so, you can set your preferred volume, range (length and segment), playing speed and pitch. You can forward your projects to others using external messenger services.",
        ),
        const TextSection(content: "Piano", sectionType: SectionType.headline3),
        const TextSection(
          content:
              "You can use the built-in piano, select different sound modes and save your individual configurations.",
        ),
        const TextSection(content: "Image", sectionType: SectionType.headline3),
        const TextSection(
          content: "You can upload pictures or note sheets to the app using the camera on your device.",
        ),
        const TextSection(content: "Text", sectionType: SectionType.headline3),
        const TextSection(
          content:
              "You can use your device to create text notes, e.g. for playing instructions, background information, song lyrics etc.",
        ),
        const SizedBox(height: spacing),
        const TextSection(
          content: "We aim to continuously improve the app for you - so we look forward to your feedback!",
        ),
        const SizedBox(height: spacing),
        const TextSection(
          content:
              "This app was developed as part of the RE|LEVEL-project at Hochschule für Musik Nürnberg. RE|LEVEL is funded by Stiftung Innovation in der Hochschullehre.",
        ),
        const TextSection(content: "Imprint", sectionType: SectionType.headline2),
        const TextSection(
          content: "Editor: University of Music Nuremberg",
          sectionType: SectionType.text,
        ),
        InkWell(
          child: const Text('https://www.hfm-nuernberg.de/', style: TextStyle(color: ColorTheme.tertiary)),
          onTap: () async {
            final Uri url = Uri.parse('https://www.hfm-nuernberg.de/');
            await launchUrl(url);
          },
        ),
        const SizedBox(height: spacing),
        const TextSection(content: "Developer: Studio Fluffy", sectionType: SectionType.text),
        InkWell(
          child: const Text('https://studiofluffy.de/', style: TextStyle(color: ColorTheme.tertiary)),
          onTap: () async {
            final Uri url = Uri.parse('https://studiofluffy.de/');
            await launchUrl(url);
          },
        ),
        const TextSection(content: "Data protection", sectionType: SectionType.headline2),
        const TextSection(
          content:
              "We do not collect any of your data. Please note that your projects are only saved locally on your device, i.e. they are not saved in the app or in any cloud service or similar. If you decide to share individual content from within the app, this is possible via third-party services such as messenger etc. In such cases, only the data protection regulations of the third-party services used apply. You yourself are responsible for complying with applicable data protection or copyright regulations.",
        ),
        const TextSection(content: "App Version", sectionType: SectionType.headline2),
        _showAppVersion(),
      ],
    );
  }
}
