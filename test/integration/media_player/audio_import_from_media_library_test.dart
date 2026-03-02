import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/pages/project_page/project_page.dart';

import '../../utils/action_utils.dart';
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

  Future<void> renderAndOpenMediaPlayer(WidgetTester tester, {String title = 'Media Player 1'}) async {
    await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
    await tester.createMediaPlayerToolInProject(title: title);
    await tester.tapAndSettle(find.bySemanticsLabel(title));
  }

  group('Media library import', () {
    testWidgets('imports two audio files from media library', (tester) async {
      final filePath1 = saveTestAudioFile(context, name: 'song_one');
      final filePath2 = saveTestAudioFile(context, name: 'song_two');
      context.filePickerMock.mockPickAudioFromMediaLibrary([filePath1, filePath2]);

      await renderAndOpenMediaPlayer(tester, title: 'Song Import');
      await tester.scrollToAndTapAndSettle('Open files');
      await tester.tapAndSettle(find.bySemanticsLabel('Back'));

      expect(find.bySemanticsLabel('Song Import'), findsOneWidget);
      expect(find.bySemanticsLabel('Song Import (1)'), findsOneWidget);
    });
  });

  group('Media library import with skipped songs', () {
    testWidgets('shows not-downloaded dialog when some songs are skipped', (tester) async {
      final filePath = saveTestAudioFile(context);
      context.filePickerMock.mockPickAudioFromMediaLibrary([filePath, null, null]);

      await renderAndOpenMediaPlayer(tester);
      await tester.scrollToAndTapAndSettle('Open files');

      expect(find.bySemanticsLabel('Song(s) not available'), findsOneWidget);
    });

    testWidgets('imports valid file even when some songs are skipped', (tester) async {
      final filePath = saveTestAudioFile(context);
      context.filePickerMock.mockPickAudioFromMediaLibrary([filePath, null]);

      await renderAndOpenMediaPlayer(tester);
      await tester.scrollToAndTapAndSettle('Open files');

      expect(find.textContaining('audio_file'), findsOneWidget);
    });

    testWidgets('shows not-downloaded dialog when all songs are skipped', (tester) async {
      context.filePickerMock.mockPickAudioFromMediaLibrary([null, null]);

      await renderAndOpenMediaPlayer(tester);
      await tester.scrollToAndTapAndSettle('Open files');

      expect(find.bySemanticsLabel('Song(s) not available'), findsOneWidget);
    });

    testWidgets('does not show dialog when selection is cancelled', (tester) async {
      when(
        () => context.filePickerMock.pickAudioFromMediaLibrary(isMultipleAllowed: any(named: 'isMultipleAllowed')),
      ).thenAnswer((_) async => null);

      await renderAndOpenMediaPlayer(tester);
      await tester.scrollToAndTapAndSettle('Open files');

      expect(find.bySemanticsLabel('Song(s) not available'), findsNothing);
    });
  });
}
