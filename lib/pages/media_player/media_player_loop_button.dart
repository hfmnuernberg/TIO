import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/util/color_constants.dart';

class MediaPlayerLoopButton extends StatefulWidget {
  final Function() onToggle;

  const MediaPlayerLoopButton({super.key, required this.onToggle});

  @override
  State<MediaPlayerLoopButton> createState() => _MediaPlayerLoopButtonState();
}

class _MediaPlayerLoopButtonState extends State<MediaPlayerLoopButton> {
  late MediaPlayerBlock _mediaPlayerBlock;
  late Project _project;

  @override
  void initState() {
    super.initState();
    _mediaPlayerBlock = Provider.of<ProjectBlock>(context, listen: false) as MediaPlayerBlock;
    _project = context.read<Project>();
  }

  String _getTooltip(BuildContext context) {
    final l10n = context.l10n;
    if (_project.mediaPlayerRepeatAll) return l10n.mediaPlayerLoopingAll;
    if (_mediaPlayerBlock.looping) return l10n.mediaPlayerLooping;
    return l10n.mediaPlayerLoopingNothing;
  }

  Icon _getIcon() {
    if (_project.mediaPlayerRepeatAll) return const Icon(Icons.repeat, color: ColorTheme.tertiary);
    if (_mediaPlayerBlock.looping) return const Icon(Icons.repeat_one, color: ColorTheme.tertiary);
    return const Icon(Icons.repeat, color: ColorTheme.surfaceTint);
  }

  void _setNoLoop() {
    _mediaPlayerBlock.looping = false;
    _project.mediaPlayerRepeatAll = false;
  }

  void _setLoopOne() {
    _mediaPlayerBlock.looping = true;
    _project.mediaPlayerRepeatAll = false;
  }

  void _setLoopAll() {
    _mediaPlayerBlock.looping = false;
    _project.mediaPlayerRepeatAll = true;
  }

  void _cycleLoopState() {
    if (!_mediaPlayerBlock.looping && !_project.mediaPlayerRepeatAll) {
      _setLoopOne();
    } else if (_mediaPlayerBlock.looping && !_project.mediaPlayerRepeatAll) {
      _setLoopAll();
    } else {
      _setNoLoop();
    }
  }

  Future<void> _onLoopPressed() async {
    setState(_cycleLoopState);
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(tooltip: _getTooltip(context), icon: _getIcon(), onPressed: _onLoopPressed);
  }
}
