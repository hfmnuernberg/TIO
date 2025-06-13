import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

Future<bool> showConfirmDialog({required BuildContext context, required Widget title, required Widget content}) async {
  final bool? result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return ConfirmDialog(title: title, content: content, onDone: (res) => Navigator.of(context).pop(res));
    },
  );

  return result ?? false;
}

class ConfirmDialog extends StatelessWidget {
  final Widget title;
  final Widget content;
  final Function onDone;

  const ConfirmDialog({super.key, required this.title, required this.content, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      content: Transform.translate(offset: const Offset(0, 10), child: content),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(onPressed: () => onDone(false), child: Text(context.l10n.commonCancel)),
            TIOFlatButton(onPressed: () => onDone(true), text: context.l10n.commonConfirm, boldText: true),
          ],
        ),
      ],
    );
  }
}
