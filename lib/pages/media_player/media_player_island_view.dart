import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
import 'package:tiomusic/util/log.dart';
import 'package:tiomusic/util/util_functions.dart';

class MediaPlayerIslandView extends StatefulWidget {
  final MediaPlayerBlock mediaPlayerBlock;

  const MediaPlayerIslandView({super.key, required this.mediaPlayerBlock});

  @override
  State<MediaPlayerIslandView> createState() => _MediaPlayerIslandViewState();
}

class _MediaPlayerIslandViewState extends State<MediaPlayerIslandView> {
  static final _logger = createPrefixLogger('MediaPlayerIslandView');

  late AudioSystem _as;
  late AudioSession _audioSession;
  late Wakelock _wakelock;
  late WaveformVisualizer _waveformVisualizer;

  Float32List _rmsValues = Float32List(100);
  int numOfBins = 0;

  var _isPlaying = false;
  var _isLoading = false;

  Timer? _timerPollPlaybackPosition;

  GlobalKey globalKeyCustomPaint = GlobalKey();

  bool _processingButtonClick = false;

  AudioSessionInterruptionListenerHandle? _audioSessionInterruptionListenerHandle;

  @override
  void initState() {
    super.initState();

    _as = context.read<AudioSystem>();
    _audioSession = context.read<AudioSession>();
    _wakelock = context.read<Wakelock>();
    _as.mediaPlayerSetVolume(volume: widget.mediaPlayerBlock.volume);

    _waveformVisualizer = WaveformVisualizer(
      0,
      widget.mediaPlayerBlock.rangeStart,
      widget.mediaPlayerBlock.rangeEnd,
      _rmsValues,
    );

    MediaPlayerFunctions.setSpeedAndPitchInRust(
      _as,
      widget.mediaPlayerBlock.speedFactor,
      widget.mediaPlayerBlock.pitchSemitones,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _initBinsAndLoadRms());

    _timerPollPlaybackPosition = Timer.periodic(const Duration(milliseconds: 120), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (!_isPlaying) return;
      _as.mediaPlayerGetState().then((mediaPlayerState) {
        if (mediaPlayerState == null) {
          _logger.e('State is null.');
          return;
        }

        setState(() {
          _isPlaying = mediaPlayerState.playing;
          _waveformVisualizer = WaveformVisualizer(
            mediaPlayerState.playbackPositionFactor,
            widget.mediaPlayerBlock.rangeStart,
            widget.mediaPlayerBlock.rangeEnd,
            _rmsValues,
          );
        });
      });
    });
  }

  @override
  void deactivate() {
    if (_audioSessionInterruptionListenerHandle != null) {
      _audioSession.unregisterInterruptionListener(_audioSessionInterruptionListenerHandle!);
      _audioSessionInterruptionListenerHandle = null;
    }

    MediaPlayerFunctions.stopPlaying(
      _as,
      _wakelock,
    ).then((value) => MediaPlayerFunctions.stopRecording(_as, _wakelock));

    _timerPollPlaybackPosition?.cancel();
    super.deactivate();
  }

  void _initBinsAndLoadRms() async {
    final fs = context.read<FileSystem>();
    final customPaintContext = globalKeyCustomPaint.currentContext;
    final renderBox = customPaintContext?.findRenderObject() as RenderBox?;

    if (renderBox == null || renderBox.size.width <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _initBinsAndLoadRms());
      return;
    }

    numOfBins = WaveformVisualizer.calculateBinCountForWidth(renderBox.size.width);

    if (mounted) setState(() => _isLoading = true);

    final fileExtension = fs.toExtension(widget.mediaPlayerBlock.relativePath);
    if (mounted && fileExtension != null && !TIOMusicParams.audioFormats.contains(fileExtension)) {
      await showFormatNotSupportedDialog(context, fileExtension);
    }

    if (widget.mediaPlayerBlock.relativePath.isNotEmpty) {
      final newRms = await MediaPlayerFunctions.openAudioFileInRustAndGetRMSValues(
        _as,
        fs,
        widget.mediaPlayerBlock,
        numOfBins,
      );

      if (!mounted) return;
      if (newRms != null) {
        setState(() {
          _rmsValues = newRms;
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

  // Start/Stop Playing
  void _togglePlaying() async {
    if (_processingButtonClick) return;
    setState(() => _processingButtonClick = true);

    if (!_isPlaying) {
      await _startPlaying();
    } else {
      await _stopPlaying();
    }

    await Future.delayed(const Duration(milliseconds: TIOMusicParams.millisecondsPlayPauseDebounce));
    setState(() => _processingButtonClick = false);
  }

  Future<void> _stopPlaying() async {
    if (_audioSessionInterruptionListenerHandle != null) {
      _audioSession.unregisterInterruptionListener(_audioSessionInterruptionListenerHandle!);
      _audioSessionInterruptionListenerHandle = null;
    }

    await MediaPlayerFunctions.stopPlaying(_as, _wakelock);
    if (mounted) setState(() => _isPlaying = false);
  }

  Future<void> _startPlaying() async {
    _audioSessionInterruptionListenerHandle = await _audioSession.registerInterruptionListener(_stopPlaying);
    var success = await MediaPlayerFunctions.startPlaying(
      _as,
      _audioSession,
      _wakelock,
      widget.mediaPlayerBlock.looping,
      widget.mediaPlayerBlock.markerPositions.isNotEmpty,
    );
    if (mounted) setState(() => _isPlaying = success);
  }

  @override
  Widget build(BuildContext context) {
    return ParentInnerIsland(
      onMainIconPressed: _togglePlaying,
      mainIcon: _isPlaying
          ? const Icon(TIOMusicParams.pauseIcon, color: ColorTheme.primary)
          : widget.mediaPlayerBlock.icon,
      mainButtonIsDisabled: _isLoading,
      parameterText: widget.mediaPlayerBlock.title,
      centerView: _isLoading ? const Center(child: CircularProgressIndicator()) : _waveformVisualizer,
      customPaintKey: globalKeyCustomPaint,
      textSpaceWidth: 70,
    );
  }
}
