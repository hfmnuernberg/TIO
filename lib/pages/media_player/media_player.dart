import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/media_player/edit_markers_page.dart';
import 'package:tiomusic/pages/media_player/handle_reached_markers.dart';
import 'package:tiomusic/pages/media_player/media_player_functions.dart';
import 'package:tiomusic/pages/media_player/media_player_repeat_button.dart';
import 'package:tiomusic/pages/media_player/setting_bpm.dart';
import 'package:tiomusic/pages/media_player/setting_pitch.dart';
import 'package:tiomusic/pages/media_player/setting_speed.dart';
import 'package:tiomusic/pages/media_player/setting_trim.dart';
import 'package:tiomusic/pages/media_player/waveform_visualizer.dart';
import 'package:tiomusic/services/audio_session.dart';
import 'package:tiomusic/services/wakelock.dart';
import 'package:tiomusic/widgets/parent_tool/parent_island_view.dart';
import 'package:tiomusic/pages/parent_tool/parent_tool.dart';
import 'package:tiomusic/pages/parent_tool/setting_volume_page.dart';
import 'package:tiomusic/pages/parent_tool/settings_tile.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/file_picker.dart';
import 'package:tiomusic/services/file_references.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/media_repository.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/log.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/util/tutorial_util.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tiomusic/widgets/on_off_button.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class MediaPlayer extends StatefulWidget {
  final bool isQuickTool;
  final bool shouldAutoplay;

  const MediaPlayer({super.key, required this.isQuickTool, this.shouldAutoplay = false});

  @override
  State<MediaPlayer> createState() => _MediaPlayerState();
}

class _MediaPlayerState extends State<MediaPlayer> {
  static final _logger = createPrefixLogger('MediaPlayer');

  late AudioSystem _as;
  late AudioSession _audioSession;
  late Wakelock _wakelock;
  late FileSystem _fs;
  late FilePicker _filePicker;
  late FileReferences _fileReferences;
  late MediaRepository _mediaRepo;
  late ProjectRepository _projectRepo;

  late bool _isPlaying = false;
  late bool _isRecording = false;
  late bool _fileLoaded = false;
  late bool _isLoading = false;

  late MarkerHandler _markerHandler;
  double? _previousPlaybackPositionFactor;
  final double _markerSoundFrequency = 2000;
  final int _markerSoundDurationInMilliseconds = 80;

  Timer? _timerPollPlaybackPosition;

  final List<MenuItemButton> _menuItems = List.empty(growable: true);
  late MenuItemButton _shareMenuButton;

  Duration _fileDuration = Duration.zero;

  late MediaPlayerBlock _mediaPlayerBlock;
  Project? _project;

  Float32List _rmsValues = Float32List(100);
  int _numOfBins = 0;

  late WaveformVisualizer _waveformVisualizer;
  double _waveFormWidth = 0;

  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;

  bool _processingButtonClick = false;

  final Tutorial _tutorial = Tutorial();
  final GlobalKey _keyStartStop = GlobalKey();
  final GlobalKey _keyRepeat = GlobalKey();
  final GlobalKey _keySettings = GlobalKey();
  final GlobalKey _keyWaveform = GlobalKey();
  final GlobalKey islandToolTutorialKey = GlobalKey();

  AudioSessionInterruptionListenerHandle? playInterruptionListenerHandle;
  AudioSessionInterruptionListenerHandle? recordInterruptionListenerHandle;

  @override
  void initState() {
    super.initState();

    _as = context.read<AudioSystem>();
    _audioSession = context.read<AudioSession>();
    _wakelock = context.read<Wakelock>();
    _fs = context.read<FileSystem>();
    _filePicker = context.read<FilePicker>();
    _fileReferences = context.read<FileReferences>();
    _mediaRepo = context.read<MediaRepository>();
    _projectRepo = context.read<ProjectRepository>();

    _waveformVisualizer = WaveformVisualizer(0, 0, 1, _rmsValues, 0);

    _mediaPlayerBlock = Provider.of<ProjectBlock>(context, listen: false) as MediaPlayerBlock;
    _mediaPlayerBlock.timeLastModified = getCurrentDateTime();

    _markerHandler = MarkerHandler();

    if (!widget.isQuickTool) {
      _project = context.read<Project>();
    }

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    _as.mediaPlayerSetVolume(volume: _mediaPlayerBlock.volume);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _waveFormWidth = MediaQuery.of(context).size.width - (TIOMusicParams.edgeInset * 2);
      _numOfBins = (_waveFormWidth / MediaPlayerParams.binWidth).floor();

      MediaPlayerFunctions.setSpeedAndPitchInRust(_as, _mediaPlayerBlock.speedFactor, _mediaPlayerBlock.pitchSemitones);

      setState(() => _isLoading = true);

      final fileExtension = _fs.toExtension(_mediaPlayerBlock.relativePath);
      if (mounted && fileExtension != null && !TIOMusicParams.audioFormats.contains(fileExtension)) {
        await showFormatNotSupportedDialog(context, fileExtension);
      }

      if (_mediaPlayerBlock.relativePath.isNotEmpty) {
        var newRms = await MediaPlayerFunctions.openAudioFileInRustAndGetRMSValues(
          _as,
          _fs,
          _mediaPlayerBlock,
          _numOfBins,
        );
        if (newRms == null) {
          if (mounted) await showFileOpenFailedDialog(context, fileName: _mediaPlayerBlock.relativePath);
        } else {
          _fileLoaded = true;
          _rmsValues = newRms;
          _waveformVisualizer = WaveformVisualizer(
            0,
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

      if (mounted && widget.shouldAutoplay && _fileLoaded) _autoplayAfterDelay();
    });

    _timerPollPlaybackPosition = Timer.periodic(const Duration(milliseconds: 120), (t) async {
      if (!mounted) {
        t.cancel();
        return;
      }

      await _queryAndUpdateStateFromRust();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _shareMenuButton = MenuItemButton(
      onPressed: _shareFilePressed,
      child: Text(context.l10n.mediaPlayerShareAudioFile, style: const TextStyle(color: ColorTheme.primary)),
    );
  }

  void _addShareOptionToMenu() {
    if (!_menuItems.contains(_shareMenuButton)) {
      _menuItems.add(_shareMenuButton);
    }
  }

  void _createTutorial() {
    final l10n = context.l10n;
    var targets = <CustomTargetFocus>[
      if (context.read<ProjectLibrary>().showMediaPlayerTutorial)
        CustomTargetFocus(
          _keyStartStop,
          l10n.mediaPlayerTutorialStartStop,
          alignText: ContentAlign.top,
          pointingDirection: PointingDirection.down,
        ),
      if (context.read<ProjectLibrary>().showMediaPlayerTutorial)
        CustomTargetFocus(
          _keyRepeat,
          l10n.mediaPlayerTutorialRepeat,
          alignText: ContentAlign.top,
          pointingDirection: PointingDirection.down,
        ),
      if (context.read<ProjectLibrary>().showMediaPlayerTutorial)
        CustomTargetFocus(
          _keySettings,
          l10n.mediaPlayerTutorialAdjust,
          alignText: ContentAlign.custom,
          customTextPosition: CustomTargetContentPosition(top: MediaQuery.of(context).size.height / 2 - 100),
          pointingDirection: PointingDirection.down,
          buttonsPosition: ButtonsPosition.top,
          shape: ShapeLightFocus.RRect,
        ),
      if (context.read<ProjectLibrary>().showMediaPlayerIslandTutorial && !widget.isQuickTool)
        CustomTargetFocus(
          islandToolTutorialKey,
          l10n.mediaPlayerTutorialIslandTool,
          pointingDirection: PointingDirection.up,
          alignText: ContentAlign.bottom,
          shape: ShapeLightFocus.RRect,
        ),
      if (context.read<ProjectLibrary>().showWaveformTip && _fileLoaded)
        CustomTargetFocus(
          _keyWaveform,
          l10n.mediaPlayerTutorialJumpTo,
          alignText: ContentAlign.bottom,
          pointingDirection: PointingDirection.up,
          shape: ShapeLightFocus.RRect,
        ),
    ];

    if (targets.isEmpty) return;
    _tutorial.create(targets.map((e) => e.targetFocus).toList(), () async {
      if (context.read<ProjectLibrary>().showMediaPlayerTutorial) {
        context.read<ProjectLibrary>().showMediaPlayerTutorial = false;
      }

      if (context.read<ProjectLibrary>().showMediaPlayerIslandTutorial && !widget.isQuickTool) {
        context.read<ProjectLibrary>().showMediaPlayerIslandTutorial = false;
      }

      if (context.read<ProjectLibrary>().showWaveformTip && _fileLoaded) {
        context.read<ProjectLibrary>().showWaveformTip = false;
      }

      await _projectRepo.saveLibrary(context.read<ProjectLibrary>());
    }, context);
  }

  Future<void> _autoplayAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final success = await MediaPlayerFunctions.startPlaying(
      _as,
      _audioSession,
      _wakelock,
      false,
      _mediaPlayerBlock.markerPositions.isNotEmpty,
    );
    if (success && mounted) setState(() => _isPlaying = true);
  }

  Future<void> _queryAndUpdateStateFromRust() async {
    var mediaPlayerStateRust = await _as.mediaPlayerGetState();
    if (!mounted || mediaPlayerStateRust == null) return;

    final wasPreviousPlaying = _isPlaying;

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

    if (_project != null && _project!.mediaPlayerRepeatAll && wasPreviousPlaying && !_isPlaying && _fileLoaded) {
      _goToNextMediaPlayerWithLoadedFile();
    }

    if (_mediaPlayerBlock.markerPositions.isNotEmpty) _handleMarkers(mediaPlayerStateRust.playbackPositionFactor);
  }

  Future<void> _goToNextMediaPlayerWithLoadedFile() async {
    final project = Provider.of<Project>(context, listen: false);
    final blocks = project.blocks;
    final currentIndex = blocks.indexOf(_mediaPlayerBlock);

    for (int offset = 1; offset < blocks.length; offset++) {
      final index = (currentIndex + offset) % blocks.length;
      final block = blocks[index];
      if (block is MediaPlayerBlock && block.relativePath != MediaPlayerParams.defaultPath) {
        await goToTool(context, project, block, replace: true, shouldAutoplay: true);
        return;
      }
    }
  }

  void _handleMarkers(double currentPosition) {
    final previousPosition = _previousPlaybackPositionFactor ?? currentPosition;
    if (previousPosition > currentPosition) {
      _markerHandler.reset();
      _previousPlaybackPositionFactor = currentPosition;
      return;
    }
    _markerHandler.checkMarkers(
      previousPosition: previousPosition,
      currentPosition: currentPosition,
      markers: _mediaPlayerBlock.markerPositions,
      onPeep: (marker) async {
        if (_isPlaying) {
          await _as.generatorNoteOn(newFreq: _markerSoundFrequency);
          Future.delayed(Duration(milliseconds: _markerSoundDurationInMilliseconds), () => _as.generatorNoteOff());
        }
      },
    );
    _previousPlaybackPositionFactor = currentPosition;
  }

  @override
  void deactivate() async {
    MediaPlayerFunctions.stopPlaying(_as, _wakelock);
    MediaPlayerFunctions.stopRecording(_as, _wakelock);

    if (playInterruptionListenerHandle != null) {
      await _audioSession.unregisterInterruptionListener(playInterruptionListenerHandle!);
    }
    if (recordInterruptionListenerHandle != null) {
      await _audioSession.unregisterInterruptionListener(recordInterruptionListenerHandle!);
    }

    _recordingTimer?.cancel();
    _timerPollPlaybackPosition?.cancel();

    super.deactivate();
  }

  @override
  void dispose() {
    _tutorial.dispose();
    _recordingTimer?.cancel();
    _timerPollPlaybackPosition?.cancel();
    super.dispose();
  }

  Future<void> _handleRepeatToggle() async {
    await _projectRepo.saveLibrary(context.read<ProjectLibrary>());
    _as.mediaPlayerSetRepeat(repeatOne: _mediaPlayerBlock.looping);
  }

  @override
  Widget build(BuildContext context) {
    var waveformHeight = 200.0;
    final l10n = context.l10n;
    final isMultiImportEnabled = !widget.isQuickTool;

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
      islandToolTutorialKey: islandToolTutorialKey,
      onParentTutorialFinished: () {
        _createTutorial();
        _tutorial.show(context);
      },
      island: ParentIslandView(project: widget.isQuickTool ? null : _project, toolBlock: _mediaPlayerBlock),
      centerModule: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Stack(
                children: [
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Padding(
                      key: _keyWaveform,
                      padding: const EdgeInsets.fromLTRB(TIOMusicParams.edgeInset, 0, TIOMusicParams.edgeInset, 0),
                      child:
                          _isRecording
                              ? MediaPlayerFunctions.displayRecordingTimer(
                                context.l10n.mediaPlayerRecording,
                                context.l10n.formatDuration(_recordingDuration),
                                waveformHeight,
                              )
                              : GestureDetector(
                                onTapDown: (details) => _fileLoaded ? _onWaveGesture(details.localPosition) : null,
                                onHorizontalDragUpdate:
                                    (details) => _fileLoaded ? _onWaveGesture(details.localPosition) : null,
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
                TextButton(onPressed: () => _jump10Seconds(false), child: Text('-10 ${l10n.mediaPlayerSecShort}')),
                Container(key: _keyRepeat, child: MediaPlayerRepeatButton(onToggle: _handleRepeatToggle)),
                TextButton(onPressed: () => _jump10Seconds(true), child: Text('+10 ${l10n.mediaPlayerSecShort}')),
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

            if (_fileLoaded)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _fs.toBasename(_mediaPlayerBlock.relativePath),
                  style: TextStyle(color: ColorTheme.primary),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TIOFlatButton(
                      onPressed: () async {
                        await _pickAudioFilesAndSave(isMultipleAllowed: isMultiImportEnabled);
                        if (!context.mounted) return;
                        if (context.read<ProjectLibrary>().showWaveformTip && _fileLoaded) {
                          _createTutorial();
                          _tutorial.show(context);
                        }
                      },
                      text: Platform.isIOS ? l10n.mediaPlayerOpenMediaLibrary : l10n.mediaPlayerOpenFileSystem,
                    ),
                  ),

                  if (Platform.isIOS) ...[
                    SizedBox(width: 10),
                    Expanded(
                      child: TIOFlatButton(
                        onPressed: () async {
                          await _pickAudioFilesAndSave(
                            isMultipleAllowed: isMultiImportEnabled,
                            pickAudioFromFileSystem: true,
                          );
                          if (!context.mounted) return;
                          if (context.read<ProjectLibrary>().showWaveformTip && _fileLoaded) {
                            _createTutorial();
                            _tutorial.show(context);
                          }
                        },
                        text: l10n.mediaPlayerOpenFileSystem,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      keySettingsList: _keySettings,
      settingTiles: [
        SettingsTile(
          title: l10n.commonVolume,
          subtitle: l10n.formatNumber(_mediaPlayerBlock.volume),
          leadingIcon: Icons.volume_up,
          settingPage: SetVolume(
            initialValue: _mediaPlayerBlock.volume,
            onConfirm: (vol) {
              _mediaPlayerBlock.volume = vol;
              _as.mediaPlayerSetVolume(volume: vol);
            },
            onChange: (vol) => _as.mediaPlayerSetVolume(volume: vol),
            onCancel: () => _as.mediaPlayerSetVolume(volume: _mediaPlayerBlock.volume),
          ),
          block: _mediaPlayerBlock,
          callOnReturn: (value) => setState(() {}),
          inactive: _isLoading,
        ),
        SettingsTile(
          title: l10n.commonBasicBeat,
          subtitle: '${_mediaPlayerBlock.bpm} ${l10n.commonBpm}',
          leadingIcon: Icons.touch_app_outlined,
          settingPage: const SetBPM(),
          block: _mediaPlayerBlock,
          callOnReturn: (value) => setState(() {}),
        ),
        SettingsTile(
          title: l10n.mediaPlayerTrim,
          subtitle: '${(_mediaPlayerBlock.rangeStart * 100).round()}% → ${(_mediaPlayerBlock.rangeEnd * 100).round()}%',
          leadingIcon: 'assets/icons/arrow_range.svg',
          settingPage: SetTrim(rmsValues: _rmsValues, fileDuration: _fileDuration),
          block: _mediaPlayerBlock,
          callOnReturn: (value) => _queryAndUpdateStateFromRust(),
          inactive: _isLoading,
        ),
        SettingsTile(
          title: l10n.mediaPlayerMarkers,
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
        SettingsTile(
          title: l10n.mediaPlayerPitch,
          subtitle: getPitchSemitonesString(
            _mediaPlayerBlock.pitchSemitones,
            l10n.mediaPlayerSemitones(_mediaPlayerBlock.pitchSemitones.round()),
          ),
          leadingIcon: Icons.height,
          settingPage: const SetPitch(),
          block: _mediaPlayerBlock,
          callOnReturn: (value) => setState(() {}),
          inactive: _isLoading,
        ),
        SettingsTile(
          title: l10n.mediaPlayerSpeed,
          subtitle:
              '${l10n.formatNumber(_mediaPlayerBlock.speedFactor)}x / ${getBpmForSpeed(_mediaPlayerBlock.speedFactor, _mediaPlayerBlock.bpm)} ${l10n.commonBpm}',
          leadingIcon: Icons.speed,
          settingPage: const SetSpeed(),
          block: _mediaPlayerBlock,
          callOnReturn: (value) => setState(() {}),
          inactive: _isLoading,
        ),
      ],
    );
  }

  String getPitchSemitonesString(double semitones, String label) {
    if (semitones.abs() < 0.001) return '';
    return semitones > 0 ? '↑ $label' : '↓ $label';
  }

  void _shareFilePressed() async {
    await _filePicker.shareFile(_fs.toAbsoluteFilePath(_mediaPlayerBlock.relativePath));
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
      onTap: () async {
        await _toggleRecording();
        if (!mounted) return;
        if (context.read<ProjectLibrary>().showWaveformTip && _fileLoaded) {
          _createTutorial();
          _tutorial.show(context);
        }
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
      iconOff: (_mediaPlayerBlock.icon as Icon).icon!,
      iconOn: TIOMusicParams.pauseIcon,
      isDisabled: _isLoading,
      tooltipOff: context.l10n.mediaPlayerPause,
      tooltipOn: context.l10n.mediaPlayerPlay,
    );
  }

  List<Widget> _buildMarkers() {
    List<Widget> markers = List.empty(growable: true);

    for (final pos in _mediaPlayerBlock.markerPositions) {
      var marker = Positioned(
        left: TIOMusicParams.edgeInset + ((pos * _waveFormWidth) - (MediaPlayerParams.markerButton / 2)),
        top: 4,
        child: IconButton(
          onPressed: () async {
            await _as.mediaPlayerSetPlaybackPosFactor(posFactor: pos);
            await _queryAndUpdateStateFromRust();
          },
          icon: const Icon(Icons.arrow_drop_down, color: ColorTheme.primary, size: MediaPlayerParams.markerIconSize),
        ),
      );
      markers.add(marker);
    }

    return markers;
  }

  void _onWaveGesture(Offset localPosition) async {
    double relativeTapPosition = localPosition.dx / _waveFormWidth;

    await _as.mediaPlayerSetPlaybackPosFactor(posFactor: relativeTapPosition.clamp(0, 1));
    await _queryAndUpdateStateFromRust();
  }

  void _setFileDuration() async {
    var state = await _as.mediaPlayerGetState();
    if (state != null) {
      var millisecondsDuration = state.totalLengthSeconds * 1000;
      _fileDuration = Duration(milliseconds: millisecondsDuration.toInt());
    }
  }

  void _jump10Seconds(bool forward) async {
    final state = await _as.mediaPlayerGetState();
    if (state == null) {
      _logger.w('Cannot jump 10 seconds - State is null');
      return;
    }

    double secondFactor10 = _fileDuration.inSeconds > 0.01 ? 10.0 / _fileDuration.inSeconds : 100.0;

    double newPos;
    if (forward) {
      newPos = state.playbackPositionFactor + secondFactor10;
    } else {
      newPos = state.playbackPositionFactor - secondFactor10;
    }
    await _as.mediaPlayerSetPlaybackPosFactor(posFactor: newPos);
    await _queryAndUpdateStateFromRust();
  }

  Future<void> _pickAudioFilesAndSave({required bool isMultipleAllowed, bool pickAudioFromFileSystem = false}) async {
    try {
      final audioPaths = await _pickAudioFiles(
        context: context,
        projectLibrary: context.read<ProjectLibrary>(),
        pickAudioFromFileSystem: pickAudioFromFileSystem,
        isMultipleAllowed: isMultipleAllowed,
      );
      if (audioPaths == null || audioPaths.isEmpty) return;
      if (audioPaths.length > 10) {
        await _showTooManyFilesSelectedDialog();
        audioPaths.removeRange(10, audioPaths.length);
      }

      for (int i = 0; i < audioPaths.length; i++) {
        final audioPath = audioPaths[i];
        if (audioPath == null) return;
        await _handleAudioFile(i, audioPath);
      }

      if (!mounted) return;

      await _projectRepo.saveLibrary(context.read<ProjectLibrary>());
      setState(() {});
    } on PlatformException catch (e) {
      logger.e('Unable to pick audio files.', error: e);
    }
  }

  Future<void> _handleAudioFile(int index, String audioPath) async {
    if (!mounted) return;

    final extension = _fs.toExtension(audioPath);
    if (!_isAcceptedFormat(extension)) {
      await showFormatNotSupportedDialog(context, extension);
      return;
    }

    if (!await _fs.existsFileAfterGracePeriod(audioPath)) {
      if (mounted) await showFileNotAccessibleDialog(context, fileName: audioPath);
      return;
    }

    final basenameWithTimestamp = '${_fs.toBasename(audioPath)}_${DateTime.now().millisecondsSinceEpoch}';
    final newRelativePath = await _mediaRepo.import(audioPath, basenameWithTimestamp);

    if (newRelativePath == null) return;

    // Wait to prevent the following error:
    // flutter: media player load wav failed: unsupported feature: core (probe): no suitable format reader found
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    final projectLibrary = context.read<ProjectLibrary>();

    if (index == 0) {
      _fileReferences.dec(_mediaPlayerBlock.relativePath, projectLibrary);
      _mediaPlayerBlock.relativePath = newRelativePath;
      _fileReferences.inc(newRelativePath);

      await _projectRepo.saveLibrary(projectLibrary);

      _fileLoaded = false;
      _rmsValues = Float32List(0);
      _waveformVisualizer = WaveformVisualizer(
        0,
        _mediaPlayerBlock.rangeStart,
        _mediaPlayerBlock.rangeEnd,
        _rmsValues,
        _numOfBins,
      );

      setState(() => _isLoading = true);

      var newRms = await MediaPlayerFunctions.openAudioFileInRustAndGetRMSValues(
        _as,
        _fs,
        _mediaPlayerBlock,
        _numOfBins,
      );
      if (newRms == null) {
        if (mounted) await showFileOpenFailedDialog(context, fileName: _mediaPlayerBlock.relativePath);
      } else {
        _fileLoaded = true;
        _rmsValues = newRms;
        _waveformVisualizer = WaveformVisualizer(
          0,
          _mediaPlayerBlock.rangeStart,
          _mediaPlayerBlock.rangeEnd,
          _rmsValues,
          _numOfBins,
        );

        _setFileDuration();
        _addShareOptionToMenu();
        _mediaPlayerBlock.markerPositions.clear();
        _markerHandler.reset();
        if (mounted) await _projectRepo.saveLibrary(projectLibrary);
      }
      setState(() => _isLoading = false);

      await _queryAndUpdateStateFromRust();
    } else {
      final title = '${_mediaPlayerBlock.title} ($index)';
      final newBlock = MediaPlayerBlock.withTitle(title)..relativePath = newRelativePath;
      _project?.addBlock(newBlock);
    }
  }

  Future<List<String?>?> _pickAudioFiles({
    required BuildContext context,
    required ProjectLibrary projectLibrary,
    required bool pickAudioFromFileSystem,
    required bool isMultipleAllowed,
  }) async {
    try {
      return pickAudioFromFileSystem
          ? await _filePicker.pickAudioFromFileSystem(isMultipleAllowed: isMultipleAllowed)
          : await _filePicker.pickAudioFromMediaLibrary(isMultipleAllowed: isMultipleAllowed);
    } on PlatformException catch (e) {
      _logger.e('Failed to pick audio.', error: e);
      return null;
    }
  }

  bool _isAcceptedFormat(String? extension) => TIOMusicParams.audioFormats.contains((extension ?? '').toLowerCase());

  Future<void> _showTooManyFilesSelectedDialog() => showDialog<void>(
    context: context,
    builder: (context) {
      final l10n = context.l10n;

      return AlertDialog(
        title: Text(l10n.mediaPlayerTooManyFilesTitle, style: TextStyle(color: ColorTheme.primary)),
        content: Text(l10n.mediaPlayerTooManyFilesDescription, style: const TextStyle(color: ColorTheme.primary)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonGotIt))],
      );
    },
  );

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
      _logger.w('Cannot play - Recording in progress.');
      return;
    }
    if (!_fileLoaded) {
      _logger.w('Cannot play - No file loaded.');
      return;
    }

    var success = await MediaPlayerFunctions.startPlaying(
      _as,
      _audioSession,
      _wakelock,
      _mediaPlayerBlock.looping,
      _mediaPlayerBlock.markerPositions.isNotEmpty,
    );
    _audioSession.registerInterruptionListener(_stopPlaying);
    setState(() => _isPlaying = success);
  }

  Future<void> _stopPlaying() async {
    bool success = await MediaPlayerFunctions.stopPlaying(_as, _wakelock);
    if (!success) _logger.e('Unable to stop playing.');
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
    var success = await MediaPlayerFunctions.startRecording(_as, _audioSession, _wakelock, _isPlaying);
    setState(() {
      _isPlaying = false;
      _isRecording = true;
      if (success) _startRecordingTimer();
    });

    recordInterruptionListenerHandle = await _audioSession.registerInterruptionListener(_stopRecording);
  }

  Future<void> _stopRecording() async {
    if (recordInterruptionListenerHandle != null) {
      await _audioSession.unregisterInterruptionListener(recordInterruptionListenerHandle!);
    }

    var success = await MediaPlayerFunctions.stopRecording(_as, _wakelock);
    if (mounted) {
      setState(() => _isRecording = false);
    }
    if (success && mounted) {
      _resetRecordingTimer();

      var projectTitle = widget.isQuickTool ? context.l10n.toolQuickTool : _project!.title;
      var newName = '$projectTitle-${_mediaPlayerBlock.title}';

      final samples = await _as.mediaPlayerGetRecordingSamples();
      final newRelativePath = await _mediaRepo.saveSamplesToWaveFile(newName, samples);

      if (newRelativePath == null) {
        _logger.e('Unable to save recording.');
        return;
      }

      if (!mounted) return;

      _fileReferences.inc(newRelativePath);
      if (_mediaPlayerBlock.relativePath.isNotEmpty) {
        _fileReferences.dec(_mediaPlayerBlock.relativePath, context.read<ProjectLibrary>());
      }
      _mediaPlayerBlock.relativePath = newRelativePath;

      await _projectRepo.saveLibrary(context.read<ProjectLibrary>());
      setState(() => _isLoading = true);

      final fileExtension = _fs.toExtension(_mediaPlayerBlock.relativePath);
      if (mounted && fileExtension != null && !TIOMusicParams.audioFormats.contains(fileExtension)) {
        await showFormatNotSupportedDialog(context, fileExtension);
      }

      var newRms = await MediaPlayerFunctions.openAudioFileInRustAndGetRMSValues(
        _as,
        _fs,
        _mediaPlayerBlock,
        _numOfBins,
      );
      if (newRms == null) {
        if (mounted) await showFileOpenFailedDialog(context, fileName: _mediaPlayerBlock.relativePath);
      } else {
        _fileLoaded = true;
        _rmsValues = newRms;
        _waveformVisualizer = WaveformVisualizer(
          0,
          _mediaPlayerBlock.rangeStart,
          _mediaPlayerBlock.rangeEnd,
          _rmsValues,
          _numOfBins,
        );

        _setFileDuration();
        _addShareOptionToMenu();
        _mediaPlayerBlock.markerPositions.clear();
        _markerHandler.reset();
        if (mounted) await _projectRepo.saveLibrary(context.read<ProjectLibrary>());
      }
      setState(() => _isLoading = false);
    }

    var newRms = await MediaPlayerFunctions.openAudioFileInRustAndGetRMSValues(_as, _fs, _mediaPlayerBlock, _numOfBins);
    if (newRms == null) {
      if (mounted) await showFileOpenFailedDialog(context, fileName: _mediaPlayerBlock.relativePath);
    } else {
      _fileLoaded = true;
      _rmsValues = newRms;
      _waveformVisualizer = WaveformVisualizer(
        0,
        _mediaPlayerBlock.rangeStart,
        _mediaPlayerBlock.rangeEnd,
        _rmsValues,
        _numOfBins,
      );

      _setFileDuration();
      _addShareOptionToMenu();
      _mediaPlayerBlock.markerPositions.clear();
      _markerHandler.reset();
      if (mounted) await _projectRepo.saveLibrary(context.read<ProjectLibrary>());
    }
    setState(() => _isLoading = false);
  }

  Future _askForKeepRecordingOnExit() async {
    MediaPlayerFunctions.stopRecording(_as, _wakelock).then((success) async {
      if (success && mounted) {
        final projectTitle = widget.isQuickTool ? context.l10n.toolQuickTool : _project!.title;
        final newName = '$projectTitle-${_mediaPlayerBlock.title}';

        final samples = await _as.mediaPlayerGetRecordingSamples();
        final newRelativePath = await _mediaRepo.saveSamplesToWaveFile(newName, samples);

        if (newRelativePath == null) return;

        if (!mounted) return;

        _fileReferences.inc(newRelativePath);
        if (_mediaPlayerBlock.relativePath.isNotEmpty) {
          _fileReferences.dec(_mediaPlayerBlock.relativePath, context.read<ProjectLibrary>());
        }
        _mediaPlayerBlock.relativePath = newRelativePath;

        await _projectRepo.saveLibrary(context.read<ProjectLibrary>());
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
    setState(() => _recordingDuration = Duration.zero);
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
