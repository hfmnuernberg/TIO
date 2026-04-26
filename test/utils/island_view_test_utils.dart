import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/pages/project_page/project_page.dart';

import 'connection_utils.dart';
import 'media_player_utils.dart';
import 'render_utils.dart';
import 'test_context.dart';

extension WidgetTesterIslandViewExtension on WidgetTester {
  Future<void> prepareMediaPlayerWithLoadedIsland(
    TestContext context, {
    double? primaryDurationSeconds,
    double? islandDurationSeconds,
    double? primaryInitialPlaybackPositionFactor,
  }) async {
    final audio1 = saveTestAudioFile(context, name: 'audio_file_1');
    final audio2 = saveTestAudioFile(context, name: 'audio_file_2');
    await renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
    await createMediaPlayerToolInProject();
    await createMediaPlayerWithAudio('Media Player 2', context, audio2);

    if (primaryDurationSeconds != null) {
      mockPlayerState(
        context,
        playing: false,
        totalLengthSeconds: primaryDurationSeconds,
        playbackPositionFactor: primaryInitialPlaybackPositionFactor ?? 0,
      );
    }
    await openMediaPlayerAndLoadAudio('Media Player 1', context, audio1);

    if (islandDurationSeconds != null) {
      mockPlayerState(context, playing: false, totalLengthSeconds: islandDurationSeconds);
    }
    await connectExistingTool('Media Player 2');
  }

  Future<void> prepareMediaPlayerWithUnloadedIsland(TestContext context) async {
    final audio = saveTestAudioFile(context);
    await renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
    await createMediaPlayerToolInProject();
    await openMediaPlayerAndLoadAudio('Media Player 1', context, audio);
    await connectNewTool('Media Player', 'Media Player 2');
  }
}
