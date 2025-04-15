import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

Future<bool> showConfirmDialog({required BuildContext context}) async {
  final bool? result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return ConfirmDialog(
          onDone: (res) => Navigator.of(context).pop(res),
      );
    }
  );

  return result ?? false;
}

class ConfirmDialog extends StatelessWidget {
  final Function onDone;

  const ConfirmDialog({super.key, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import Text file', style: TextStyle(color: ColorTheme.primary)),
      content: Transform.translate(
        offset: const Offset(0, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('Would you like to import a text file?', style: TextStyle(color: ColorTheme.primary)),
            SizedBox(height: 10),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(onPressed: () => onDone(false), child: Text('Cancel')),
            TIOFlatButton(onPressed: () => onDone(true), text: 'Import', boldText: true),
          ],
        ),
      ],
    );
  }
}
