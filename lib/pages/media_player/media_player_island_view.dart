import 'dart:async';
import 'dart:typed_data';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/pages/media_player/media_player_functions.dart';
import 'package:tiomusic/pages/media_player/waveform_visualizer.dart';
import 'package:tiomusic/pages/parent_tool/parent_inner_island.dart';
import 'package:tiomusic/src/rust/api/api.dart';
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
  late WaveformVisualizer _waveformVisualizer;

  Float32List _rmsValues = Float32List(100);
  int numOfBins = 0;

  var _isPlaying = false;
  var _isLoading = false;

  Timer? _timerPollPlaybackPosition;

  GlobalKey globalKeyCustomPaint = GlobalKey();

  bool _processingButtonClick = false;

  StreamSubscription<AudioInterruptionEvent>? playInterruptionListener;

  @override
  void initState() {
    super.initState();

    mediaPlayerSetVolume(volume: widget.mediaPlayerBlock.volume);

    _waveformVisualizer = WaveformVisualizer(
      0.0,
      widget.mediaPlayerBlock.rangeStart,
      widget.mediaPlayerBlock.rangeEnd,
      _rmsValues,
      0,
    );

    MediaPlayerFunctions.setSpeedAndPitchInRust(
      widget.mediaPlayerBlock.speedFactor,
      widget.mediaPlayerBlock.pitchSemitones,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var customPaintContext = globalKeyCustomPaint.currentContext;
      if (customPaintContext != null) {
        final customPaintRenderBox = customPaintContext.findRenderObject() as RenderBox;
        numOfBins = (customPaintRenderBox.size.width / MediaPlayerParams.binWidth).floor();
      } else {
        throw ("WARNING: couldn't set numOfBins because the custom painter context was null!");
      }

      setState(() {
        _isLoading = true;
      });
      var fileExtension = widget.mediaPlayerBlock.getFileExtension();
      if (mounted && fileExtension != null && !TIOMusicParams.audioFormats.contains(fileExtension)) {
        await showFormatNotSupportedDialog(context, fileExtension);
      }

      if (widget.mediaPlayerBlock.relativePath.isNotEmpty) {
        var newRms = await MediaPlayerFunctions.openAudioFileInRustAndGetRMSValues(widget.mediaPlayerBlock, numOfBins);
        if (newRms != null) {
          _rmsValues = newRms;

          // this return is to prevent the call of setState if user exits media player while isLoading
          if (!mounted) return;
          setState(() {
            _waveformVisualizer = WaveformVisualizer(
              0.0,
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

    _timerPollPlaybackPosition = Timer.periodic(const Duration(milliseconds: 120), (Timer t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (!_isPlaying) return;
      mediaPlayerGetState().then((mediaPlayerState) {
        if (mediaPlayerState == null) {
          debugPrint("State is null");
          return;
        }

        setState(() {
          _isPlaying = mediaPlayerState.playing;
          _waveformVisualizer = WaveformVisualizer(
            mediaPlayerState.playbackPositionFactor,
            widget.mediaPlayerBlock.rangeStart,
            widget.mediaPlayerBlock.rangeEnd,
            _rmsValues,
            numOfBins,
          );
        });
      });
    });
  }

  @override
  void deactivate() {
    playInterruptionListener?.cancel();
    MediaPlayerFunctions.stopPlaying().then((value) => MediaPlayerFunctions.stopRecording());

    _timerPollPlaybackPosition?.cancel();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return ParentInnerIsland(
      onMainIconPressed: _togglePlaying,
      mainIcon:
          _isPlaying ? const Icon(TIOMusicParams.pauseIcon, color: ColorTheme.primary) : widget.mediaPlayerBlock.icon,
      mainButtonIsDisabled: _isLoading,
      parameterText: widget.mediaPlayerBlock.title,
      centerView:
          _isLoading
              // loading spinner
              ? const Center(child: CircularProgressIndicator())
              // waveform visualizer
              : _waveformVisualizer,
      customPaintKey: globalKeyCustomPaint,
      textSpaceWidth: 70,
    );
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
    await playInterruptionListener?.cancel();
    await MediaPlayerFunctions.stopPlaying();
    if (mounted) setState(() => _isPlaying = false);
  }

  Future<void> _startPlaying() async {
    playInterruptionListener = (await AudioSession.instance).interruptionEventStream.listen((event) {
      if (event.type == AudioInterruptionType.unknown) _stopPlaying();
    });
    var success = await MediaPlayerFunctions.startPlaying(widget.mediaPlayerBlock.looping);
    if (mounted) setState(() => _isPlaying = success);
  }
}
