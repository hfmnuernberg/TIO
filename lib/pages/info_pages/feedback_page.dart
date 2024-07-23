import 'package:flutter/material.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';
import 'package:tiomusic/widgets/info_page.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoPage(
      appBarTitle: "Feedback survey",
      textSections: [
        const TextSection(
            content: "Do you like TIO Music? Please take part in this survey!", sectionType: SectionType.headline3),
        const TextSection(content: "(For now the survey is only available in German)"),
        const SizedBox(height: 12),
        Center(
          child: TIOFlatButton(
            text: 'Fill out',
            onPressed: () async {
              // open link in browser
              final Uri url = Uri.parse('https://cloud9.evasys.de/hfmn/online.php?p=Q2TYV');
              if (!await launchUrl(url)) {
                throw Exception('Could not launch $url');
              }
            },
          ),
        ),
      ],
    );
  }
}
