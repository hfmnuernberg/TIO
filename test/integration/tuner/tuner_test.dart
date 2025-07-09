import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/tuner_type.dart';
import 'package:tiomusic/pages/project_page/project_page.dart';

import '../../utils/action_utils.dart';
import '../../utils/project_utils.dart';
import '../../utils/render_utils.dart';
import '../../utils/test_context.dart';

extension WidgetTesterTunerExtension on WidgetTester {
  void expectSelectedTuner(TunerType expected) {
    final selected = widget<ToggleButtons>(find.byType(ToggleButtons)).isSelected;

    for (int i = 0; i < selected.length; i++) {
      if (i == expected.index) {
        expect(selected[i], isTrue, reason: 'Expected ${expected.name} to be selected');
      } else {
        expect(selected[i], isFalse, reason: 'Expected only ${expected.name} to be selected');
      }
    }
  }

  Future<void> openTunerAndInstrumentOption() async {
    await tapAndSettle(find.bySemanticsLabel('Tuner 1'));
    await pumpAndSettle(const Duration(milliseconds: 1100));
    await ensureVisible(find.bySemanticsLabel('Instrument'));
    await tapAndSettle(find.bySemanticsLabel('Instrument'));
  }
}

void main() {
  late TestContext context;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    context = TestContext();
    await context.init(project: Project.defaultThumbnail('Test Project'));
  });

  group('TunerTool', () {
    group('change instrument', () {
      testWidgets('instrument is selected initially', (tester) async {
        await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
        await tester.createTunerToolInProject();

        await tester.openTunerAndInstrumentOption();

        tester.expectSelectedTuner(TunerType.chromatic);
      });

      testWidgets('changes instrument on tap', (tester) async {
        await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
        await tester.createTunerToolInProject();

        await tester.openTunerAndInstrumentOption();

        tester.expectSelectedTuner(TunerType.chromatic);

        await tester.tapAndSettle(find.bySemanticsLabel('Guitar'));

        tester.expectSelectedTuner(TunerType.guitar);
      });

      testWidgets('resets instrument on reset button tap', (tester) async {
        await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
        await tester.createTunerToolInProject();

        await tester.openTunerAndInstrumentOption();

        await tester.tapAndSettle(find.bySemanticsLabel('Guitar'));
        tester.expectSelectedTuner(TunerType.guitar);

        await tester.tapAndSettle(find.bySemanticsLabel('Reset'));
        tester.expectSelectedTuner(TunerType.chromatic);
      });

      testWidgets('saves selected instrument on accept button tap', (tester) async {
        await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
        await tester.createTunerToolInProject();

        await tester.openTunerAndInstrumentOption();

        await tester.tapAndSettle(find.bySemanticsLabel('Guitar'));
        tester.expectSelectedTuner(TunerType.guitar);

        await tester.tapAndSettle(find.bySemanticsLabel('Submit'));
        await tester.ensureVisible(find.bySemanticsLabel('Instrument'));
        await tester.tapAndSettle(find.bySemanticsLabel('Instrument'));

        tester.expectSelectedTuner(TunerType.guitar);
      });

      testWidgets('cancels selected instrument on cancel button tap', (tester) async {
        await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
        await tester.createTunerToolInProject();

        await tester.openTunerAndInstrumentOption();

        await tester.tapAndSettle(find.bySemanticsLabel('Guitar'));
        tester.expectSelectedTuner(TunerType.guitar);

        await tester.tapAndSettle(find.bySemanticsLabel('Cancel'));
        await tester.ensureVisible(find.bySemanticsLabel('Instrument'));
        await tester.tapAndSettle(find.bySemanticsLabel('Instrument'));

        tester.expectSelectedTuner(TunerType.chromatic);
      });
    });
  });
}
