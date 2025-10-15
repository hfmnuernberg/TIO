import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/domain/audio/player.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/pages/media_player/media_player_functions.dart';
import 'package:tiomusic/pages/media_player/waveform_visualizer.dart';
import 'package:tiomusic/pages/parent_tool/parent_inner_island.dart';
import 'package:tiomusic/services/audio_session.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/wakelock.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';

class MediaPlayerIslandView extends StatefulWidget {
  final MediaPlayerBlock mediaPlayerBlock;

  const MediaPlayerIslandView({super.key, required this.mediaPlayerBlock});

  @override
  State<MediaPlayerIslandView> createState() => _MediaPlayerIslandViewState();
}

class _MediaPlayerIslandViewState extends State<MediaPlayerIslandView> {
  late AudioSystem _as;
  late FileSystem _fs;
  late Wakelock _wakelock;
  late WaveformVisualizer _waveformVisualizer;

  late final Player _player;

  Float32List _rmsValues = Float32List(100);
  int numOfBins = 0;

  var _isLoading = false;

  Timer? _timerPollPlaybackPosition;

  GlobalKey globalKeyCustomPaint = GlobalKey();

  bool _processingButtonClick = false;

  @override
  void initState() {
    super.initState();

    _as = context.read<AudioSystem>();
    _fs = context.read<FileSystem>();
    _wakelock = context.read<Wakelock>();
    _as.mediaPlayerSetVolume(volume: widget.mediaPlayerBlock.volume);

    _player = Player(
      context.read<AudioSystem>(),
      context.read<AudioSession>(),
      context.read<FileSystem>(),
      context.read<Wakelock>(),
    );

    _waveformVisualizer = WaveformVisualizer(
      0,
      widget.mediaPlayerBlock.rangeStart,
      widget.mediaPlayerBlock.rangeEnd,
      _rmsValues,
      0,
    );

    _player.setPitch(widget.mediaPlayerBlock.pitchSemitones);
    _player.setSpeed(widget.mediaPlayerBlock.speedFactor);
    _player.setRepeat(widget.mediaPlayerBlock.looping);
    _player.markers.positions = widget.mediaPlayerBlock.markerPositions;
    _player.setTrim(widget.mediaPlayerBlock.rangeStart, widget.mediaPlayerBlock.rangeEnd);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final fs = context.read<FileSystem>();
      var customPaintContext = globalKeyCustomPaint.currentContext;
      if (customPaintContext != null) {
        final customPaintRenderBox = customPaintContext.findRenderObject()! as RenderBox;
        numOfBins = (customPaintRenderBox.size.width / MediaPlayerParams.binWidth).floor();
      } else {
        throw "WARNING: couldn't set numOfBins because the custom painter context was null!";
      }

      setState(() {
        _isLoading = true;
      });
      final fileExtension = fs.toExtension(widget.mediaPlayerBlock.relativePath);
      if (mounted && fileExtension != null && !TIOMusicParams.audioFormats.contains(fileExtension)) {
        await showFormatNotSupportedDialog(context, fileExtension);
      }

      if (widget.mediaPlayerBlock.relativePath.isNotEmpty) {
        final success = await _player.loadAudioFile(_fs.toAbsoluteFilePath(widget.mediaPlayerBlock.relativePath));
        if (!success) {
          _rmsValues = await _player.getRmsValues(numOfBins);

          // this return is to prevent the call of setState if user exits media player while isLoading
          if (!mounted) return;
          setState(() {
            _waveformVisualizer = WaveformVisualizer(
              0,
              widget.mediaPlayerBlock.rangeStart,
              widget.mediaPlayerBlock.rangeEnd,
              _rmsValues,
              numOfBins,
            );
          });
        }
      }

      // this return is to prevent the call of setState if user exits media player while isLoading
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    });

    _timerPollPlaybackPosition = Timer.periodic(const Duration(milliseconds: 120), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (!_player.isPlaying) return;

      setState(() {
        _waveformVisualizer = WaveformVisualizer(
          _player.playbackPosition,
          widget.mediaPlayerBlock.rangeStart,
          widget.mediaPlayerBlock.rangeEnd,
          _rmsValues,
          numOfBins,
        );
      });
    });
  }

  @override
  Future<void> deactivate() async {
    await _player.stop();
    MediaPlayerFunctions.stopRecording(_as, _wakelock);

    _timerPollPlaybackPosition?.cancel();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return ParentInnerIsland(
      onMainIconPressed: _togglePlaying,
      mainIcon: _player.isPlaying
          ? const Icon(TIOMusicParams.pauseIcon, color: ColorTheme.primary)
          : widget.mediaPlayerBlock.icon,
      mainButtonIsDisabled: _isLoading,
      parameterText: widget.mediaPlayerBlock.title,
      centerView: _isLoading
          // loading spinner
          ? const Center(child: CircularProgressIndicator())
          // waveform visualizer
          : _waveformVisualizer,
      customPaintKey: globalKeyCustomPaint,
      textSpaceWidth: 70,
    );
  }

  void _togglePlaying() async {
    if (_processingButtonClick) return;
    setState(() => _processingButtonClick = true);

    if (!_player.isPlaying) {
      await _player.start();
    } else {
      await _player.stop();
    }

    await Future.delayed(const Duration(milliseconds: TIOMusicParams.millisecondsPlayPauseDebounce));
    setState(() => _processingButtonClick = false);
  }
}
