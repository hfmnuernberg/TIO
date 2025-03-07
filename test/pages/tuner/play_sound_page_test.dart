import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/blocks/tuner_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/pages/tuner/play_sound_page.dart';

extension WidgetTesterPumpExtension on WidgetTester {
  Future<void> renderWidget(Widget widget) async {
    await pumpWidget(
      ChangeNotifierProvider<ProjectBlock>.value(
        value: TunerBlock.withDefaults(),
        child: MaterialApp(
          home: Scaffold(
            body: widget,
          ),
        ),
      ),
    );
    await pumpAndSettle();
  }
}


void main() {
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
  });

  group('tuner - play sound page', () {
    testWidgets('shows frequency when clicking sound button', (tester) async {
      await tester.renderWidget(PlaySoundPage());

      debugDumpSemanticsTree();
      expect(tester.getSemantics(find.bySemanticsLabel('Octave input')).value, '4');
    });
  });
}
