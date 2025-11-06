import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/info_dialog.dart';

Future<bool?> askForOverridingFileOnRecordingStart(BuildContext context) => showDialog<bool>(
  context: context,
  builder: (context) {
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.mediaPlayerOverwriteSound, style: const TextStyle(color: ColorTheme.primary)),
      content: Text(l10n.mediaPlayerOverwriteWithRecordingQuestion, style: const TextStyle(color: ColorTheme.primary)),
      actions: [
        TextButton(child: Text(l10n.commonNo), onPressed: () => Navigator.of(context).pop(false)),
        TextButton(
          child: Text(l10n.commonYes, style: const TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  },
);

Future<bool?> askForOverridingFileOnOpenFileSelection(BuildContext context) => showDialog<bool>(
  context: context,
  builder: (context) {
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.mediaPlayerOverwriteSound, style: const TextStyle(color: ColorTheme.primary)),
      content: Text(l10n.mediaPlayerOverwriteWithAudioQuestion, style: const TextStyle(color: ColorTheme.primary)),
      actions: [
        TextButton(child: Text(l10n.commonNo), onPressed: () => Navigator.of(context).pop(false)),
        TextButton(
          child: Text(l10n.commonYes, style: const TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  },
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
