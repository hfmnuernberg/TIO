import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/pages/projects_page/projects_page.dart';
import 'package:tiomusic/services/audio_session.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/util/log.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static final logger = createPrefixLogger('HomePage');

  @override
  void initState() {
    super.initState();

    final audioSystem = context.read<AudioSystem>();
    final audioSession = context.read<AudioSession>();

    if (Platform.isIOS) {
      audioSession.start().then((success) async {
        if (!success) {
          logger.e('Unable to start audio session.');
          return;
        }
        // await audioSession.preparePlayback();
        try {
          await audioSession.preparePlayback();
        } catch (e) {
          // This can fail if permissions are not granted yet.
          // ignore: avoid_print
          print('[Home] preparePlayback failed early: $e (will reconfigure when a tool starts)');
        }
        await Future.delayed(const Duration(milliseconds: 500));
        await audioSystem.initAudio();
      });
    } else {
      audioSystem.initAudio();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(resizeToAvoidBottomInset: false, body: ProjectsPage());
  }
}
