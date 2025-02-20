import 'dart:async';
import 'dart:typed_data';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/media_player/edit_markers_page.dart';
import 'package:tiomusic/pages/media_player/media_player_functions.dart';
import 'package:tiomusic/pages/media_player/setting_bpm.dart';
import 'package:tiomusic/pages/media_player/setting_pitch.dart';
import 'package:tiomusic/pages/media_player/setting_speed.dart';
import 'package:tiomusic/pages/media_player/setting_trim.dart';
import 'package:tiomusic/pages/media_player/waveform_visualizer.dart';
import 'package:tiomusic/pages/parent_tool/parent_island_view.dart';
import 'package:tiomusic/pages/parent_tool/parent_tool.dart';
import 'package:tiomusic/pages/parent_tool/setting_volume_page.dart';
import 'package:tiomusic/pages/parent_tool/settings_tile.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/util/walkthrough_util.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tiomusic/widgets/on_off_button.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class MediaPlayer extends StatefulWidget {
  final bool isQuickTool;

  const MediaPlayer({super.key, required this.isQuickTool});

  @override
  State<MediaPlayer> createState() => _MediaPlayerState();
}

class _MediaPlayerState extends State<MediaPlayer> {
  var _isPlaying = false;
  var _isRecording = false;
  var _fileLoaded = false;
  var _isLoading = false;

  Timer? _timerPollPlaybackPosition;

  final List<MenuItemButton> _menuItems = List.empty(growable: true);
  late MenuItemButton _shareMenuButton;

  Duration _fileDuration = Duration.zero;

  late MediaPlayerBlock _mediaPlayerBlock;
  late Project? _project;

  Float32List _rmsValues = Float32List(100);
  int _numOfBins = 0;

  late WaveformVisualizer _waveformVisualizer;
  double _waveFormWidth = 0.0;

  Timer? _recordingTimer;
  Duration _recordingDuration = const Duration(seconds: 0);

  bool _processingButtonClick = false;

  final Walkthrough _walkthrough = Walkthrough();
  final GlobalKey _keyStartStop = GlobalKey();
  final GlobalKey _keySettings = GlobalKey();
  final GlobalKey _keyWaveform = GlobalKey();

  StreamSubscription<AudioInterruptionEvent>? playInterruptionListener;
  StreamSubscription<AudioInterruptionEvent>? recordInterruptionListener;

  @override
  void initState() {
    super.initState();

    _shareMenuButton = MenuItemButton(
      onPressed: _shareFilePressed,
      child: const Text("Share audio file", style: TextStyle(color: ColorTheme.primary)),
    );

    _waveformVisualizer = WaveformVisualizer(0.0, 0.0, 1.0, _rmsValues, 0);

    _mediaPlayerBlock = Provider.of<ProjectBlock>(context, listen: false) as MediaPlayerBlock;
    _mediaPlayerBlock.timeLastModified = getCurrentDateTime();

    if (!widget.isQuickTool) {
      _project = Provider.of<Project>(context, listen: false);
    }

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    mediaPlayerSetVolume(volume: _mediaPlayerBlock.volume);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _waveFormWidth = MediaQuery.of(context).size.width - (TIOMusicParams.edgeInset * 2);
      _numOfBins = (_waveFormWidth / MediaPlayerParams.binWidth).floor();

      MediaPlayerFunctions.setSpeedAndPitchInRust(_mediaPlayerBlock.speedFactor, _mediaPlayerBlock.pitchSemitones);

      setState(() {
        _isLoading = true;
      });
      var fileExtension = _mediaPlayerBlock.getFileExtension();
      if (mounted && fileExtension != null && !TIOMusicParams.audioFormats.contains(fileExtension)) {
        await showFormatNotSupportedDialog(context, fileExtension);
      }

      if (_mediaPlayerBlock.relativePath.isNotEmpty) {
        var newRms = await MediaPlayerFunctions.openAudioFileInRustAndGetRMSValues(_mediaPlayerBlock, _numOfBins);
        if (newRms == null) {
          if (mounted) await showFileOpenFailedDialog(context, fileName: _mediaPlayerBlock.relativePath);
        } else {
          _fileLoaded = true;
          _rmsValues = newRms;
          _waveformVisualizer = WaveformVisualizer(
            0.0,
            _mediaPlayerBlock.rangeStart,
            _mediaPlayerBlock.rangeEnd,
            _rmsValues,
            _numOfBins,
          );

          _setFileDuration();
        }
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (_fileLoaded) {
        _addShareOptionToMenu();
      }

      await _queryAndUpdateStateFromRust();

      if (mounted) {
        if (context.read<ProjectLibrary>().showMediaPlayerTutorial &&
            !context.read<ProjectLibrary>().showToolTutorial &&
            !context.read<ProjectLibrary>().showQuickToolTutorial &&
            !context.read<ProjectLibrary>().showIslandTutorial) {
          _createWalkthrough();
          _walkthrough.show(context);
        } else if (context.read<ProjectLibrary>().showWaveformTip &&
            _fileLoaded &&
            !context.read<ProjectLibrary>().showToolTutorial &&
            !context.read<ProjectLibrary>().showQuickToolTutorial &&
            !context.read<ProjectLibrary>().showIslandTutorial) {
          _createWalkthroughWaveformTip();
          _walkthrough.show(context);
        }
      }
    });

    _timerPollPlaybackPosition = Timer.periodic(const Duration(milliseconds: 120), (Timer t) async {
      if (!mounted) {
        t.cancel();
        return;
      }

      await _queryAndUpdateStateFromRust();
    });
  }

  void _createWalkthrough() {
    var targets = <CustomTargetFocus>[
      CustomTargetFocus(
        _keyStartStop,
        "Tap here to start and stop recording or to play a sound file",
        alignText: ContentAlign.top,
        pointingDirection: PointingDirection.down,
      ),
      CustomTargetFocus(
        _keySettings,
        "Tap here to adjust your sound file",
        alignText: ContentAlign.top,
        pointingDirection: PointingDirection.down,
        buttonsPosition: ButtonsPosition.top,
        shape: ShapeLightFocus.RRect,
      ),
    ];

    if (_fileLoaded) {
      targets.add(
        CustomTargetFocus(
          _keyWaveform,
          "Tap anywhere to jump to that part of your sound file",
          alignText: ContentAlign.bottom,
          pointingDirection: PointingDirection.up,
          shape: ShapeLightFocus.RRect,
        ),
      );
    }
    _walkthrough.create(targets.map((e) => e.targetFocus).toList(), () {
      context.read<ProjectLibrary>().showMediaPlayerTutorial = false;
      if (_fileLoaded) context.read<ProjectLibrary>().showWaveformTip = false;
      FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    }, context);
  }

  void _createWalkthroughWaveformTip() {
    var targets = <CustomTargetFocus>[
      CustomTargetFocus(
        _keyWaveform,
        "Tap anywhere to jump to that part of your sound file",
        alignText: ContentAlign.bottom,
        pointingDirection: PointingDirection.up,
        shape: ShapeLightFocus.RRect,
      ),
    ];

    _walkthrough.create(targets.map((e) => e.targetFocus).toList(), () {
      context.read<ProjectLibrary>().showWaveformTip = false;
      FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    }, context);
  }

  Future<void> _queryAndUpdateStateFromRust() async {
    var mediaPlayerStateRust = await mediaPlayerGetState();
    if (!mounted || mediaPlayerStateRust == null) return;
    setState(() {
      _isPlaying = mediaPlayerStateRust.playing;
      _waveformVisualizer = WaveformVisualizer(
        mediaPlayerStateRust.playbackPositionFactor,
        _mediaPlayerBlock.rangeStart,
        _mediaPlayerBlock.rangeEnd,
        _rmsValues,
        _numOfBins,
      );
    });
  }

  @override
  void deactivate() async {
    MediaPlayerFunctions.stopPlaying();
    MediaPlayerFunctions.stopRecording();

    await playInterruptionListener?.cancel();
    await recordInterruptionListener?.cancel();
    _recordingTimer?.cancel();
    _timerPollPlaybackPosition?.cancel();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    var waveformHeight = 200.0;

    return ParentTool(
      barTitle: _mediaPlayerBlock.title,
      functionBeforeNavigatingBack: () async {
        if (_isRecording) {
          await _askForKeepRecordingOnExit();
        }
      },
      isQuickTool: widget.isQuickTool,
      project: widget.isQuickTool ? null : Provider.of<Project>(context, listen: false),
      toolBlock: _mediaPlayerBlock,
      menuItems: _menuItems,
      onParentWalkthroughFinished: () {
        if (context.read<ProjectLibrary>().showMediaPlayerTutorial) {
          _createWalkthrough();
          _walkthrough.show(context);
        } else if (context.read<ProjectLibrary>().showWaveformTip && _fileLoaded) {
          _createWalkthroughWaveformTip();
          _walkthrough.show(context);
        }
      },
      island: ParentIslandView(project: widget.isQuickTool ? null : _project, toolBlock: _mediaPlayerBlock),
      centerModule: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Stack(
                children: [
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Padding(
                        key: _keyWaveform,
                        padding: const EdgeInsets.fromLTRB(TIOMusicParams.edgeInset, 0, TIOMusicParams.edgeInset, 0),
                        child:
                            _isRecording
                                ? MediaPlayerFunctions.displayRecordingTimer(_recordingDuration, waveformHeight)
                                : GestureDetector(
                                  onTapDown: _fileLoaded ? _onWaveTap : null,
                                  child: CustomPaint(
                                    painter: _waveformVisualizer,
                                    size: Size(_waveFormWidth, waveformHeight),
                                  ),
                                ),
                      ),
                  Stack(children: _isRecording ? [] : _buildMarkers()),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(onPressed: () => _jump10Seconds(false), child: const Text("-10 sec")),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _mediaPlayerBlock.looping = !_mediaPlayerBlock.looping;
                      FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
                    });
                    mediaPlayerSetLoop(looping: _mediaPlayerBlock.looping);
                  },
                  icon:
                      _mediaPlayerBlock.looping
                          ? const Icon(Icons.all_inclusive, color: ColorTheme.tertiary)
                          : const Icon(Icons.all_inclusive, color: ColorTheme.surfaceTint),
                ),
                TextButton(onPressed: () => _jump10Seconds(true), child: const Text("+10 sec")),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const PlaceholderButton(buttonSize: TIOMusicParams.sizeSmallButtons),
                _switchMainButton(_keyStartStop),
                _switchRightButton(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TIOFlatButton(
                onPressed: () async {
                  _pickNewAudioFile().then((value) {
                    if (context.read<ProjectLibrary>().showWaveformTip && _fileLoaded) {
                      _createWalkthroughWaveformTip();
                      _walkthrough.show(context);
                    }
                  });
                },
                text: _fileLoaded ? FileIO.getFileName(_mediaPlayerBlock.relativePath) : "Load Audio File",
              ),
            ),
          ],
        ),
      ),
      keySettingsList: _keySettings,
      settingTiles: [
        SettingsTile(
          title: "Volume",
          subtitle: _mediaPlayerBlock.volume.toString(),
          leadingIcon: Icons.volume_up,
          settingPage: SetVolume(
            initialValue: _mediaPlayerBlock.volume,
            onConfirm: (vol) {
              _mediaPlayerBlock.volume = vol;
              mediaPlayerSetVolume(volume: vol);
            },
            onUserChangedVolume: (vol) => mediaPlayerSetVolume(volume: vol),
            onCancel: () => mediaPlayerSetVolume(volume: _mediaPlayerBlock.volume),
          ),
          block: _mediaPlayerBlock,
          callOnReturn: (value) => setState(() {}),
          inactive: _isLoading,
        ),
        SettingsTile(
          title: "Trim",
          subtitle: "${(_mediaPlayerBlock.rangeStart * 100).round()}% → ${(_mediaPlayerBlock.rangeEnd * 100).round()}%",
          leadingIcon: "assets/icons/arrow_range.svg",
          settingPage: SetTrim(rmsValues: _rmsValues, fileDuration: _fileDuration),
          block: _mediaPlayerBlock,
          callOnReturn: (value) => _queryAndUpdateStateFromRust(),
          inactive: _isLoading,
        ),
        SettingsTile(
          title: "Basic Beat",
          subtitle: "${_mediaPlayerBlock.bpm} bpm",
          leadingIcon: Icons.touch_app_outlined,
          settingPage: const SetBPM(),
          block: _mediaPlayerBlock,
          callOnReturn: (value) => setState(() {}),
        ),
        SettingsTile(
          title: "Speed",
          subtitle:
              "${formatDoubleToString(_mediaPlayerBlock.speedFactor)}x / ${getBpmForSpeed(_mediaPlayerBlock.speedFactor, _mediaPlayerBlock.bpm)} bpm",
          leadingIcon: Icons.speed,
          settingPage: const SetSpeed(),
          block: _mediaPlayerBlock,
          callOnReturn: (value) => setState(() {}),
          inactive: _isLoading,
        ),
        SettingsTile(
          title: "Pitch",
          subtitle:
              "${_mediaPlayerBlock.pitchSemitones.abs() < 0.001 ? "" : (_mediaPlayerBlock.pitchSemitones > 0 ? "↑ " : "↓ ")}${formatDoubleToString(_mediaPlayerBlock.pitchSemitones.abs())} semitone${pluralSDouble(_mediaPlayerBlock.pitchSemitones)}",
          leadingIcon: Icons.height,
          settingPage: const SetPitch(),
          block: _mediaPlayerBlock,
          callOnReturn: (value) => setState(() {}),
          inactive: _isLoading,
        ),
        SettingsTile(
          title: "Markers",
          subtitle: _mediaPlayerBlock.markerPositions.length.toString(),
          leadingIcon: Icons.arrow_drop_down,
          settingPage: EditMarkersPage(
            mediaPlayerBlock: _mediaPlayerBlock,
            fileDuration: _fileDuration,
            rmsValues: _rmsValues,
          ),
          block: _mediaPlayerBlock,
          callOnReturn: (value) => setState(() {}),
          inactive: _isLoading,
        ),
      ],
    );
  }

  void _addShareOptionToMenu() {
    if (!_menuItems.contains(_shareMenuButton)) {
      _menuItems.add(_shareMenuButton);
    }
  }

  void _shareFilePressed() async {
    XFile file = XFile(await FileIO.getAbsoluteFilePath(_mediaPlayerBlock.relativePath));
    await Share.shareXFiles([file]);
  }

  Widget _switchMainButton(Key key) {
    if (_isRecording) {
      return _recordButton(TIOMusicParams.sizeBigButtons, key: key);
    } else {
      if (_fileLoaded) {
        return _playPauseButton(TIOMusicParams.sizeBigButtons, key: key);
      } else {
        return _recordButton(TIOMusicParams.sizeBigButtons, key: key);
      }
    }
  }

  Widget _switchRightButton() {
    if (_isRecording) {
      return _playPauseButton(TIOMusicParams.sizeSmallButtons);
    } else {
      if (_fileLoaded) {
        return _recordButton(TIOMusicParams.sizeSmallButtons);
      } else {
        return _playPauseButton(TIOMusicParams.sizeSmallButtons);
      }
    }
  }

  Widget _recordButton(double buttonSize, {Key? key}) {
    return OnOffButton(
      key: key,
      isActive: _isRecording,
      onTap: () {
        _toggleRecording().then((value) {
          if (context.read<ProjectLibrary>().showWaveformTip && _fileLoaded) {
            _createWalkthroughWaveformTip();
            _walkthrough.show(context);
          }
        });
      },
      buttonSize: buttonSize,
      iconOff: Icons.mic,
      iconOn: TIOMusicParams.pauseIcon,
      isDisabled: _isLoading,
    );
  }

  Widget _playPauseButton(double buttonSize, {Key? key}) {
    return OnOffButton(
      key: key,
      isActive: _isPlaying,
      onTap: _togglePlaying,
      buttonSize: buttonSize,
      iconOff: _mediaPlayerBlock.icon.icon!,
      iconOn: TIOMusicParams.pauseIcon,
      isDisabled: _isLoading,
    );
  }

  List<Widget> _buildMarkers() {
    List<Widget> markers = List.empty(growable: true);

    for (double pos in _mediaPlayerBlock.markerPositions) {
      var marker = Positioned(
        left: TIOMusicParams.edgeInset + ((pos * _waveFormWidth) - (MediaPlayerParams.markerIconSize / 2)),
        top: 4,
        child: IconButton(
          onPressed: () async {
            await mediaPlayerSetPlaybackPosFactor(posFactor: pos);
            await _queryAndUpdateStateFromRust();
          },
          icon: const Icon(Icons.arrow_drop_down, color: ColorTheme.primary, size: MediaPlayerParams.markerIconSize),
        ),
      );
      markers.add(marker);
    }

    return markers;
  }

  void _onWaveTap(TapDownDetails details) async {
    double relativeTapPosition = details.localPosition.dx / _waveFormWidth;

    await mediaPlayerSetPlaybackPosFactor(posFactor: relativeTapPosition);
    await _queryAndUpdateStateFromRust();
  }

  void _setFileDuration() async {
    var state = await mediaPlayerGetState();
    if (state != null) {
      var millisecondsDuration = state.totalLengthSeconds * 1000;
      _fileDuration = Duration(milliseconds: millisecondsDuration.toInt());
    }
  }

  void _jump10Seconds(bool forward) async {
    final state = await mediaPlayerGetState();
    if (state == null) {
      debugPrint("Cannot jump 10 seconds - State is null");
      return;
    }

    double secondFactor10 = _fileDuration.inSeconds > 0.01 ? 10.0 / _fileDuration.inSeconds : 100.0;

    double newPos;
    if (forward) {
      newPos = state.playbackPositionFactor + secondFactor10;
    } else {
      newPos = state.playbackPositionFactor - secondFactor10;
    }
    await mediaPlayerSetPlaybackPosFactor(posFactor: newPos);
    await _queryAndUpdateStateFromRust();
  }

  Future<void> _pickNewAudioFile() async {
    var newFilePicked = await _mediaPlayerBlock.pickAudio(context, context.read<ProjectLibrary>());

    if (newFilePicked && mounted) {
      FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());

      _fileLoaded = false;
      _rmsValues = Float32List(0);
      _waveformVisualizer = WaveformVisualizer(
        0.0,
        _mediaPlayerBlock.rangeStart,
        _mediaPlayerBlock.rangeEnd,
        _rmsValues,
        _numOfBins,
      );

      setState(() {
        _isLoading = true;
      });

      var fileExtension = _mediaPlayerBlock.getFileExtension();
      if (mounted && fileExtension != null && !TIOMusicParams.audioFormats.contains(fileExtension)) {
        await showFormatNotSupportedDialog(context, fileExtension);
      }

      var newRms = await MediaPlayerFunctions.openAudioFileInRustAndGetRMSValues(_mediaPlayerBlock, _numOfBins);
      if (newRms == null) {
        if (mounted) await showFileOpenFailedDialog(context, fileName: _mediaPlayerBlock.relativePath);
      } else {
        _fileLoaded = true;
        _rmsValues = newRms;
        _waveformVisualizer = WaveformVisualizer(
          0.0,
          _mediaPlayerBlock.rangeStart,
          _mediaPlayerBlock.rangeEnd,
          _rmsValues,
          _numOfBins,
        );

        _setFileDuration();
        _addShareOptionToMenu();
        _mediaPlayerBlock.markerPositions.clear();
        if (mounted) {
          FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
        }
      }
      setState(() {
        _isLoading = false;
      });

      await _queryAndUpdateStateFromRust();
    }
  }

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

  Future<void> _startPlaying() async {
    if (_isRecording) {
      debugPrint("Cannot play while recording");
      return;
    }
    if (!_fileLoaded) {
      debugPrint("Cannot play - No file loaded");
      return;
    }

    var success = await MediaPlayerFunctions.startPlaying(_mediaPlayerBlock.looping);
    playInterruptionListener = (await AudioSession.instance).interruptionEventStream.listen((event) {
      if (event.type == AudioInterruptionType.unknown) _stopPlaying();
    });
    setState(() => _isPlaying = success);
  }

  Future<void> _stopPlaying() async {
    bool success = await MediaPlayerFunctions.stopPlaying();
    if (!success) debugPrint("Error stopping playback");
    if (mounted) setState(() => _isPlaying = false);
  }

  Future<void> _toggleRecording() async {
    if (_processingButtonClick) return;
    setState(() => _processingButtonClick = true);

    if (!_isRecording && _fileLoaded) {
      final overrideFile = await askForOverridingFileOnRecordingStart(context);
      if (overrideFile == null || !overrideFile) {
        setState(() => _processingButtonClick = false);
        return;
      }
    }

    if (!_isRecording) {
      await _startRecording();
    } else {
      await _stopRecording();
    }

    await Future.delayed(const Duration(milliseconds: TIOMusicParams.millisecondsPlayPauseDebounce));
    setState(() => _processingButtonClick = false);
  }

  Future<void> _startRecording() async {
    var success = await MediaPlayerFunctions.startRecording(_isPlaying);
    setState(() {
      _isPlaying = false;
      _isRecording = true;
      if (success) _startRecordingTimer();
    });

    recordInterruptionListener = (await AudioSession.instance).interruptionEventStream.listen((event) {
      if (event.type == AudioInterruptionType.unknown) _stopRecording();
    });
  }

  Future<void> _stopRecording() async {
    await recordInterruptionListener?.cancel();

    var success = await MediaPlayerFunctions.stopRecording();
    if (mounted) {
      setState(() => _isRecording = false);
    }
    if (success && mounted) {
      _resetRecordingTimer();

      var projectTitle = widget.isQuickTool ? "Quick Tool" : _project!.title;
      var newName = "$projectTitle-${_mediaPlayerBlock.title}";

      var newRelativePath = await MediaPlayerFunctions.writeRecordingToFile(
        newName,
        _mediaPlayerBlock.relativePath == "" ? null : _mediaPlayerBlock.relativePath,
        context.read<ProjectLibrary>(),
      );

      if (newRelativePath != null) {
        _mediaPlayerBlock.relativePath = newRelativePath;
        if (mounted) {
          FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
          setState(() => _isLoading = true);

          var fileExtension = _mediaPlayerBlock.getFileExtension();
          if (mounted && fileExtension != null && !TIOMusicParams.audioFormats.contains(fileExtension)) {
            await showFormatNotSupportedDialog(context, fileExtension);
          }

          var newRms = await MediaPlayerFunctions.openAudioFileInRustAndGetRMSValues(_mediaPlayerBlock, _numOfBins);
          if (newRms == null) {
            if (mounted) await showFileOpenFailedDialog(context, fileName: _mediaPlayerBlock.relativePath);
          } else {
            _fileLoaded = true;
            _rmsValues = newRms;
            _waveformVisualizer = WaveformVisualizer(
              0.0,
              _mediaPlayerBlock.rangeStart,
              _mediaPlayerBlock.rangeEnd,
              _rmsValues,
              _numOfBins,
            );

            _setFileDuration();
            _addShareOptionToMenu();
            _mediaPlayerBlock.markerPositions.clear();
            if (mounted) FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
          }
          setState(() => _isLoading = false);
        }
      } else {
        debugPrint("Error saving recording to file");
      }
    }

    var newRms = await MediaPlayerFunctions.openAudioFileInRustAndGetRMSValues(_mediaPlayerBlock, _numOfBins);
    if (newRms == null) {
      if (mounted) await showFileOpenFailedDialog(context, fileName: _mediaPlayerBlock.relativePath);
    } else {
      _fileLoaded = true;
      _rmsValues = newRms;
      _waveformVisualizer = WaveformVisualizer(
        0.0,
        _mediaPlayerBlock.rangeStart,
        _mediaPlayerBlock.rangeEnd,
        _rmsValues,
        _numOfBins,
      );

      _setFileDuration();
      _addShareOptionToMenu();
      _mediaPlayerBlock.markerPositions.clear();
      if (mounted) FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future _askForKeepRecordingOnExit() async {
    MediaPlayerFunctions.stopRecording().then((success) async {
      if (success && mounted) {
        var projectTitle = widget.isQuickTool ? "Quick Tool" : _project!.title;
        var newName = "$projectTitle-${_mediaPlayerBlock.title}";

        var newRelativePath = await MediaPlayerFunctions.writeRecordingToFile(
          newName,
          _mediaPlayerBlock.relativePath == "" ? null : _mediaPlayerBlock.relativePath,
          context.read<ProjectLibrary>(),
        );

        if (newRelativePath != null) {
          _mediaPlayerBlock.relativePath = newRelativePath;
          if (mounted) {
            FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
          }
        }
      }
    });
  }

  void _startRecordingTimer() {
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) => _setCountUp());
  }

  void _stopRecordingTimer() {
    setState(() => _recordingTimer?.cancel());
  }

  void _resetRecordingTimer() {
    _stopRecordingTimer();
    setState(() => _recordingDuration = const Duration(seconds: 0));
  }

  void _setCountUp() {
    const countUpBy = 1;
    if (!mounted) return;
    setState(() {
      final seconds = _recordingDuration.inSeconds + countUpBy;
      _recordingDuration = Duration(seconds: seconds);
    });
  }
}
