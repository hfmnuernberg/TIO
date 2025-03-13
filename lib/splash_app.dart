import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/main.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/file_references.dart';
import 'package:tiomusic/services/media_repository.dart';
import 'package:tiomusic/services/project_library_repository.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/color_schemes.g.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

class SplashApp extends StatefulWidget {
  final Function(ProjectLibrary, ThemeData?) returnProjectLibraryAndTheme;

  const SplashApp({super.key, required this.returnProjectLibraryAndTheme});

  @override
  State<SplashApp> createState() => _SplashAppState();
}

class _SplashAppState extends State<SplashApp> {
  late ProjectLibraryRepository _projectLibraryRepo;
  late MediaRepository _mediaRepo;
  late FileReferences _fileReferences;

  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    _projectLibraryRepo = Provider.of<ProjectLibraryRepository>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _mediaRepo.init();
      await NoteHandler.createNoteBeatLengthMap();
      final ProjectLibrary projectLibrary = await _initProjectLibrary();
      await _fileReferences.init(projectLibrary);
      return _returnLoadedData(projectLibrary, null);
    });
  }

  Future<ProjectLibrary> _initProjectLibrary() async {
    try {
      return _projectLibraryRepo.exists() ? _projectLibraryRepo.load() : ProjectLibrary.withDefaults();
    } catch (e) {
      debugPrint('Unable to load project library: $e');
      _hasError = true;
      setState(() {});
      return ProjectLibrary.withDefaults();
    }
  }

  void _returnLoadedData(ProjectLibrary projectLibrary, ThemeData? theme) {
    widget.returnProjectLibraryAndTheme(projectLibrary, theme);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Splash Screen',
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      home: Scaffold(resizeToAvoidBottomInset: false, backgroundColor: ColorTheme.primary92, body: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Could not load user data!', style: TextStyle(color: ColorTheme.surfaceTint, fontSize: 24)),
            const SizedBox(height: 24),
            TIOFlatButton(onPressed: main, text: 'Retry'),
            const SizedBox(height: 24),
            TIOFlatButton(
              onPressed: () async {
                _projectLibraryRepo.delete();
                _returnLoadedData(ProjectLibrary.withDefaults(), null);
              },
              text: 'Open anyway? (All user data will be lost!)',
            ),
          ],
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}
