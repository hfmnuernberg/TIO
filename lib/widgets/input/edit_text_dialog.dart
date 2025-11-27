import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/common_buttons.dart';

Future<String?> showEditTextDialog({
  required BuildContext context,
  required String label,
  required String value,
  bool isNew = false,
}) {
  final TextEditingController controller = TextEditingController(text: value);
  controller.selection = TextSelection(baseOffset: 0, extentOffset: value.length);

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, textValue, _) {
          return PopScope(
            canPop: textValue.text == value,
            child: EditTextDialog(
              label: label,
              value: value,
              isNew: isNew,
              controller: controller,
              onSave: (newValue) => Navigator.of(context).pop(newValue),
              onCancel: () => Navigator.of(context).pop(),
            ),
          );
        },
      );
    },
  );
}

class EditTextDialog extends StatelessWidget {
  final String label;
  final String value;
  final bool isNew;
  final TextEditingController controller;
  final Function(String value) onSave;
  final Function() onCancel;

  const EditTextDialog({
    super.key,
    required this.label,
    required this.value,
    this.isNew = false,
    required this.controller,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    void handleSubmit() => onSave(controller.text);

    return AlertDialog(
      content: Transform.translate(
        offset: const Offset(0, 10),
        child: TextField(
          autofocus: true,
          maxLength: 100,
          decoration: InputDecoration(
            hintText: '',
            border: OutlineInputBorder(borderSide: BorderSide(color: ColorTheme.primary)),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorTheme.primary)),
            label: Text(label, style: TextStyle(color: ColorTheme.surfaceTint)),
          ),
          style: const TextStyle(color: ColorTheme.primary),
          controller: controller,
          onSubmitted: (_) => handleSubmit(),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        TextButton(onPressed: onCancel, child: Text(context.l10n.commonCancel)),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, textValue, _) {
            final isValid = textValue.text.isNotEmpty;
            final isDirty = textValue.text != value;
            final isSubmitEnabled = isValid && (isNew || isDirty);

            return TIOFlatButton(
              onPressed: isSubmitEnabled ? handleSubmit : null,
              text: context.l10n.commonSubmit,
              boldText: true,
            );
          },
        ),
      ],
    );
  }
}
