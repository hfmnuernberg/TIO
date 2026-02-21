import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/pages/project_page/project_page.dart';

import '../../mocks/permission_handler_mock.dart';
import '../../utils/action_utils.dart';
import '../../utils/media_player_utils.dart';
import '../../utils/render_utils.dart';
import '../../utils/test_context.dart';

void main() {
  late TestContext context;
  late PermissionHandlerMock permissionHandlerMock;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    context = TestContext();

    permissionHandlerMock = PermissionHandlerMock()..grant();
    PermissionHandlerPlatform.instance = permissionHandlerMock;

    await context.init(project: Project.defaultThumbnail('Test Project'));
  });

  group('MediaPlayerTool - recording', () {
    testWidgets('shows warning when microphone permission is missing', (tester) async {
      permissionHandlerMock.deny();
      await tester.renderScaffold(ProjectPage(goStraightToTool: false, withoutRealProject: false), context.providers);
      await tester.createMediaPlayerToolInProject();
      await tester.tapAndSettle(find.bySemanticsLabel('Media Player 1'));

      await tester.tapAndSettle(find.byTooltip('Start recording'));
      expect(find.textContaining('Missing permission'), findsOneWidget);

      await tester.tapAndSettle(find.bySemanticsLabel('Got it'));
      expect(find.textContaining('Missing permission'), findsNothing);
    });
  });
}
