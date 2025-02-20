import 'package:flutter/material.dart';
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
    return AlertDialog(
      title: const Text("No image in this tool", style: TextStyle(color: ColorTheme.primary)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Pick an image from your device or take a photo using the camera",
            style: TextStyle(color: ColorTheme.primary),
          ),
          const SizedBox(height: 10),
          TIOFlatButton(
            onPressed: () {
              widget.pickImageFunction(useImageAsProjectThumbnail);
              Navigator.pop(context);
            },
            text: "Pick an image",
          ),
          TIOFlatButton(
            onPressed: () {
              widget.takePhotoFunction(useImageAsProjectThumbnail);
              Navigator.pop(context);
            },
            text: "Take a photo",
          ),
          CheckboxListTile(
            value: useImageAsProjectThumbnail,
            onChanged: (bool? value) {
              setState(() {
                useImageAsProjectThumbnail = value!;
              });
            },
            title: const Text("Use image as project thumbnail", style: TextStyle(color: ColorTheme.primary)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Do it later'),
        ),
      ],
    );
  }
}
