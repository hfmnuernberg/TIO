import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tiomusic/pages/projects_page/projects_page.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/util/audio_util.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    if (Platform.isIOS) {
      startAudioSession()
          .then((_) async => configureAudioSession(AudioSessionType.playback))
          .then((_) async => Future.delayed(const Duration(milliseconds: 500)))
          .then((_) => initAudio());
    } else {
      initAudio();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(resizeToAvoidBottomInset: false, body: ProjectsPage());
  }
}
