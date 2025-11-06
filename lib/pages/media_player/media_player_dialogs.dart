import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/confirm_dialog.dart';
import 'package:tiomusic/widgets/info_dialog.dart';

Future<bool?> askForOverridingFileOnRecordingStart(BuildContext context) => showConfirmDialog(
  context: context,
  title: context.l10n.mediaPlayerOverwriteSound,
  content: context.l10n.mediaPlayerOverwriteWithRecordingQuestion,
);

Future<bool?> askForOverridingFileOnOpenFileSelection(BuildContext context) => showConfirmDialog(
  context: context,
  title: context.l10n.mediaPlayerOverwriteSound,
  content: context.l10n.mediaPlayerOverwriteWithAudioQuestion,
);

Future<void> showTooManyFilesSelectedDialog(BuildContext context) => showInfoDialog(
  context: context,
  title: context.l10n.mediaPlayerTooManyFilesTitle,
  content: Text(context.l10n.mediaPlayerTooManyFilesDescription, style: const TextStyle(color: ColorTheme.primary)),
);

Future<void> showMissingMicrophonePermissionDialog(BuildContext context) => showInfoDialog(
  context: context,
  title: context.l10n.mediaPlayerErrorMissingPermission,
  content: Text(
    context.l10n.mediaPlayerErrorMissingMicPermissionDescription,
    style: const TextStyle(color: ColorTheme.primary),
  ),
);

Future<void> showFormatNotSupportedDialog(BuildContext context, String? format) => showInfoDialog(
  context: context,
  title: context.l10n.mediaPlayerErrorFileFormat,
  content: Text(
    context.l10n.mediaPlayerErrorFileFormatDescription(format ?? ''),
    style: const TextStyle(color: ColorTheme.primary),
  ),
);

Future<void> showFileOpenFailedDialog(BuildContext context, {String? fileName}) {
  fileName = (fileName ?? '').isEmpty ? null : fileName;

  return showInfoDialog(
    context: context,
    title: context.l10n.mediaPlayerErrorFileOpen,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.l10n.mediaPlayerErrorFileOpenDescription, style: const TextStyle(color: ColorTheme.primary)),
        if (fileName != null)
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: Text(
              '${context.l10n.mediaPlayerFile}: ${basename(fileName)}',
              style: const TextStyle(color: ColorTheme.primary),
            ),
          ),
      ],
    ),
  );
}
