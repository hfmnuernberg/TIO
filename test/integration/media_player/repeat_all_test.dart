import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/pages/project_page/project_page.dart';

import '../../utils/action_utils.dart';
import '../../utils/connection_utils.dart';
import '../../utils/media_player_utils.dart';
import '../../utils/render_utils.dart';
import '../../utils/test_context.dart';

void main() {
  late TestContext context;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    context = TestContext();
    await context.init(project: Project.defaultThumbnail('Test Project'));
  });

  group('MediaPlayer - Repeat All', () {
    testWidgets('skips island media players when advancing to next track', (tester) async {
      final audio1 = saveTestAudioFile(context, name: 'audio_file_1');
      final audio2 = saveTestAudioFile(context, name: 'audio_file_2');
      final audio3 = saveTestAudioFile(context, name: 'audio_file_3');

      await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
      await tester.createMediaPlayerToolInProject();
      await tester.createMediaPlayerWithAudio('Media Player 2', context, audio2);
      await tester.createMediaPlayerWithAudio('Media Player 3', context, audio3);
      await tester.openMediaPlayerAndLoadAudio('Media Player 1', context, audio1);
      await tester.connectExistingTool('Media Player 2');

      await tester.ensureVisible(find.byTooltip('Repeat no media player'));
      await tester.tapAndSettle(find.byTooltip('Repeat no media player'));
      await tester.ensureVisible(find.byTooltip('Repeat media player'));
      await tester.tapAndSettle(find.byTooltip('Repeat media player'));

      mockPlayerState(context, playbackPositionFactor: 0.99);
      await tester.ensureVisible(find.byTooltip('Play'));
      await tester.tap(find.byTooltip('Play'));
      await tester.pump(const Duration(milliseconds: 150));

      mockPlayerState(context, playing: false);
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      expect(find.textContaining('Media Player 3'), findsOneWidget);
    });
  });
}
