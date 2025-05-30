import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/metronome/rhythm_preset.dart';

class RhythmPresetWheel extends StatefulWidget {
  final void Function(RhythmPresetKey key) onPresetSelected;
  final RhythmPresetKey presetKey;

  const RhythmPresetWheel({super.key, required this.presetKey, required this.onPresetSelected});

  @override
  State<RhythmPresetWheel> createState() => _RhythmPresetWheelState();
}

class _RhythmPresetWheelState extends State<RhythmPresetWheel> {
  late final FixedExtentScrollController _wheelController;

  @override
  void initState() {
    super.initState();
    final currentIndex = RhythmPresetKey.values.indexOf(widget.presetKey);
    _wheelController = FixedExtentScrollController(initialItem: currentIndex == -1 ? 0 : currentIndex);
  }

  @override
  void dispose() {
    _wheelController.dispose();
    super.dispose();
  }

  void handleSelectPreset(int index) {
    _wheelController.animateToItem(index, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    widget.onPresetSelected(RhythmPresetKey.values[index]);
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: RotatedBox(
                quarterTurns: -1,
                child: ListWheelScrollView.useDelegate(
                  controller: _wheelController,
                  itemExtent: 70,
                  perspective: 0.008,
                  physics: const FixedExtentScrollPhysics(),
                  overAndUnderCenterOpacity: 0.6,
                  onSelectedItemChanged: handleSelectPreset,
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: RhythmPresetKey.values.length,
                    builder: (context, index) {
                      final key = RhythmPresetKey.values[index];
                      return RotatedBox(
                        quarterTurns: 1,
                        child: GestureDetector(
                          onTap: () => handleSelectPreset(index),
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
