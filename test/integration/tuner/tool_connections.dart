import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/pages/project_page/project_page.dart';

import '../../utils/action_utils.dart';
import '../../utils/project_utils.dart';
import '../../utils/render_utils.dart';
import '../../utils/test_context.dart';

void main() {
  late TestContext context;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    context = TestContext();
    await context.init(project: Project.defaultThumbnail('Test Project'));
  });

  group('TunerTool - connections to other tools', () {
    testWidgets('provides connection possibility', (tester) async {
      await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
      await tester.createTunerToolInProject();

      await tester.tapAndSettle(find.bySemanticsLabel('Tuner 1'));
      await tester.pumpAndSettle(const Duration(milliseconds: 1100));

      expect(find.byTooltip('Connect another tool'), findsOneWidget);
    });
  });
}
