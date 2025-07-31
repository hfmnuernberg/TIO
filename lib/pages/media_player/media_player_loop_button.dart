import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/util/color_constants.dart';

class MediaPlayerLoopButton extends StatefulWidget {
  const MediaPlayerLoopButton({super.key});

  @override
  State<MediaPlayerLoopButton> createState() => _MediaPlayerLoopButtonState();
}

class _MediaPlayerLoopButtonState extends State<MediaPlayerLoopButton> {
  late AudioSystem _as;
  late ProjectRepository _projectRepo;
  late MediaPlayerBlock _mediaPlayerBlock;

  @override
  void initState() {
    super.initState();

    _as = context.read<AudioSystem>();
    _projectRepo = context.read<ProjectRepository>();
    _mediaPlayerBlock = Provider.of<ProjectBlock>(context, listen: false) as MediaPlayerBlock;
  }

  String _loopTooltip(BuildContext context) {
    final l10n = context.l10n;
    if (_mediaPlayerBlock.looping) return l10n.mediaPlayerLooping;
    if (_mediaPlayerBlock.loopingAll) return l10n.mediaPlayerLoopingAll;
    return l10n.mediaPlayerLoopingNothing;
  }

  Icon _loopIcon() {
    if (_mediaPlayerBlock.looping) {
      return const Icon(Icons.repeat_one, color: ColorTheme.tertiary);
    } else if (_mediaPlayerBlock.loopingAll) {
      return const Icon(Icons.repeat, color: ColorTheme.tertiary);
    } else {
      return const Icon(Icons.repeat, color: ColorTheme.surfaceTint);
    }
  }

  void _setLoopOne() {
    _mediaPlayerBlock.looping = true;
    _mediaPlayerBlock.loopingAll = false;
  }

  void _setLoopAll() {
    _mediaPlayerBlock.looping = false;
    _mediaPlayerBlock.loopingAll = true;
  }

  void _setNoLoop() {
    _mediaPlayerBlock.looping = false;
    _mediaPlayerBlock.loopingAll = false;
  }

  void _cycleLoopState() {
    if (!_mediaPlayerBlock.looping && !_mediaPlayerBlock.loopingAll) {
      _setLoopOne();
    } else if (_mediaPlayerBlock.looping && !_mediaPlayerBlock.loopingAll) {
      _setLoopAll();
    } else {
      _setNoLoop();
    }
  }

  Future<void> _onLoopPressed() async {
    setState(_cycleLoopState);
    await _projectRepo.saveLibrary(context.read<ProjectLibrary>());
    _as.mediaPlayerSetLoop(looping: _mediaPlayerBlock.looping);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(tooltip: _loopTooltip(context), icon: _loopIcon(), onPressed: _onLoopPressed);
  }
}
