import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class SurveyBanner extends StatelessWidget {
  final VoidCallback onClose;

  const SurveyBanner({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Positioned(
      left: 0,
      top: 0,
      width: MediaQuery.of(context).size.width,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        elevation: 8,
        margin: const EdgeInsets.all(TIOMusicParams.edgeInset),
        color: ColorTheme.onPrimary,
        surfaceTintColor: ColorTheme.onPrimary,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.feedbackQuestion, style: TextStyle(color: ColorTheme.surfaceTint)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () async {
                      final Uri url = Uri.parse('https://cloud9.evasys.de/hfmn/online.php?p=Q2TYV');
                      if (await launchUrl(url) && context.mounted) {
                        context.read<ProjectLibrary>().neverShowSurveyAgain = true;
                        await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
                        onClose();
                      }
                    },
                    child: Text(l10n.feedbackCta),
                  ),
                  IconButton(
                    onPressed: () async {
                      final projectLibrary = context.read<ProjectLibrary>();
                      projectLibrary.idxCheckShowSurvey++;
                      if (projectLibrary.idxCheckShowSurvey >= projectLibrary.showSurveyAtVisits.length) {
                        projectLibrary.neverShowSurveyAgain = true;
                      }
                      await context.read<ProjectRepository>().saveLibrary(projectLibrary);
                      onClose();
                    },
                    icon: const Icon(Icons.close, color: ColorTheme.surfaceTint),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
