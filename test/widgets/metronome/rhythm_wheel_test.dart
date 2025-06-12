import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/models/rhythm.dart';
import 'package:tiomusic/widgets/metronome/rhythm_wheel.dart';

import '../../utils/action_utils.dart';
import '../../utils/render_utils.dart';

class StatefulRhythmWheel extends StatefulWidget {
  final Rhythm rhythm;

  const StatefulRhythmWheel({super.key, required this.rhythm});

  @override
  State<StatefulRhythmWheel> createState() => _StatefulRhythmWheelState();
}

class _StatefulRhythmWheelState extends State<StatefulRhythmWheel> {
  late Rhythm rhythm;

  @override
  void initState() {
    super.initState();
    rhythm = widget.rhythm;
  }

  Future<void> handleSelect(Rhythm rhythm) async {
    setState(() => this.rhythm = rhythm);
  }

  @override
  Widget build(BuildContext context) {
    return RhythmWheel(rhythm: rhythm, onSelect: handleSelect);
  }
}

void main() {
  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  group('RhythmWheel', () {
    testWidgets('shows given rhythm when valid rhythm is given', (tester) async {
      await tester.renderWidget(StatefulRhythmWheel(rhythm: Rhythm.quarter));

      expect(tester.getSemantics(find.bySemanticsLabel('Subdivision')).value, 'Quarter');
    });

    testWidgets('changes rhythm when tapping on other rhythm', (tester) async {
      await tester.renderWidget(StatefulRhythmWheel(rhythm: Rhythm.quarter));

      await tester.tapAndSettle(find.bySemanticsLabel('Eighths'));

      expect(tester.getSemantics(find.bySemanticsLabel('Subdivision')).value, 'Eighths');
    });

    testWidgets('changes rhythm when dragging to next rhythm', (tester) async {
      await tester.renderWidget(StatefulRhythmWheel(rhythm: Rhythm.quarter));

      await tester.dragFromCenterToTargetAndSettle(find.bySemanticsLabel('Quarter'), const Offset(-70, 0));

      expect(tester.getSemantics(find.bySemanticsLabel('Subdivision')).value, 'Eighths');
    });

    testWidgets('changes rhythm when dragging to previous rhythm', (tester) async {
      await tester.renderWidget(StatefulRhythmWheel(rhythm: Rhythm.eighths));

      await tester.dragFromCenterToTargetAndSettle(find.bySemanticsLabel('Eighths'), const Offset(70, 0));

      expect(tester.getSemantics(find.bySemanticsLabel('Subdivision')).value, 'Quarter');
    });

    testWidgets('changes rhythm to last rhythm when dragging too the end', (tester) async {
      await tester.renderWidget(StatefulRhythmWheel(rhythm: Rhythm.quarter));

      await tester.dragFromCenterToTargetAndSettle(find.bySemanticsLabel('Quarter'), const Offset(-140, 0));

      expect(tester.getSemantics(find.bySemanticsLabel('Subdivision')).value, 'Eighths');
    });
  });
}
