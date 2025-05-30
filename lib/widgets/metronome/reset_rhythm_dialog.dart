import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

Future<bool> showResetRhythmDialog({required BuildContext context}) async {
  final bool? result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return ResetRhythmDialog(onDone: (res) => Navigator.of(context).pop(res));
    },
  );

  return result ?? false;
}

class ResetRhythmDialog extends StatelessWidget {
  final Function onDone;

  const ResetRhythmDialog({super.key, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.metronomeResetRhythmDialogTitle, style: TextStyle(color: ColorTheme.primary)),
      content: Transform.translate(
        offset: const Offset(0, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.metronomeResetRhythmDialogHint, style: TextStyle(color: ColorTheme.primary)),
            SizedBox(height: 10),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(onPressed: () => onDone(false), child: Text(l10n.commonCancel)),
            TIOFlatButton(onPressed: () => onDone(true), text: l10n.metronomeResetRhythmDialogConfirm, boldText: true),
          ],
        ),
      ],
    );
  }
}
