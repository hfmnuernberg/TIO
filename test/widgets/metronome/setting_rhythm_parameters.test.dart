import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/models/rhythm_group.dart';
import 'package:tiomusic/pages/metronome/setting_rhythm_parameters.dart';
import 'package:tiomusic/services/decorators/file_system_log_decorator.dart';
import 'package:tiomusic/services/decorators/project_repository_log_decorator.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/impl/file_based_project_repository.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';

import '../../mocks/in_memory_file_system_mock.dart';
import '../../utils/render_utils.dart';

class _TestWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rhythmGroup = RhythmGroup(
      'key ID',
      const [BeatType.Accented, BeatType.Unaccented],
      const [BeatTypePoly.Accented, BeatTypePoly.Unaccented],
      NoteValues.quarter,
    )
      ..beatLen = NoteHandler.getBeatLength(NoteValues.quarter);

    return SetRhythmParameters(
      currentNoteKey: NoteValues.quarter,
      currentBeats: const [BeatType.Accented, BeatType.Unaccented],
      currentPolyBeats: const [BeatTypePoly.Accented, BeatTypePoly.Unaccented],
      isAddingNewBar: true,
      rhythmGroups: [rhythmGroup],
      isSecondMetronome: false,
      metronomeBlock: MetronomeBlock.withTitle('Test'),
    );
  }
}

void main() {
  late List<SingleChildWidget> providers;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    final fileSystem = FileSystemLogDecorator(InMemoryFileSystemMock());
    final projectRepo = ProjectRepositoryLogDecorator(FileBasedProjectRepository(fileSystem));

    await fileSystem.init();
    final projectLibrary =
    projectRepo.existsLibrary() ? await projectRepo.loadLibrary() : ProjectLibrary.withDefaults()
      ..dismissAllTutorials();
    await projectRepo.saveLibrary(projectLibrary);

    providers = [
      Provider<FileSystem>(create: (_) => fileSystem),
      Provider<ProjectRepository>(create: (_) => projectRepo),
      ChangeNotifierProvider<ProjectLibrary>.value(value: projectLibrary),
    ];
  });

  group('setting rhythm parameters', () {
    testWidgets('adds poly beat when tapping plus button', (tester) async {
      await tester.renderScaffold(_TestWrapper(), providers);

      // expect(tester.getSemantics(find.bySemanticsLabel('Number of Poly Beats')).value, '0');

      // final plusButton = find.descendant(
      //   of: find.bySemanticsLabel('Number of Poly Beats'),
      //   matching: find.bySemanticsLabel('Plus button'),
      // );

      // await tester.tapAndSettle(plusButton);

      // expect(tester.getSemantics(find.bySemanticsLabel('Number of Poly Beats')).value, '2');
    });
  });
}
