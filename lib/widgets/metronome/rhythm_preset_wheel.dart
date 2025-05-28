import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/metronome/rhythm_preset.dart';

class NoteIconWidget extends StatelessWidget {
  final RhythmPresetKey presetKey;

  const NoteIconWidget({super.key, required this.presetKey});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/metronome_presets/${presetKey.assetName}.svg',
      height: 50,
      colorFilter: const ColorFilter.mode(ColorTheme.surfaceTint, BlendMode.srcIn),
    );
  }
}

class RhythmPresetWheel extends StatelessWidget {
  final FixedExtentScrollController controller;
  final List<RhythmPresetKey> wheelNoteKeys;
  final void Function(RhythmPresetKey key) onPresetSelected;

  const RhythmPresetWheel({
    super.key,
    required this.controller,
    required this.wheelNoteKeys,
    required this.onPresetSelected,
  });

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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: RotatedBox(
                quarterTurns: -1,
                child: ListWheelScrollView.useDelegate(
                  controller: controller,
                  itemExtent: 70,
                  perspective: 0.008,
                  physics: const FixedExtentScrollPhysics(),
                  overAndUnderCenterOpacity: 0.6,
                  onSelectedItemChanged: (index) => onPresetSelected(wheelNoteKeys[index]),
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: wheelNoteKeys.length,
                    builder: (context, index) {
                      final key = wheelNoteKeys[index];
                      return RotatedBox(
                        quarterTurns: 1,
                        child: GestureDetector(
                          onTap: () {
                            controller.animateToItem(
                              index,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                            onPresetSelected(key);
                          },
                          child: NoteIconWidget(presetKey: key),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(context.l10n.metronomeSubdivision, style: const TextStyle(color: ColorTheme.primary)),
        ),
      ],
    );
  }
}
