import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/util/color_constants.dart';

class MediaPlayerRepeatButton extends StatefulWidget {
  final Function() onToggle;

  const MediaPlayerRepeatButton({super.key, required this.onToggle});

  @override
  State<MediaPlayerRepeatButton> createState() => _MediaPlayerRepeatButtonState();
}

class _MediaPlayerRepeatButtonState extends State<MediaPlayerRepeatButton> {
  late MediaPlayerBlock _mediaPlayerBlock;
  Project? _project;

  late bool hasProject;

  @override
  void initState() {
    super.initState();
    _mediaPlayerBlock = Provider.of<ProjectBlock>(context, listen: false) as MediaPlayerBlock;
    _project = context.read<Project?>();
    hasProject = _project != null;
  }

  bool _isRepeatAll() => hasProject && _project!.mediaPlayerRepeatAll;
  bool _isRepeatOne() => !_isRepeatAll() && _mediaPlayerBlock.looping;

  String _getTooltip(BuildContext context) {
    final l10n = context.l10n;
    if (_isRepeatAll()) return l10n.mediaPlayerRepeatAll;
    if (_isRepeatOne()) return l10n.mediaPlayerRepeatOne;
    return l10n.mediaPlayerRepeatOff;
  }

  Icon _getIcon() {
    if (_isRepeatAll()) return const Icon(Icons.repeat, color: ColorTheme.tertiary);
    if (_isRepeatOne()) return const Icon(Icons.repeat_one, color: ColorTheme.tertiary);
    return const Icon(Icons.repeat, color: ColorTheme.surfaceTint);
  }

  void _setRepeatOff() {
    _mediaPlayerBlock.looping = false;
    if (hasProject) _project!.mediaPlayerRepeatAll = false;
  }

  void _setRepeatOne() {
    _mediaPlayerBlock.looping = true;
    if (hasProject) _project!.mediaPlayerRepeatAll = false;
  }

  void _setRepeatAll() {
    _mediaPlayerBlock.looping = false;
    if (hasProject) _project!.mediaPlayerRepeatAll = true;
  }

  void _cycleRepeatState() {
    if (_isRepeatAll()) return _setRepeatOff();
    if (_isRepeatOne()) return _setRepeatAll();
    _setRepeatOne();
  }

  Future<void> _onRepeatPressed() async {
    setState(_cycleRepeatState);
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(tooltip: _getTooltip(context), icon: _getIcon(), onPressed: _onRepeatPressed);
  }
}
