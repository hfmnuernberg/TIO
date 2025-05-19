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
import 'package:tiomusic/widgets/confirm_setting_button.dart';
import 'package:tiomusic/widgets/tio_icon_button.dart';

class ImageTool extends StatefulWidget {
  final bool isQuickTool;

  const ImageTool({super.key, required this.isQuickTool});

  @override
  State<ImageTool> createState() => _ImageToolState();
}

class _ImageToolState extends State<ImageTool> {
  static final _logger = createPrefixLogger('ImageTool');

  late FileSystem _fs;
  late FilePicker _filePicker;
  late FileReferences _fileReferences;
  late MediaRepository _mediaRepo;
  late ProjectRepository _projectRepo;

  late ImageBlock _imageBlock;
  late Project _project;

  @override
  void initState() {
    super.initState();

    _fs = context.read<FileSystem>();
    _filePicker = context.read<FilePicker>();
    _fileReferences = context.read<FileReferences>();
    _mediaRepo = context.read<MediaRepository>();
    _projectRepo = context.read<ProjectRepository>();

    _imageBlock = Provider.of<ProjectBlock>(context, listen: false) as ImageBlock;
    _imageBlock.timeLastModified = getCurrentDateTime();

    _project = Provider.of<Project>(context, listen: false);

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    if (_imageBlock.relativePath.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _addImageDialog(context);
      });
    }
  }

  void _shareFilePressed() async {
    await _filePicker.shareFile(context.read<FileSystem>().toAbsoluteFilePath(_imageBlock.relativePath));
  }

  void _setAsThumbnail() async {
    if (_imageBlock.relativePath.isEmpty) return;

    bool? useAsProfilePicture = await _useAsProjectPicture();
    if (useAsProfilePicture != null && useAsProfilePicture) {
      _project.thumbnailPath = _imageBlock.relativePath;
      if (mounted) {
        await _projectRepo.saveLibrary(context.read<ProjectLibrary>());
      }
    }
  }

  Future<bool?> _useAsProjectPicture() => showDialog<bool>(
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

  Future _addImageDialog(BuildContext context) => showDialog(
    context: context,
    builder:
        (context) => AddImageDialog(
          pickImageFunction: (useAsThumbnail) => _pickImageAndSave(useAsThumbnail),
          takePhotoFunction: (useAsThumbnail) => _takePhotoAndSave(useAsThumbnail),
        ),
  );

  Future<void> _pickImageAndSave(bool useAsThumbnail) async {
    try {
      final imagePath = await _filePicker.pickImage();
      if (imagePath == null) return;

      if (!await _fs.existsFileAfterGracePeriod(imagePath)) {
        if (mounted) await showFileNotAccessibleDialog(context, fileName: imagePath);
        return;
      }

      final newRelativePath = await _mediaRepo.import(imagePath, _fs.toBasename(imagePath));
      if (newRelativePath == null) return;

      if (!mounted) return;

      if (useAsThumbnail) Provider.of<Project>(context, listen: false).thumbnailPath = newRelativePath;

      final projectLibrary = context.read<ProjectLibrary>();

      _fileReferences.dec(_imageBlock.relativePath, projectLibrary);
      _imageBlock.relativePath = newRelativePath;
      _fileReferences.inc(newRelativePath);

      await _projectRepo.saveLibrary(projectLibrary);

      setState(() {});
    } on PlatformException catch (e) {
      _logger.e('Unable to pick image.', error: e);
    }
  }

  Future<void> _takePhotoAndSave(bool useAsThumbnail) async {
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

    var newFileName = '${_project.title}-${_imageBlock.title}';

    final newRelativePath = await _mediaRepo.import(imagePath, newFileName);
    if (newRelativePath == null) return;

    if (!mounted) return;

    if (useAsThumbnail) Provider.of<Project>(context, listen: false).thumbnailPath = newRelativePath;

    final projectLibrary = context.read<ProjectLibrary>();

    _fileReferences.dec(_imageBlock.relativePath, projectLibrary);
    _imageBlock.relativePath = newRelativePath;
    _fileReferences.inc(newRelativePath);

    await _projectRepo.saveLibrary(projectLibrary);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ParentTool(
      barTitle: _imageBlock.title,
      isQuickTool: widget.isQuickTool,
      project: widget.isQuickTool ? null : Provider.of<Project>(context, listen: false),
      toolBlock: _imageBlock,
      menuItems:
          _imageBlock.relativePath.isNotEmpty
              ? [
                MenuItemButton(
                  onPressed: _shareFilePressed,
                  child: Text(context.l10n.imageShare, style: const TextStyle(color: ColorTheme.primary)),
                ),
                MenuItemButton(
                  onPressed: _setAsThumbnail,
                  child: Text(context.l10n.imageSetAsThumbnail, style: const TextStyle(color: ColorTheme.primary)),
                ),
                MenuItemButton(
                  onPressed: () => _pickImageAndSave(false),
                  child: Text(context.l10n.imagePickNewImage, style: const TextStyle(color: ColorTheme.primary)),
                ),
                MenuItemButton(
                  onPressed: () => _takePhotoAndSave(false),
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
                return Image(image: FileImage(File(_fs.toAbsoluteFilePath(imageBlock.relativePath))));
              } else {
                return Stack(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TioIconButton.sm(
                          icon: const Icon(Icons.image_outlined, color: ColorTheme.primary),
                          onPressed: () => _pickImageAndSave(false),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            child: Text(
                              context.l10n.imageNoImage,
                              style: const TextStyle(color: ColorTheme.primary),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TioIconButton.sm(
                          icon: const Icon(Icons.camera_alt_outlined, color: ColorTheme.primary),
                          onPressed: () => _takePhotoAndSave(false),
                        ),
                      ],
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
