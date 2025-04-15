import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/main.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/file_references.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/media_repository.dart';
import 'package:tiomusic/services/project_library_repository.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/color_schemes.g.dart';
import 'package:tiomusic/util/log.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

class SplashApp extends StatefulWidget {
  final Function(ProjectLibrary, ThemeData?) returnProjectLibraryAndTheme;

  const SplashApp({super.key, required this.returnProjectLibraryAndTheme});

  @override
  State<SplashApp> createState() => _SplashAppState();
}

class _SplashAppState extends State<SplashApp> {
  static final _logger = createPrefixLogger('SplashApp');

  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final fs = context.read<FileSystem>();
      final mediaRepo = context.read<MediaRepository>();
      final fileReferences = context.read<FileReferences>();

      await fs.init();
      await mediaRepo.init();
      final ProjectLibrary projectLibrary = await _initProjectLibrary();
      await fileReferences.init(projectLibrary);
      await NoteHandler.createNoteBeatLengthMap();

      return _returnLoadedData(projectLibrary, null);
    });
  }

  Future<ProjectLibrary> _initProjectLibrary() async {
    try {
      final projectLibraryRepo = context.read<ProjectLibraryRepository>();
      return projectLibraryRepo.exists() ? projectLibraryRepo.load() : ProjectLibrary.withDefaults();
    } catch (e) {
      _logger.e('Unable to load project library.', error: e);
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
      title: context.l10n.mainSplashScreen,
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      home: Scaffold(resizeToAvoidBottomInset: false, backgroundColor: ColorTheme.primary92, body: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(context.l10n.mainErrorDataLoading, style: TextStyle(color: ColorTheme.surfaceTint, fontSize: 24)),
            const SizedBox(height: 24),
            TIOFlatButton(onPressed: main, text: context.l10n.mainRetry),
            const SizedBox(height: 24),
            TIOFlatButton(
              onPressed: () async {
                await context.read<ProjectLibraryRepository>().delete();
                _returnLoadedData(ProjectLibrary.withDefaults(), null);
              },
              text: context.l10n.mainOpenAnyway,
            ),
          ],
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}
