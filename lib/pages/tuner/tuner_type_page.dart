import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/tuner_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/models/tuner_type.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/color_constants.dart';

class TunerTypePage extends StatefulWidget {
  const TunerTypePage({super.key});

  @override
  State<TunerTypePage> createState() => _TunerTypePageState();
}

class _TunerTypePageState extends State<TunerTypePage> {
  late TunerBlock _tunerBlock;
  final List<bool> _selectedTuners = List.filled(TunerType.values.length, false);

  @override
  void initState() {
    super.initState();
    _tunerBlock = Provider.of<ProjectBlock>(context, listen: false) as TunerBlock;
    _selectedTuners[_tunerBlock.tunerType.index] = true;
  }

  Future<void> _onConfirm() async {
    final selectedIndex = _selectedTuners.indexWhere((element) => element);
    _tunerBlock.tunerType = TunerType.values[selectedIndex];
    await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _reset() {
    for (int i = 0; i < _selectedTuners.length; i++) {
      _selectedTuners[i] = i == TunerType.chromatic.index;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ParentSettingPage(
      title: context.l10n.tunerSelectType,
      confirm: _onConfirm,
      reset: _reset,
      customWidget: Center(
        child: ToggleButtons(
          direction: Axis.vertical,
          constraints: const BoxConstraints(minHeight: 30, minWidth: 200),
          onPressed: (index) {
            setState(() {
              for (int i = 0; i < _selectedTuners.length; i++) {
                _selectedTuners[i] = i == index;
              }
            });
          },
          isSelected: _selectedTuners,
          children:
              TunerType.values
                  .map((type) => Text(type.getLabel(context.l10n), style: const TextStyle(color: ColorTheme.primary)))
                  .toList(),
        ),
      ),
    );
  }
}
