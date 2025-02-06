import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

Future<String?> showEditTextDialog({
  required BuildContext context,
  required String label,
  required String value,
  bool isNew = false,
}) =>
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => EditTextDialog(
        label: label,
        value: value,
        isNew: isNew,
        onSave: (value) => Navigator.of(context).pop(value),
        onCancel: () => Navigator.of(context).pop(),
      ),
    );

class EditTextDialog extends StatelessWidget {
  final String label;
  final String value;
  final bool isNew;
  final Function(String value) onSave;
  final Function() onCancel;

  const EditTextDialog({
    super.key,
    required this.label,
    required this.value,
    this.isNew = false,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController(text: value);
    controller.selection = TextSelection(baseOffset: 0, extentOffset: value.length);

    void handleSubmit() => onSave(controller.text);

    return PopScope(
      canPop: controller.text == value,
      child: AlertDialog(
        content: Transform.translate(
          offset: const Offset(0, 10),
          child: TextField(
            autofocus: true,
            maxLength: 100,
            decoration: InputDecoration(
              hintText: "",
              border: OutlineInputBorder(borderSide: BorderSide(color: ColorTheme.primary)),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorTheme.primary)),
              label: Text(label, style: TextStyle(color: ColorTheme.surfaceTint)),
            ),
            style: const TextStyle(color: ColorTheme.primary),
            controller: controller,
            onSubmitted: (_) => handleSubmit(),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: onCancel,
                child: const Text('Cancel'),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, child) {
                  final isValid = controller.text.isNotEmpty;
                  final isDirty = controller.text != this.value;
                  final isSubmitEnabled = isValid && (isNew || isDirty);

                  return TIOFlatButton(
                    onPressed: isSubmitEnabled ? handleSubmit : null,
                    text: 'Submit',
                    boldText: true,
                  );
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
