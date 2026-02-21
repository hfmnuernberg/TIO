import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/src/rust/api/modules/media_player.dart';

import 'action_utils.dart';
import 'test_context.dart';

void mockPlayerState(
  TestContext context, {
  bool playing = true,
  double playbackPositionFactor = 0,
  double totalLengthSeconds = 10,
  bool looping = false,
  double trimStartFactor = 0,
  double trimEndFactor = 1,
}) {
  context.audioSystemMock.mockMediaPlayerGetState(
    MediaPlayerState(
      playing: playing,
      playbackPositionFactor: playbackPositionFactor,
      totalLengthSeconds: totalLengthSeconds,
      looping: looping,
      trimStartFactor: trimStartFactor,
      trimEndFactor: trimEndFactor,
    ),
  );
}

String saveTestAudioFile(TestContext context, {String name = 'audio_file'}) {
  final filePath = '${context.inMemoryFileSystem.tmpFolderPath}/$name.wav';
  context.inMemoryFileSystem.saveFileAsBytes(filePath, File('assets/test/ping.wav').readAsBytesSync());
  return filePath;
}

extension WidgetTesterMediaPlayerExtension on WidgetTester {
  Future<void> loadAudioOnCurrentMediaPlayer(TestContext context, String audioFilePath) async {
    context.filePickerMock.mockPickAudioFromMediaLibrary([audioFilePath]);
    await scrollToAndTapAndSettle('Open files');
  }

  Future<void> openMediaPlayerAndLoadAudio(String title, TestContext context, String audioFilePath) async {
    await tapAndSettle(find.bySemanticsLabel(title));
    await loadAudioOnCurrentMediaPlayer(context, audioFilePath);
  }

  Future<void> createMediaPlayerWithAudio(String title, TestContext context, String audioFilePath) async {
    await tapAndSettle(find.byTooltip('Add new tool'));
    await tapAndSettle(find.bySemanticsLabel('Media Player'));
    await enterTextAndSettle(find.bySemanticsLabel('Tool title'), title);
    await tapAndSettle(find.bySemanticsLabel('Submit'));
    await loadAudioOnCurrentMediaPlayer(context, audioFilePath);
    await tapAndSettle(find.bySemanticsLabel('Back'));
  }

  Future<void> connectExistingTool(String toolTitle) async {
    await ensureVisible(find.byTooltip('Connect another tool'));
    await tapAndSettle(find.byTooltip('Connect another tool'));
    await tapAndSettle(find.bySemanticsLabel(toolTitle));
    await pumpAndSettle(const Duration(milliseconds: 1100));
  }

  Future<void> connectNewTool(String toolType, String toolTitle) async {
    await ensureVisible(find.byTooltip('Connect another tool'));
    await tapAndSettle(find.byTooltip('Connect another tool'));
    await tapAndSettle(find.bySemanticsLabel(toolType));
    await enterTextAndSettle(find.bySemanticsLabel('Tool title'), toolTitle);
    await tapAndSettle(find.bySemanticsLabel('Submit'));
    await pumpAndSettle(const Duration(milliseconds: 1100));
  }
}
