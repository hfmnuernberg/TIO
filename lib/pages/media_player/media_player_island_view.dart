import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/domain/audio/player.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/pages/media_player/media_player_dialogs.dart';
import 'package:tiomusic/pages/media_player/waveform_visualizer.dart';
import 'package:tiomusic/pages/parent_tool/parent_inner_island.dart';
import 'package:tiomusic/services/audio_session.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/wakelock.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants/constants.dart';

class MediaPlayerIslandView extends StatefulWidget {
  final MediaPlayerBlock mediaPlayerBlock;

  const MediaPlayerIslandView({super.key, required this.mediaPlayerBlock});

  @override
  State<MediaPlayerIslandView> createState() => _MediaPlayerIslandViewState();
}

class _MediaPlayerIslandViewState extends State<MediaPlayerIslandView> {
  late FileSystem _fs;
  late WaveformVisualizer _waveformVisualizer;

  late final Player _player;
  Player? _primaryPlayer;

  Float32List _rmsValues = Float32List(100);
  int _numOfBins = 0;

  var _isLoading = false;

  final GlobalKey _customPaintKey = GlobalKey();

  bool _processingButtonClick = false;

  @override
  void initState() {
    super.initState();

    _fs = context.read<FileSystem>();

    _player = Player(
      context.read<AudioSystem>(),
      context.read<AudioSession>(),
      context.read<FileSystem>(),
      context.read<Wakelock>(),
    );

    _primaryPlayer = context.read<Player?>();

    _player.addOnIsPlayingChangeListener((_) {
      if (!mounted) return;
      setState(() {});
    });
    _player.addOnPlaybackPositionChangeListener((_) {
      if (!mounted) return;
      setState(() {
        _waveformVisualizer = WaveformVisualizer(
          _player.playbackPosition,
          widget.mediaPlayerBlock.rangeStart,
          widget.mediaPlayerBlock.rangeEnd,
          _rmsValues,
        );
      });
    });

    _waveformVisualizer = WaveformVisualizer(
      0,
      widget.mediaPlayerBlock.rangeStart,
      widget.mediaPlayerBlock.rangeEnd,
      _rmsValues,
    );

    _player.setVolume(widget.mediaPlayerBlock.volume);
    _player.setPitch(widget.mediaPlayerBlock.pitchSemitones);
    _player.setSpeed(widget.mediaPlayerBlock.speedFactor);
    _player.setRepeat(widget.mediaPlayerBlock.looping);
    _player.markers.positions = widget.mediaPlayerBlock.markerPositions;
    _player.setTrim(widget.mediaPlayerBlock.rangeStart, widget.mediaPlayerBlock.rangeEnd);

    if (_primaryPlayer != null) {
      _primaryPlayer!.addOnIsPlayingChangeListener(_onPrimaryIsPlayingChange);
      _primaryPlayer!.addOnSeekListener(_onPrimarySeek);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _initBinsAndLoadRms());
  }

  @override
  void deactivate() {
    _primaryPlayer?.removeOnIsPlayingChangeListener(_onPrimaryIsPlayingChange);
    _primaryPlayer?.removeOnSeekListener(_onPrimarySeek);
    _player.dispose();
    super.deactivate();
  }

  void _onPrimaryIsPlayingChange(bool primaryIsPlaying) async {
    if (!_player.loaded) return;

    if (primaryIsPlaying && !_player.isPlaying) {
      await _player.setPlaybackPosition(_player.startPosition);
      await _player.start();
    } else if (!primaryIsPlaying && _player.isPlaying) {
      await _player.stop();
    }
  }

  void _onPrimarySeek(double primaryPosFactor) async {
    if (!_player.loaded || _primaryPlayer == null) return;

    final secondaryPosition = _mapPrimaryToSecondaryPosition(primaryPosFactor);
    if (secondaryPosition == null) return;

    if (_isOutsideSecondaryTrim(secondaryPosition)) {
      if (_player.isPlaying) await _player.stop();
    } else {
      await _player.setPlaybackPosition(secondaryPosition.clamp(0.0, 1.0));
    }
  }

  double? _mapPrimaryToSecondaryPosition(double primaryPosFactor) {
    final primaryTotalMs = _primaryPlayer!.fileDuration.inMilliseconds;
    final secondaryTotalMs = _player.fileDuration.inMilliseconds;
    if (primaryTotalMs <= 0 || secondaryTotalMs <= 0) return null;

    final elapsedMs = _elapsedMsFromTrimStart(primaryPosFactor, primaryTotalMs);
    final secondaryElapsedFactor = elapsedMs / secondaryTotalMs;
    return _player.startPosition + secondaryElapsedFactor;
  }

  double _elapsedMsFromTrimStart(double positionFactor, int totalMs) {
    return (positionFactor - _primaryPlayer!.startPosition) * totalMs;
  }

  bool _isOutsideSecondaryTrim(double position) => position > _player.endPosition;

  Future<void> _initBinsAndLoadRms() async {
    final ctx = _customPaintKey.currentContext;
    final renderBox = ctx?.findRenderObject() as RenderBox?;
    if (renderBox == null || renderBox.size.width <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _initBinsAndLoadRms());
      return;
    }

    _numOfBins = WaveformVisualizer.calculateBinCountForWidth(renderBox.size.width);

    if (mounted) setState(() => _isLoading = true);

    final fileExtension = _fs.toExtension(widget.mediaPlayerBlock.relativePath);
    if (mounted && fileExtension != null && !TIOMusicParams.audioFormats.contains(fileExtension)) {
      await showFormatNotSupportedDialog(context, fileExtension);
    }

    if (widget.mediaPlayerBlock.relativePath.isNotEmpty) {
      final success = await _player.loadAudioFile(_fs.toAbsoluteFilePath(widget.mediaPlayerBlock.relativePath));
      if (success) {
        _rmsValues = await _player.getRmsValues(_numOfBins);
        if (!mounted) return;
        setState(() {
          _waveformVisualizer = WaveformVisualizer(
            0,
            widget.mediaPlayerBlock.rangeStart,
            widget.mediaPlayerBlock.rangeEnd,
            _rmsValues,
          );
        });
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _togglePlaying() async {
    if (_processingButtonClick) return;
    setState(() => _processingButtonClick = true);

    if (_player.isPlaying) {
      await _player.stop();
    } else {
      await _player.start();
    }

    await Future.delayed(const Duration(milliseconds: TIOMusicParams.millisecondsPlayPauseDebounce));
    setState(() => _processingButtonClick = false);
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
      centerView: _isLoading ? const Center(child: CircularProgressIndicator()) : _waveformVisualizer,
      customPaintKey: _customPaintKey,
      textSpaceWidth: 70,
    );
  }
}
