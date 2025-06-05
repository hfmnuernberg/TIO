import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

class AddImageDialog extends StatefulWidget {
  final Function pickImageFunction;
  final Function takePhotoFunction;

  const AddImageDialog({super.key, required this.pickImageFunction, required this.takePhotoFunction});

  @override
  State<AddImageDialog> createState() => _AddImageDialogState();
}

class _AddImageDialogState extends State<AddImageDialog> {
  bool useImageAsProjectThumbnail = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.imagePickOrTakeImage, style: TextStyle(color: ColorTheme.primary)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.imageUploadHintFirst, style: TextStyle(color: ColorTheme.primary)),
          const SizedBox(height: 10),
          Text(l10n.imageUploadHintSecond, style: TextStyle(color: ColorTheme.primary)),
          const SizedBox(height: 10),
          TIOFlatButton(
            onPressed: () {
              widget.pickImageFunction(useImageAsProjectThumbnail);
              Navigator.pop(context);
            },
            text: l10n.imagePickImage,
          ),
          TIOFlatButton(
            onPressed: () {
              widget.takePhotoFunction(useImageAsProjectThumbnail);
              Navigator.pop(context);
            },
            text: l10n.imageTakePhoto,
          ),
          CheckboxListTile(
            value: useImageAsProjectThumbnail,
            onChanged: (value) {
              setState(() {
                useImageAsProjectThumbnail = value!;
              });
            },
            title: Text(l10n.imageUseAsThumbnailQuestion, style: TextStyle(color: ColorTheme.primary)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(l10n.imageDoLater),
        ),
      ],
    );
  }
}
