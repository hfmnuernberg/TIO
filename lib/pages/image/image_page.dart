import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/image_block.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/image/add_image_dialog.dart';
import 'package:tiomusic/pages/image/take_picture_screen.dart';
import 'package:tiomusic/pages/parent_tool/parent_tool.dart';
import 'package:tiomusic/services/file_picker.dart';
import 'package:tiomusic/services/file_references.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/media_repository.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/log.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/common_buttons.dart';
import 'package:tiomusic/widgets/tio_icon_button.dart';

class ImageTool extends StatefulWidget {
  final bool isQuickTool;

  const ImageTool({super.key, required this.isQuickTool});

  @override
  State<ImageTool> createState() => _ImageToolState();
}

class _ImageToolState extends State<ImageTool> {
  static final logger = createPrefixLogger('ImageTool');

  late FileSystem fs;
  late FilePicker filePicker;
  late FileReferences fileReferences;
  late MediaRepository mediaRepo;
  late ProjectRepository projectRepo;

  late ImageBlock imageBlock;
  late Project project;

  @override
  void initState() {
    super.initState();

    fs = context.read<FileSystem>();
    filePicker = context.read<FilePicker>();
    fileReferences = context.read<FileReferences>();
    mediaRepo = context.read<MediaRepository>();
    projectRepo = context.read<ProjectRepository>();

    imageBlock = Provider.of<ProjectBlock>(context, listen: false) as ImageBlock;
    imageBlock.timeLastModified = getCurrentDateTime();

    project = context.read<Project>();

    if (imageBlock.relativePath.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await addImageDialog(context);
      });
    }
  }

  void shareFilePressed() async {
    await filePicker.shareFile(context.read<FileSystem>().toAbsoluteFilePath(imageBlock.relativePath));
  }

  void setAsThumbnail() async {
    if (imageBlock.relativePath.isEmpty) return;

    bool? useAsProfilePicture = await useAsProjectPicture();
    if (useAsProfilePicture != null && useAsProfilePicture) {
      project.thumbnailPath = imageBlock.relativePath;
      if (mounted) {
        await projectRepo.saveLibrary(context.read<ProjectLibrary>());
      }
    }
  }

  Future<bool?> useAsProjectPicture() => showDialog<bool>(
    context: context,
    builder: (context) {
      final l10n = context.l10n;
      return AlertDialog(
        title: Text(l10n.imageSetAsProjectThumbnail, style: TextStyle(color: ColorTheme.primary)),
        content: Text(l10n.imageSetAsThumbnailQuestion, style: TextStyle(color: ColorTheme.primary)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(l10n.commonNo),
          ),
          TIOFlatButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            text: l10n.commonYes,
            boldText: true,
          ),
        ],
      );
    },
  );

  Future addImageDialog(BuildContext context) => showDialog(
    context: context,
    builder: (context) => AddImageDialog(
      pickImageFunction: (useAsThumbnail) => pickImagesAndSave(useAsThumbnail),
      takePhotoFunction: (useAsThumbnail) => takePhotoAndSave(useAsThumbnail),
    ),
  );

  Future<void> pickImagesAndSave(bool useAsThumbnail) async {
    try {
      final imagePaths = await filePicker.pickImages(limit: 10);
      if (imagePaths.isEmpty) return;

      for (int i = 0; i < imagePaths.length; i++) {
        await handleImage(i, imagePaths[i], useAsThumbnail);
      }
    } on PlatformException catch (e) {
      logger.e('Unable to pick images.', error: e);
    }
  }

  Future<void> takePhotoAndSave(bool useAsThumbnail) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) await showNoCameraFoundDialog(context);
        return;
      }

      final firstCamera = cameras.first;

      if (!mounted) return;
      String? imagePath = await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => TakePictureScreen(camera: firstCamera)));
      if (imagePath == null) return;

      await handleImage(0, imagePath, useAsThumbnail);
    } on PlatformException catch (e) {
      logger.e('Unable to take photo.', error: e);
    }
  }

  Future<void> handleImage(int index, String imagePath, bool useAsThumbnail) async {
    if (!await fs.existsFileAfterGracePeriod(imagePath)) {
      if (mounted) await showFileNotAccessibleDialog(context, fileName: imagePath);
      return;
    }

    final newRelativePath = await mediaRepo.import(imagePath, fs.toBasename(imagePath));
    if (newRelativePath == null || !mounted) return;

    fileReferences.inc(newRelativePath);

    if (index == 0) {
      if (useAsThumbnail) project.thumbnailPath = newRelativePath;
      fileReferences.dec(imageBlock.relativePath, context.read<ProjectLibrary>());
      imageBlock.relativePath = newRelativePath;
    } else {
      final title = '${imageBlock.title} ($index)';
      final newBlock = ImageBlock.withTitle(title)..relativePath = newRelativePath;
      project.addBlock(newBlock);
    }

    if (!mounted) return;

    await projectRepo.saveLibrary(context.read<ProjectLibrary>());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.isQuickTool ? null : context.read<Project>();
    final isUsedAsThumbnail = project?.thumbnailPath == imageBlock.relativePath;

    return ParentTool(
      barTitle: imageBlock.title,
      isQuickTool: widget.isQuickTool,
      project: project,
      toolBlock: imageBlock,
      menuItems: imageBlock.relativePath.isNotEmpty
          ? [
              MenuItemButton(
                onPressed: shareFilePressed,
                child: Text(context.l10n.imageShare, style: const TextStyle(color: ColorTheme.primary)),
              ),
              MenuItemButton(
                onPressed: setAsThumbnail,
                child: Text(context.l10n.imageSetAsThumbnail, style: const TextStyle(color: ColorTheme.primary)),
              ),
              MenuItemButton(
                onPressed: () => pickImagesAndSave(isUsedAsThumbnail),
                child: Text(context.l10n.imagePickNewImage, style: const TextStyle(color: ColorTheme.primary)),
              ),
              MenuItemButton(
                onPressed: () => takePhotoAndSave(isUsedAsThumbnail),
                child: Text(context.l10n.imageTakeNewPhoto, style: const TextStyle(color: ColorTheme.primary)),
              ),
            ]
          : null,
      centerModule: Padding(
        padding: const EdgeInsets.all(TIOMusicParams.edgeInset),
        child: Center(
          child: Consumer<ProjectBlock>(
            builder: (context, projectBlock, child) {
              var imageBlock = projectBlock as ImageBlock;
              if (imageBlock.relativePath.isNotEmpty) {
                return Image(image: FileImage(File(fs.toAbsoluteFilePath(imageBlock.relativePath))));
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.l10n.imagePickOrTakeImage,
                      style: const TextStyle(color: ColorTheme.primary),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          TioIconButton.sm(
                            icon: const Icon(Icons.image_outlined, color: ColorTheme.primary),
                            tooltip: context.l10n.imagePickImage,
                            onPressed: () => pickImagesAndSave(false),
                          ),
                          const SizedBox(width: 12),
                          TioIconButton.sm(
                            icon: const Icon(Icons.camera_alt_outlined, color: ColorTheme.primary),
                            tooltip: context.l10n.imageTakePhoto,
                            onPressed: () => takePhotoAndSave(false),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
      settingTiles: const [],
    );
  }
}
