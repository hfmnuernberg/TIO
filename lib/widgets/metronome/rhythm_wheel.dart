import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/rhythm.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/rhythm_extension.dart';

class RhythmWheel extends StatefulWidget {
  final Rhythm rhythm;
  final void Function(Rhythm key) onSelect;

  const RhythmWheel({super.key, required this.rhythm, required this.onSelect});

  @override
  State<RhythmWheel> createState() => _RhythmWheelState();
}

class _RhythmWheelState extends State<RhythmWheel> {
  late final FixedExtentScrollController controller;

  @override
  void initState() {
    super.initState();
    controller = FixedExtentScrollController(initialItem: indexOfOrThrow(Rhythm.values, widget.rhythm));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void handleSelect(int index) {
    controller.animateToItem(index, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    widget.onSelect(Rhythm.values[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Container(
            height: 78,
            width: 160,
            decoration: BoxDecoration(color: ColorTheme.surface, borderRadius: BorderRadius.circular(16)),
            child: Semantics(
              label: context.l10n.metronomeRhythmPattern,
              value: widget.rhythm.getLabel(context.l10n),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: RotatedBox(
                  quarterTurns: -1,
                  child: ListWheelScrollView.useDelegate(
                    controller: controller,
                    itemExtent: 90,
                    perspective: 0.007,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: handleSelect,
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: Rhythm.values.length,
                      builder: (context, index) {
                        final key = Rhythm.values[index];
                        return RotatedBox(
                          quarterTurns: 1,
                          child: GestureDetector(
                            onTap: () => handleSelect(index),
                            child: RhythmIconWidget(rhythm: key),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Semantics(
          excludeSemantics: true,
          child: Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(context.l10n.metronomeRhythmPattern, style: const TextStyle(color: ColorTheme.primary)),
          ),
        ),
      ],
    );
  }
}

class RhythmIconWidget extends StatelessWidget {
  final Rhythm rhythm;

  const RhythmIconWidget({super.key, required this.rhythm});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: rhythm.getLabel(context.l10n),
      child: SvgPicture.asset(
        'assets/rhythms/${rhythm.assetName}.svg',
        height: 50,
        colorFilter: const ColorFilter.mode(ColorTheme.surfaceTint, BlendMode.srcIn),
      ),
    );
  }
}

int indexOfOrThrow<T>(List<T> list, T value) {
  final index = list.indexOf(value);
  if (index == -1) throw StateError('Value not found in list: $value');
  return index;
}
