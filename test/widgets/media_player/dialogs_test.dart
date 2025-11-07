import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/pages/media_player/media_player_dialogs.dart';

import '../../utils/action_utils.dart';
import '../../utils/render_utils.dart';

class TestWrapper extends StatelessWidget {
  const TestWrapper({super.key});

  Future<void> handleAskForOverridingFileOnRecordingStart(BuildContext context) async {
    await askForOverridingFileOnRecordingStart(context);
  }
  Future<void> handleAskForOverridingFileOnOpenFileSelection(BuildContext context) async {
    await askForOverridingFileOnOpenFileSelection(context);
  }

  Future<void> handleShowTooManyFilesSelectedDialog(BuildContext context) async {
    await showTooManyFilesSelectedDialog(context);
  }

  Future<void> handleShowMissingMicrophonePermissionDialog(BuildContext context) async {
    await showMissingMicrophonePermissionDialog(context);
  }

  Future<void> handleShowFormatNotSupportedDialog(BuildContext context) async {
    await showFormatNotSupportedDialog(context, 'wav');
  }

  Future<void> handleShowFileOpenFailedDialogNoName(BuildContext context) async {
    await showFileOpenFailedDialog(context);
  }

  Future<void> handleShowFileOpenFailedDialogWithName(BuildContext context) async {
    await showFileOpenFailedDialog(context, fileName: '/tmp/some/path/name.mp3');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () => handleAskForOverridingFileOnRecordingStart(context),
          child: const Text('Open askForOverridingFileOnRecordingStart'),
        ),
        TextButton(
          onPressed: () => handleAskForOverridingFileOnOpenFileSelection(context),
          child: const Text('Open askForOverridingFileOnOpenFileSelection'),
        ),
        TextButton(
          onPressed: () => handleShowTooManyFilesSelectedDialog(context),
          child: const Text('Open showTooManyFilesSelectedDialog'),
        ),
        TextButton(
          onPressed: () => handleShowMissingMicrophonePermissionDialog(context),
          child: const Text('Open showMissingMicrophonePermissionDialog'),
        ),
        TextButton(
          onPressed: () => handleShowFormatNotSupportedDialog(context),
          child: const Text('Open showFormatNotSupportedDialog'),
        ),
        TextButton(
          onPressed: () => handleShowFileOpenFailedDialogNoName(context),
          child: const Text('Open showFileOpenFailedDialog (no name)'),
        ),
        TextButton(
          onPressed: () => handleShowFileOpenFailedDialogWithName(context),
          child: const Text('Open showFileOpenFailedDialog (with name)'),
        ),
      ],
    );
  }
}

void main() {
  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  group('Media Player Dialogs', () {
    testWidgets('askForOverridingFileOnRecordingStart', (tester) async {
      await tester.renderWidget(TestWrapper());
      expect(find.bySemanticsLabel('Overwrite?'), findsNothing);

      await tester.tapAndSettle(find.bySemanticsLabel('Open askForOverridingFileOnRecordingStart'));

      expect(find.bySemanticsLabel('Overwrite?'), findsOneWidget);
    });

    testWidgets('askForOverridingFileOnOpenFileSelection', (tester) async {
      await tester.renderWidget(TestWrapper());
      expect(find.bySemanticsLabel('Overwrite?'), findsNothing);

      await tester.tapAndSettle(find.bySemanticsLabel('Open askForOverridingFileOnOpenFileSelection'));

      expect(find.bySemanticsLabel('Overwrite?'), findsOneWidget);
    });

    testWidgets('showTooManyFilesSelectedDialog', (tester) async {
      await tester.renderWidget(const TestWrapper());
      expect(find.byType(AlertDialog), findsNothing);

      await tester.tapAndSettle(find.bySemanticsLabel('Open showTooManyFilesSelectedDialog'));

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('showMissingMicrophonePermissionDialog', (tester) async {
      await tester.renderWidget(const TestWrapper());
      expect(find.byType(AlertDialog), findsNothing);

      await tester.tapAndSettle(find.bySemanticsLabel('Open showMissingMicrophonePermissionDialog'));

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('showFormatNotSupportedDialogmentions format', (tester) async {
      await tester.renderWidget(const TestWrapper());
      expect(find.byType(AlertDialog), findsNothing);

      await tester.tapAndSettle(find.bySemanticsLabel('Open showFormatNotSupportedDialog'));

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.textContaining('wav'), findsWidgets);
    });

    testWidgets('showFileOpenFailedDialog without file name', (tester) async {
      await tester.renderWidget(const TestWrapper());
      expect(find.byType(AlertDialog), findsNothing);

      await tester.tapAndSettle(find.bySemanticsLabel('Open showFileOpenFailedDialog (no name)'));

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.textContaining('name.mp3'), findsNothing);
    });

    testWidgets('showFileOpenFailedDialog with file name', (tester) async {
      await tester.renderWidget(const TestWrapper());
      expect(find.byType(AlertDialog), findsNothing);

      await tester.tapAndSettle(find.bySemanticsLabel('Open showFileOpenFailedDialog (with name)'));

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.textContaining('name.mp3'), findsWidgets);
    });
  });
}
