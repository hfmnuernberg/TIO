import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/loop_mode.dart';
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

  @override
  void initState() {
    super.initState();
    _mediaPlayerBlock = Provider.of<ProjectBlock>(context, listen: false) as MediaPlayerBlock;
  }

  String _getTooltip(BuildContext context) {
    final l10n = context.l10n;
    if (_mediaPlayerBlock.loopMode == LoopMode.one) return l10n.mediaPlayerLooping;
    if (_mediaPlayerBlock.loopMode == LoopMode.all) return l10n.mediaPlayerLoopingAll;
    return l10n.mediaPlayerLoopingNothing;
  }

  Icon _getIcon() {
    if (_mediaPlayerBlock.loopMode == LoopMode.one) {
      return const Icon(Icons.repeat_one, color: ColorTheme.tertiary);
    } else if (_mediaPlayerBlock.loopMode == LoopMode.all) {
      return const Icon(Icons.repeat, color: ColorTheme.tertiary);
    } else {
      return const Icon(Icons.repeat, color: ColorTheme.surfaceTint);
    }
  }

  void _setNoLoop() => _mediaPlayerBlock.loopMode = LoopMode.none;
  void _setLoopOne() => _mediaPlayerBlock.loopMode = LoopMode.one;
  void _setLoopAll() => _mediaPlayerBlock.loopMode = LoopMode.all;

  void _cycleLoopState() => switch (_mediaPlayerBlock.loopMode) {
    LoopMode.none => _setLoopOne(),
    LoopMode.one => _setLoopAll(),
    LoopMode.all => _setNoLoop(),
  };

  Future<void> _onLoopPressed() async {
    setState(_cycleLoopState);
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(tooltip: _getTooltip(context), icon: _getIcon(), onPressed: _onLoopPressed);
  }
}
