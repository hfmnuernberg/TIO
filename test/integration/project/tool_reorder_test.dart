import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/pages/project_page/project_page.dart';

import '../../utils/action_utils.dart';
import '../../utils/project_utils.dart';
import '../../utils/render_utils.dart';
import '../../utils/test_context.dart';

extension WidgetTesterToolOrderExtension on WidgetTester {
  double _verticalPositionOf(String toolTitle) => getTopLeft(find.textContaining(toolTitle).first).dy;

  List<String> toolTitlesInVisualOrder(List<String> toolTitles) {
    final sorted = [...toolTitles];
    sorted.sort((one, other) => _verticalPositionOf(one).compareTo(_verticalPositionOf(other)));
    return sorted;
  }

  Future<void> startEditingTools() async {
    await tapAndSettle(find.byTooltip('Project menu'));
    await tapAndSettle(find.bySemanticsLabel('Edit tools'));
  }

  Future<void> dragToolHandle(int handleIndex, double verticalOffset) async =>
      dragFromCenterToTargetAndSettle(find.byTooltip('Reorder').at(handleIndex), Offset(0, verticalOffset));
}

void main() {
  late TestContext context;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    context = TestContext();
    await context.init(project: Project.defaultThumbnail('Test Project'));
  });

  Future<void> renderProjectWithThreeTools(WidgetTester tester) async {
    await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);

    await tester.createTextToolInProject('Text 1');
    await tester.tapAndSettle(find.byTooltip('Add new tool'));
    await tester.createTextToolInProject('Text 2');
    await tester.tapAndSettle(find.byTooltip('Add new tool'));
    await tester.createTextToolInProject('Text 3');
  }

  const allTools = ['Text 1', 'Text 2', 'Text 3'];

  group('tool reordering', () {
    testWidgets('shows newest tool first', (tester) async {
      await renderProjectWithThreeTools(tester);

      expect(tester.toolTitlesInVisualOrder(allTools), equals(['Text 3', 'Text 2', 'Text 1']));
    });

    testWidgets('keeps order when tool is dragged too little', (tester) async {
      await renderProjectWithThreeTools(tester);
      await tester.startEditingTools();

      await tester.dragToolHandle(0, 10);

      expect(tester.toolTitlesInVisualOrder(allTools), equals(['Text 3', 'Text 2', 'Text 1']));
    });

    testWidgets('moves first tool to the end when dragged to the bottom', (tester) async {
      await renderProjectWithThreeTools(tester);
      await tester.startEditingTools();

      await tester.dragToolHandle(0, 500);

      expect(tester.toolTitlesInVisualOrder(allTools), equals(['Text 2', 'Text 1', 'Text 3']));
    });

    testWidgets('moves last tool to the start when dragged to the top', (tester) async {
      await renderProjectWithThreeTools(tester);
      await tester.startEditingTools();

      await tester.dragToolHandle(2, -500);

      expect(tester.toolTitlesInVisualOrder(allTools), equals(['Text 1', 'Text 3', 'Text 2']));
    });

    testWidgets('moves middle tool to the end when dragged to the bottom', (tester) async {
      await renderProjectWithThreeTools(tester);
      await tester.startEditingTools();

      await tester.dragToolHandle(1, 500);

      expect(tester.toolTitlesInVisualOrder(allTools), equals(['Text 3', 'Text 1', 'Text 2']));
    });
  });
}
