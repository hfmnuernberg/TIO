import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/widgets/metronome/rhythm_preset.dart';
import 'package:tiomusic/widgets/metronome/rhythm_preset_wheel.dart';

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
    return Column(
      children: [
        Semantics(
          label: 'Preset key',
          value: presetKey.assetName,
          excludeSemantics: true,
          child: RhythmPresetWheel(presetKey: presetKey, onSelect: handlePresetSelect),
        ),
      ],
    );
  }
}

void main() {
  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  group('RhythmPresetWheel', () {
    testWidgets('shows given preset key when preset is given', (tester) async {
      await tester.renderWidget(TestWrapper(presetKey: RhythmPresetKey.oneFourth));

      expect(tester.getSemantics(find.bySemanticsLabel('Preset key')).value, RhythmPresetKey.oneFourth.assetName);
    });
  });
}
