import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/widgets/metronome/rhythm_preset.dart';
import 'package:tiomusic/widgets/metronome/rhythm_preset_wheel.dart';

import '../../utils/action_utils.dart';
import '../../utils/render_utils.dart';

class TestWrapper extends StatefulWidget {
  final RhythmPresetKey presetKey;

  const TestWrapper({super.key, required this.presetKey});

  @override
  State<TestWrapper> createState() => _TestWrapperState();
}

class _TestWrapperState extends State<TestWrapper> {
  late RhythmPresetKey presetKey;

  @override
  void initState() {
    super.initState();
    presetKey = widget.presetKey;
  }

  Future<void> handlePresetSelect(RhythmPresetKey key) async {
    setState(() => presetKey = key);
  }

  @override
  Widget build(BuildContext context) {
    return RhythmPresetWheel(presetKey: presetKey, onSelect: handlePresetSelect);
  }
}

void main() {
  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  group('RhythmPresetWheel', () {
    testWidgets('shows given preset when valid preset key is given', (tester) async {
      await tester.renderWidget(TestWrapper(presetKey: RhythmPresetKey.oneFourth));

      expect(tester.getSemantics(find.bySemanticsLabel('Subdivision')).value, 'One-fourth note');
    });

    testWidgets('changes preset when tapping on other preset', (tester) async {
      await tester.renderWidget(TestWrapper(presetKey: RhythmPresetKey.oneFourth));

      await tester.tapAndSettle(find.bySemanticsLabel('Two-eighth note'));

      expect(tester.getSemantics(find.bySemanticsLabel('Subdivision')).value, 'Two-eighth note');
    });

    testWidgets('changes preset when dragging to next preset', (tester) async {
      await tester.renderWidget(TestWrapper(presetKey: RhythmPresetKey.oneFourth));

      await tester.dragFromCenterToTargetAndSettle(find.bySemanticsLabel('One-fourth note'), const Offset(-70, 0));

      expect(tester.getSemantics(find.bySemanticsLabel('Subdivision')).value, 'Two-eighth note');
    });

    testWidgets('changes preset when dragging to previous preset', (tester) async {
      await tester.renderWidget(TestWrapper(presetKey: RhythmPresetKey.twoEighth));

      await tester.dragFromCenterToTargetAndSettle(find.bySemanticsLabel('Two-eighth note'), const Offset(70, 0));

      expect(tester.getSemantics(find.bySemanticsLabel('Subdivision')).value, 'One-fourth note');
    });

    testWidgets('changes preset to last preset when dragging too the end', (tester) async {
      await tester.renderWidget(TestWrapper(presetKey: RhythmPresetKey.oneFourth));

      await tester.dragFromCenterToTargetAndSettle(find.bySemanticsLabel('One-fourth note'), const Offset(-140, 0));

      expect(tester.getSemantics(find.bySemanticsLabel('Subdivision')).value, 'Four-sixteenth note');
    });
  });
}
