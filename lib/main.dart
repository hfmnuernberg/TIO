import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/file_references.dart';
import 'package:tiomusic/models/json_converter.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/projects_list/projects_list.dart';
import 'package:tiomusic/rust_api/ffi.dart';

import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/util/audio_util.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/color_schemes.g.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

void main() {
  // first running loading screen app to load the data from json
  runApp(
    SplashApp(
      key: UniqueKey(),
      returnProjectLibraryAndTheme: (projectLibrary, themeData) => runMainApp(projectLibrary, themeData),
    ),
  );
}

// and then running the main app
void runMainApp(ProjectLibrary projectLibrary, ThemeData? theme) {
  runApp(
    TIOMusicApp(projectLibrary: projectLibrary, ourTheme: theme),
  );
}

class TIOMusicApp extends StatelessWidget {
  const TIOMusicApp({super.key, required this.projectLibrary, this.ourTheme});

  final ProjectLibrary projectLibrary;
  final ThemeData? ourTheme;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProjectLibrary>.value(
      value: projectLibrary,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TIO Music',
        theme: ourTheme ?? ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
        home: const TIOMusicHomePage(title: 'TIO Music'),
      ),
    );
  }
}

class TIOMusicHomePage extends StatefulWidget {
  const TIOMusicHomePage({super.key, required this.title});

  final String title;

  @override
  State<TIOMusicHomePage> createState() => _TIOMusicHomePageState();
}

class _TIOMusicHomePageState extends State<TIOMusicHomePage> {
  @override
  void initState() {
    super.initState();

    if (Platform.isIOS) {
      startAudioSession()
          .then((_) async => await configureAudioSession(AudioSessionType.playback))
          .then((_) async => await Future.delayed(const Duration(milliseconds: 500)))
          .then((_) => rustApi.init());
    } else {
      rustApi.init();
    }

    if (kDebugMode) {
      Timer.periodic(const Duration(milliseconds: 25), (Timer t) {
        rustApi.pollDebugLogMessage().then((message) {
          if (message != null && message.isNotEmpty) debugPrint(message);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: false,
      body: ProjectsList(),
    );
  }
}

// app for the loading screen and for loading the data
class SplashApp extends StatefulWidget {
  final Function(ProjectLibrary, ThemeData?) returnProjectLibraryAndTheme;

  const SplashApp({
    super.key,
    required this.returnProjectLibraryAndTheme,
  });

  @override
  State<SplashApp> createState() => _SplashAppState();
}

class _SplashAppState extends State<SplashApp> {
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await FileIO.createMediaDirectory();

      await NoteHandler.createNoteBeatLengthMap();

      final ProjectLibrary? projectLibrary = await _initializeProjectLibrary();

      if (projectLibrary != null) {
        FileReferences.init(projectLibrary).then(
          (_) => _returnLoadedData(projectLibrary, null),
        );
      }
      // if projectLibrary is null, the hasError flag was set to true and we build the "ask user again" page
    });
  }

  Future<ProjectLibrary?> _initializeProjectLibrary() async {
    String? jsonString = await FileIO.readJsonDataFromSave();

    ProjectLibrary? projectLibrary;
    if (jsonString == null || jsonString.isEmpty) {
      projectLibrary = ProjectLibrary.withDefaults();
      FileIO.deleteLocalJsonFile();
    } else {
      try {
        // _________________________________________________________________
        // If you want to test custom ProjectLibrary data, you can use this code to import your own json file
        // This way you can test how old fields are converted to new fields for example
        // String customJsonString = "";
        // if (mounted) {
        //   customJsonString = await DefaultAssetBundle.of(context).loadString("assets/testdata/jsonoldversion.json");
        // }
        // _________________________________________________________________

        Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        CustomJsonConverter.renameKeys(jsonMap);
        CustomJsonConverter.checkIfJsonMapContainsOldRhythmVersion(jsonMap);

        projectLibrary = ProjectLibrary.fromJson(jsonMap);
      } catch (e) {
        _hasError = true;
        debugPrint("failed to parse json to library: $e");
        setState(() {});

        projectLibrary = null;
      }
    }

    return projectLibrary;
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
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: ColorTheme.primary92,
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Could not load user data!",
              style: TextStyle(color: ColorTheme.surfaceTint, fontSize: 24),
            ),
            const SizedBox(height: 24),
            TIOFlatButton(
              onPressed: () => main(),
              text: "Retry",
            ),
            const SizedBox(height: 24),
            TIOFlatButton(
              onPressed: () {
                FileIO.deleteLocalJsonFile();
                _returnLoadedData(ProjectLibrary.withDefaults(), null);
              },
              text: "Open anyway (All data is lost!)",
            ),
          ],
        ),
      );
    }
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}