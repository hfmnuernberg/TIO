import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';
import 'package:tiomusic/widgets/info_page.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return InfoPage(
      appBarTitle: l10n.feedbackTitle,
      textSections: [
        TextSection(content: l10n.feedbackQuestion, sectionType: SectionType.headline3),
        const SizedBox(height: 12),
        Center(
          child: TIOFlatButton(
            text: l10n.feedbackCta,
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
