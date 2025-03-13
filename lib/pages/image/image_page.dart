import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tiomusic/models/blocks/image_block.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/image/add_image_dialog.dart';
import 'package:tiomusic/pages/image/take_picture_screen.dart';
import 'package:tiomusic/pages/parent_tool/parent_tool.dart';
import 'package:tiomusic/services/file_references.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/media_repository.dart';
import 'package:tiomusic/services/project_library_repository.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

class ImageTool extends StatefulWidget {
  final bool isQuickTool;

  const ImageTool({super.key, required this.isQuickTool});

  @override
  State<ImageTool> createState() => _ImageToolState();
}

class _ImageToolState extends State<ImageTool> {
  late FileSystem _fs;
  late FileReferences _fileReferences;
  late MediaRepository _mediaRepo;
  late ProjectLibraryRepository _projectLibraryRepo;

  late ImageBlock _imageBlock;
  late Project _project;

  final List<MenuItemButton> _menuItems = List.empty(growable: true);
  late MenuItemButton _shareMenuButton;
  late MenuItemButton _setAsThumbnailMenuButton;

  @override
  void initState() {
    super.initState();

    _fs = Provider.of<FileSystem>(context, listen: false);
    _fileReferences = Provider.of<FileReferences>(context, listen: false);
    _mediaRepo = Provider.of<MediaRepository>(context, listen: false);
    _projectLibraryRepo = Provider.of<ProjectLibraryRepository>(context, listen: false);

    _shareMenuButton = MenuItemButton(
      onPressed: _shareFilePressed,
      child: const Text('Share image', style: TextStyle(color: ColorTheme.primary)),
    );

    _setAsThumbnailMenuButton = MenuItemButton(
      onPressed: _setAsThumbnail,
      child: const Text('Set as thumbnail', style: TextStyle(color: ColorTheme.primary)),
    );

    _imageBlock = Provider.of<ProjectBlock>(context, listen: false) as ImageBlock;
    _imageBlock.timeLastModified = getCurrentDateTime();

    _project = Provider.of<Project>(context, listen: false);

    // only allow portrait mode for this tool
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    if (_imageBlock.relativePath.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _addImageDialog(context);
      });
    } else {
      _addOptionsToMenu();
    }
  }

  void _addOptionsToMenu() {
    setState(() {
      if (!_menuItems.contains(_shareMenuButton)) {
        _menuItems.add(_shareMenuButton);
      }
      if (!_menuItems.contains(_setAsThumbnailMenuButton)) {
        _menuItems.add(_setAsThumbnailMenuButton);
      }
    });
  }

  void _shareFilePressed() async {
    XFile file = XFile(context.read<FileSystem>().toAbsoluteFilePath(_imageBlock.relativePath));
    await Share.shareXFiles([file]);
  }

  void _setAsThumbnail() async {
    if (_imageBlock.relativePath.isEmpty) return;

    bool? useAsProfilePicture = await _useAsProjectPicture();
    if (useAsProfilePicture != null && useAsProfilePicture) {
      _project.setThumbnail( _imageBlock.relativePath);
      if (mounted) {
        await _projectLibraryRepo.save(context.read<ProjectLibrary>());
      }
    }
  }

  Future<bool?> _useAsProjectPicture() => showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Set Project Thumbnail', style: TextStyle(color: ColorTheme.primary)),
          content: const Text(
            'Do you want to use the image of this tool as your profile picture for this project?',
            style: TextStyle(color: ColorTheme.primary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
            TIOFlatButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              text: 'Yes',
              boldText: true,
            ),
          ],
        ),
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
    final fs = Provider.of<FileSystem>(context, listen: false);
    final imagePath = await fs.pickImage();
    // TODO
    // await fs.saveImage(image);
    // await _pickImage(context, context.read<ProjectLibrary>());
    // _imageBlock.relativePath = imagePath;

    if (_imageBlock.relativePath.isNotEmpty) {
      _addOptionsToMenu();
    }

    if (!mounted) return;

    if (useAsThumbnail) {
      Provider.of<Project>(context, listen: false).setThumbnail(_imageBlock.relativePath);
    }

    await _projectLibraryRepo.save(context.read<ProjectLibrary>());
  }

  Future<void> _pickImage(BuildContext context, ProjectLibrary projectLibrary) async {
    try {
      final imagePath = await _fs.pickImage();

      if (imagePath == null) return;

      if (!context.mounted) return;

      final newRelativePath = await _mediaRepo.import(imagePath, _fs.toBasename(imagePath));

      if (newRelativePath == null) return;

      // TODO
      // notifyListeners();
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image: $e');
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

    if (mounted) {
      XFile? image = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return TakePictureScreen(camera: firstCamera);
          },
        ),
      );

      if (image == null) return;

      var newFileName = '${_project.title}-${_imageBlock.title}';

      if (mounted) {
        var projectLib = context.read<ProjectLibrary>();

        final newRelativePath = await _mediaRepo.import(image.path, newFileName);

        if (newRelativePath == null) return;

        if (mounted) {
          if (useAsThumbnail) {
            Provider.of<Project>(context, listen: false).setThumbnail(newRelativePath);
          }

          _imageBlock.relativePath = newRelativePath;
          await _projectLibraryRepo.save(projectLib);

          _addOptionsToMenu();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ParentTool(
      barTitle: _imageBlock.title,
      isQuickTool: widget.isQuickTool,
      project: widget.isQuickTool ? null : Provider.of<Project>(context, listen: false),
      toolBlock: _imageBlock,
      menuItems: _menuItems,
      centerModule: Padding(
        padding: const EdgeInsets.all(TIOMusicParams.edgeInset),
        child: Center(
          child: Consumer<ProjectBlock>(
            builder: (context, projectBlock, child) {
              var imageBlock = projectBlock as ImageBlock;
              if (imageBlock.relativePath.isNotEmpty) {
                return Image(image: FileImage(File(_fs.toAbsoluteFilePath(imageBlock.relativePath))));
              } else {
                return const Text('No image in this tool.', style: TextStyle(color: ColorTheme.primary));
              }
            },
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FloatingActionButton(
              onPressed: () => _pickImageAndSave(false),
              heroTag: null,
              backgroundColor: ColorTheme.surface,
              child: const Icon(Icons.image_outlined, color: ColorTheme.primary),
            ),
            FloatingActionButton(
              onPressed: () => _takePhotoAndSave(false),
              heroTag: null,
              backgroundColor: ColorTheme.surface,
              child: const Icon(Icons.camera_alt_outlined, color: ColorTheme.primary),
            ),
          ],
        ),
      ),
      settingTiles: const [],
    );
  }
}
