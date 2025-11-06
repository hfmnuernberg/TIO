import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';

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

Future<void> showMissingMicrophonePermissionDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) {
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.mediaPlayerErrorMissingPermission, style: TextStyle(color: ColorTheme.primary)),
      content: Text(l10n.mediaPlayerErrorMissingMicPermissionDescription, style: const TextStyle(color: ColorTheme.primary)),
      actions: [TextButton(child: Text(l10n.commonGotIt), onPressed: () => Navigator.pop(context))],
    );
  },
);

Future<void> showFormatNotSupportedDialog(BuildContext context, String? format) => showDialog<void>(
  context: context,
  builder: (context) {
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.mediaPlayerErrorFileFormat, style: TextStyle(color: ColorTheme.primary)),
      content: Text(
        l10n.mediaPlayerErrorFileFormatDescription(format ?? ''),
        style: const TextStyle(color: ColorTheme.primary),
      ),
      actions: [TextButton(child: Text(l10n.commonGotIt), onPressed: () => Navigator.pop(context))],
    );
  },
);

Future<void> showFileOpenFailedDialog(BuildContext context, {String? fileName}) {
  final l10n = context.l10n;
  fileName = (fileName ?? '').isEmpty ? null : fileName;

  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.mediaPlayerErrorFileOpen, style: TextStyle(color: ColorTheme.primary)),
      content: Column(
        children: [
          Text(l10n.mediaPlayerErrorFileOpenDescription, style: const TextStyle(color: ColorTheme.primary)),
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
      actions: [TextButton(child: Text(l10n.commonGotIt), onPressed: () => Navigator.pop(context))],
    ),
  );
}
