import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/domain/audio/player.dart';
import 'package:tiomusic/domain/audio/recorder.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/media_player/edit_markers_page.dart';
import 'package:tiomusic/pages/media_player/media_player_repeat_button.dart';
import 'package:tiomusic/pages/media_player/setting_bpm.dart';
import 'package:tiomusic/pages/media_player/setting_pitch.dart';
import 'package:tiomusic/pages/media_player/setting_speed.dart';
import 'package:tiomusic/pages/media_player/setting_trim.dart';
import 'package:tiomusic/pages/media_player/waveform_visualizer.dart';
import 'package:tiomusic/pages/parent_tool/parent_tool.dart';
import 'package:tiomusic/pages/parent_tool/setting_volume_page.dart';
import 'package:tiomusic/pages/parent_tool/settings_tile.dart';
import 'package:tiomusic/services/audio_session.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/file_picker.dart';
import 'package:tiomusic/services/file_references.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/media_repository.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/services/wakelock.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/log.dart';
import 'package:tiomusic/util/tutorial_util.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tiomusic/widgets/on_off_button.dart';
import 'package:tiomusic/widgets/parent_tool/parent_island_view.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class MediaPlayerPage extends StatefulWidget {
  final bool isQuickTool;
  final bool shouldAutoplay;

  const MediaPlayerPage({super.key, required this.isQuickTool, this.shouldAutoplay = false});

  @override
  State<MediaPlayerPage> createState() => _MediaPlayerPageState();
}

class _MediaPlayerPageState extends State<MediaPlayerPage> {
  static final _logger = createPrefixLogger('MediaPlayerPage');

  late FileSystem _fs;
  late FilePicker _filePicker;
  late FileReferences _fileReferences;
  late MediaRepository _mediaRepo;
  late ProjectRepository _projectRepo;

  late final Player _player;
  late final Recorder _recorder;

  late bool _isLoading = false;
  late bool _wasPlaying = false;
  double _previousPosition = 0;
  static const double _endEpsilon = 0.01;

  final List<MenuItemButton> _menuItems = List.empty(growable: true);
  late MenuItemButton _shareMenuButton;

  late MediaPlayerBlock _mediaPlayerBlock;
  Project? _project;

  Float32List _rmsValues = Float32List(100);
  int _numOfBins = 0;

  late WaveformVisualizer _waveformVisualizer;
  double _waveFormWidth = 0;

  Duration _recordingLength = Duration.zero;

  bool _processingButtonClick = false;

  final Tutorial _tutorial = Tutorial();
  final GlobalKey _keyStartStop = GlobalKey();
  final GlobalKey _keyRepeat = GlobalKey();
  final GlobalKey _keySettings = GlobalKey();
  final GlobalKey _keyWaveform = GlobalKey();
  final GlobalKey islandToolTutorialKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _fs = context.read<FileSystem>();
    _filePicker = context.read<FilePicker>();
    _fileReferences = context.read<FileReferences>();
    _mediaRepo = context.read<MediaRepository>();
    _projectRepo = context.read<ProjectRepository>();

    _player = Player(
      context.read<AudioSystem>(),
      context.read<AudioSession>(),
      context.read<FileSystem>(),
      context.read<Wakelock>(),
      onIsPlayingChange: (_) => _updateState(),
      onPlaybackPositionChange: (_) => _updateState(),
    );

    _recorder = Recorder(
      context.read<AudioSystem>(),
      context.read<AudioSession>(),
      context.read<Wakelock>(),
      onIsRecordingChange: (_) => _handleIsRecordingChange(),
      onRecordingLengthChange: _handleRecordingLengthChange,
    );

    _waveformVisualizer = WaveformVisualizer(0, 0, 1, _rmsValues);

    _mediaPlayerBlock = Provider.of<ProjectBlock>(context, listen: false) as MediaPlayerBlock;
    _mediaPlayerBlock.timeLastModified = getCurrentDateTime();

    if (!widget.isQuickTool) {
      _project = context.read<Project>();
    }

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    _player.setVolume(_mediaPlayerBlock.volume);
    _player.setRepeat(_mediaPlayerBlock.looping);
    _player.markers.positions = _mediaPlayerBlock.markerPositions;
    _player.setTrim(_mediaPlayerBlock.rangeStart, _mediaPlayerBlock.rangeEnd);
    _player.setPitch(_mediaPlayerBlock.pitchSemitones);
    _player.setSpeed(_mediaPlayerBlock.speedFactor);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _waveFormWidth = MediaQuery.of(context).size.width - (TIOMusicParams.edgeInset * 2);
      _numOfBins = WaveformVisualizer.calculateBinCountForWidth(_waveFormWidth);

      setState(() => _isLoading = true);

      final fileExtension = _fs.toExtension(_mediaPlayerBlock.relativePath);
      if (mounted && fileExtension != null && !TIOMusicParams.audioFormats.contains(fileExtension)) {
        await showFormatNotSupportedDialog(context, fileExtension);
      }

      if (_mediaPlayerBlock.relativePath.isNotEmpty) {
        final success = await _player.loadAudioFile(_fs.toAbsoluteFilePath(_mediaPlayerBlock.relativePath));
        if (!success) {
          if (mounted) await showFileOpenFailedDialog(context, fileName: _mediaPlayerBlock.relativePath);
        } else {
          _rmsValues = await _player.getRmsValues(_numOfBins);
          _waveformVisualizer = WaveformVisualizer(
            0,
            _mediaPlayerBlock.rangeStart,
            _mediaPlayerBlock.rangeEnd,
            _rmsValues,
          );
        }
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (_player.loaded) _addShareOptionToMenu();

      await _updateState();

      if (mounted && widget.shouldAutoplay && _player.loaded) _autoplayAfterDelay();
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

  @override
  void deactivate() {
    _player.stop();
    _recorder.stop();
    super.deactivate();
  }

  @override
  void dispose() {
    _tutorial.dispose();
    _player.stop();
    super.dispose();
  }

  void _addShareOptionToMenu() {
    if (!_menuItems.contains(_shareMenuButton)) _menuItems.add(_shareMenuButton);
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
          alignText: ContentAlign.top,
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
      if (context.read<ProjectLibrary>().showWaveformTip && _player.loaded)
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

      if (context.read<ProjectLibrary>().showWaveformTip && _player.loaded) {
        context.read<ProjectLibrary>().showWaveformTip = false;
      }

      await _projectRepo.saveLibrary(context.read<ProjectLibrary>());
    }, context);
  }

  Future<void> _autoplayAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _player.setRepeat(false);
    await _recorder.stop();
    await _player.start();
  }

  double _effectiveEndEpsilon() {
    final totalMs = _player.fileDuration.inMilliseconds;
    if (totalMs <= 0) return _endEpsilon;
    final tickFraction = playbackSamplingIntervalInMs / totalMs;
    return math.max(_endEpsilon, tickFraction * 3.0);
  }

  bool _didFinishAndStopped({
    required bool wasPlaying,
    required bool isPlaying,
    required double currentPosition,
    required double previousPosition,
    required double start,
    required double end,
  }) {
    final bool fell = wasPlaying && !isPlaying;
    final epsilon = _effectiveEndEpsilon();
    final bool atEndNow = currentPosition >= (end - epsilon);
    final bool wasAtEnd = previousPosition >= (end - epsilon);
    final resetToStartAfterFinish = wasAtEnd && (currentPosition <= start + epsilon);
    final bool finished = atEndNow || wasAtEnd || resetToStartAfterFinish;
    return fell && finished;
  }

  void _updatePlaybackMemories({required bool isPlaying, required double position}) {
    _wasPlaying = isPlaying;
    _previousPosition = position;
  }

  Future<void> _updateState() async {
    if (!mounted) return;

    final bool isPlaying = _player.isPlaying;
    final double currentPosition = _player.playbackPosition;
    final double start = _mediaPlayerBlock.rangeStart;
    final double end = _mediaPlayerBlock.rangeEnd;

    setState(() {
      _waveformVisualizer = WaveformVisualizer(currentPosition, start, end, _rmsValues);
    });

    if (!mounted) return;

    final bool shouldAdvance =
        _project!.mediaPlayerRepeatAll &&
        _player.loaded &&
        _didFinishAndStopped(
          wasPlaying: _wasPlaying,
          isPlaying: isPlaying,
          currentPosition: currentPosition,
          previousPosition: _previousPosition,
          start: start,
          end: end,
        );

    _updatePlaybackMemories(isPlaying: isPlaying, position: currentPosition);

    if (shouldAdvance) await _goToNextMediaPlayerWithLoadedFile();
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

  Future<void> _handleRepeatToggle() async {
    await _projectRepo.saveLibrary(context.read<ProjectLibrary>());
    _player.setRepeat(_mediaPlayerBlock.looping);
  }

  String _getPitchSemitonesString(double semitones, String label) {
    if (semitones.abs() < 0.001) return '';
    return semitones > 0 ? '↑ $label' : '↓ $label';
  }

  void _shareFilePressed() async {
    await _filePicker.shareFile(_fs.toAbsoluteFilePath(_mediaPlayerBlock.relativePath));
  }

  void _onWaveGesture(Offset localPosition) async {
    double relativeTapPosition = localPosition.dx / _waveFormWidth;
    await _player.setPlaybackPosition(relativeTapPosition.clamp(0, 1));
    await _updateState();
  }

  void _skip(bool forward) async {
    await _player.skip(seconds: forward ? 10 : -10);
    await _updateState();
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

      _rmsValues = Float32List(0);
      _waveformVisualizer = WaveformVisualizer(0, _mediaPlayerBlock.rangeStart, _mediaPlayerBlock.rangeEnd, _rmsValues);

      await _player.stop();
      setState(() => _isLoading = true);

      final success = await _player.loadAudioFile(_fs.toAbsoluteFilePath(newRelativePath));
      if (!success) {
        if (mounted) await showFileOpenFailedDialog(context, fileName: _mediaPlayerBlock.relativePath);
      } else {
        _rmsValues = await _player.getRmsValues(_numOfBins);
        _waveformVisualizer = WaveformVisualizer(
          0,
          _mediaPlayerBlock.rangeStart,
          _mediaPlayerBlock.rangeEnd,
          _rmsValues,
        );

        _addShareOptionToMenu();
        _mediaPlayerBlock.markerPositions.clear();
        if (mounted) await _projectRepo.saveLibrary(projectLibrary);
      }
      setState(() => _isLoading = false);

      await _updateState();
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

  Future<void> _togglePlaying() async {
    if (_processingButtonClick) return;
    setState(() => _processingButtonClick = true);

    if (_player.isPlaying) {
      await _player.stop();
    } else {
      if (_recorder.isRecording) await _cancelRecording();
      await _player.start();
    }

    await Future.delayed(const Duration(milliseconds: TIOMusicParams.millisecondsPlayPauseDebounce));
    setState(() => _processingButtonClick = false);
  }

  Future<void> _toggleRecording() async {
    if (_processingButtonClick) return;
    setState(() => _processingButtonClick = true);

    if (!_recorder.isRecording && _player.loaded) {
      final overrideFile = await askForOverridingFileOnRecordingStart(context);
      if (overrideFile == null || !overrideFile) {
        setState(() => _processingButtonClick = false);
        return;
      }
    }

    _recorder.isRecording ? await _stopRecording() : await _startRecording();

    await Future.delayed(const Duration(milliseconds: TIOMusicParams.millisecondsPlayPauseDebounce));
    setState(() => _processingButtonClick = false);
  }

  Future<void> _startRecording() async {
    await _player.stop();
    await _recorder.start();
    setState(() {});
  }

  Future<void> _stopRecording() async {
    final success = await _recorder.stop();
    if (success && mounted) {
      setState(() => _recordingLength = Duration.zero);

      var projectTitle = widget.isQuickTool ? context.l10n.toolQuickTool : _project!.title;
      var newName = '$projectTitle-${_mediaPlayerBlock.title}';

      final samples = await _recorder.getRecordingSamples();
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

      if (mounted) await _projectRepo.saveLibrary(context.read<ProjectLibrary>());
      setState(() => _isLoading = true);

      final fileExtension = _fs.toExtension(_mediaPlayerBlock.relativePath);
      if (mounted && fileExtension != null && !TIOMusicParams.audioFormats.contains(fileExtension)) {
        await showFormatNotSupportedDialog(context, fileExtension);
      }

      final success = await _player.loadAudioFile(_fs.toAbsoluteFilePath(newRelativePath));
      if (!success) {
        if (mounted) await showFileOpenFailedDialog(context, fileName: _mediaPlayerBlock.relativePath);
      } else {
        _rmsValues = await _player.getRmsValues(_numOfBins);
        _waveformVisualizer = WaveformVisualizer(
          0,
          _mediaPlayerBlock.rangeStart,
          _mediaPlayerBlock.rangeEnd,
          _rmsValues,
        );

        _addShareOptionToMenu();
        _mediaPlayerBlock.markerPositions.clear();
        _player.markers.positions = [];
        if (mounted) await _projectRepo.saveLibrary(context.read<ProjectLibrary>());
      }
      setState(() => _isLoading = false);
    }
  }

  Future _askForKeepRecordingOnExit() async {
    _recorder.stop().then((success) async {
      if (success && mounted) {
        final projectTitle = widget.isQuickTool ? context.l10n.toolQuickTool : _project!.title;
        final newName = '$projectTitle-${_mediaPlayerBlock.title}';

        final samples = await _recorder.getRecordingSamples();
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

  Future<void> _cancelRecording() async {
    await _recorder.stop();
    setState(() => _recordingLength = Duration.zero);
  }

  void _handleIsRecordingChange() {
    if (!mounted) return;
    setState(() {});
  }

  void _handleRecordingLengthChange(Duration recordingLength) {
    if (!mounted) return;
    setState(() => _recordingLength = recordingLength);
  }

  Widget _switchMainButton(Key key) {
    if (_recorder.isRecording) {
      return _recordButton(TIOMusicParams.sizeBigButtons, key: key);
    } else {
      return _player.loaded
          ? _playPauseButton(TIOMusicParams.sizeBigButtons, key: key)
          : _recordButton(TIOMusicParams.sizeBigButtons, key: key);
    }
  }

  Widget _switchRightButton() {
    if (_recorder.isRecording) {
      return _cancelButton(TIOMusicParams.sizeSmallButtons);
    } else {
      return _player.loaded
          ? _recordButton(TIOMusicParams.sizeSmallButtons)
          : _playPauseButton(TIOMusicParams.sizeSmallButtons);
    }
  }

  Widget _cancelButton(double buttonSize, {Key? key}) {
    return OnOffButton(
      key: key,
      isActive: _recorder.isRecording,
      onTap: _cancelRecording,
      buttonSize: buttonSize,
      iconOff: Icons.close,
      iconOn: Icons.close,
      isDisabled: _isLoading,
    );
  }

  Widget _recordButton(double buttonSize, {Key? key}) {
    return OnOffButton(
      key: key,
      isActive: _recorder.isRecording,
      onTap: () async {
        await _toggleRecording();
        if (!mounted) return;
        if (context.read<ProjectLibrary>().showWaveformTip && _player.loaded) {
          _createTutorial();
          _tutorial.show(context);
        }
      },
      buttonSize: buttonSize,
      iconOff: Icons.mic,
      iconOn: Icons.stop,
      isDisabled: _isLoading,
    );
  }

  Widget _playPauseButton(double buttonSize, {Key? key}) {
    return OnOffButton(
      key: key,
      isActive: _player.isPlaying,
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
            await _player.setPlaybackPosition(pos);
            await _updateState();
          },
          icon: const Icon(Icons.arrow_drop_down, color: ColorTheme.primary, size: MediaPlayerParams.markerIconSize),
        ),
      );
      markers.add(marker);
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    var waveformHeight = 200.0;
    final l10n = context.l10n;
    final isMultiImportEnabled = !widget.isQuickTool;

    return ParentTool(
      barTitle: _mediaPlayerBlock.title,
      functionBeforeNavigatingBack: () async {
        if (_recorder.isRecording) await _askForKeepRecordingOnExit();
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
                      child: _recorder.isRecording
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              context.l10n.mediaPlayerRecording,
                              style: TextStyle(color: ColorTheme.tertiary, fontSize: waveformHeight / 10),
                            ),
                            Text(
                              context.l10n.formatDuration(_recordingLength),
                              style: TextStyle(color: ColorTheme.tertiary, fontSize: waveformHeight / 6),
                            ),
                          ],
                        ),
                      )
                          : GestureDetector(
                        onTapDown: (details) => _player.loaded ? _onWaveGesture(details.localPosition) : null,
                        onHorizontalDragUpdate: (details) =>
                        _player.loaded ? _onWaveGesture(details.localPosition) : null,
                        child: CustomPaint(
                          painter: _waveformVisualizer,
                          size: Size(_waveFormWidth, waveformHeight),
                        ),
                      ),
                    ),
                  Stack(children: _recorder.isRecording ? [] : _buildMarkers()),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(onPressed: () => _skip(false), child: Text('-10 ${l10n.mediaPlayerSecShort}')),
                Container(
                  key: _keyRepeat,
                  child: MediaPlayerRepeatButton(onToggle: _handleRepeatToggle),
                ),
                TextButton(onPressed: () => _skip(true), child: Text('+10 ${l10n.mediaPlayerSecShort}')),
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

            if (_player.loaded)
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
                        if (context.read<ProjectLibrary>().showWaveformTip && _player.loaded) {
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
                          if (context.read<ProjectLibrary>().showWaveformTip && _player.loaded) {
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
              _player.setVolume(vol);
            },
            onChange: (vol) => _player.setVolume(vol),
            onCancel: () => _player.setVolume(_mediaPlayerBlock.volume),
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
          // refactor into onConform, onChange, onCancel callback like for SetVolume, no ffi in settings page
          settingPage: SetTrim(rmsValues: _rmsValues, fileDuration: _player.fileDuration),
          block: _mediaPlayerBlock,
          callOnReturn: (value) => _updateState(),
          inactive: _isLoading,
        ),
        SettingsTile(
          title: l10n.mediaPlayerMarkers,
          subtitle: _mediaPlayerBlock.markerPositions.length.toString(),
          leadingIcon: Icons.arrow_drop_down,
          settingPage: EditMarkersPage(
            mediaPlayerBlock: _mediaPlayerBlock,
            fileDuration: _player.fileDuration,
            rmsValues: _rmsValues,
          ),
          block: _mediaPlayerBlock,
          callOnReturn: (value) {
            _player.markers.positions = _mediaPlayerBlock.markerPositions;
            setState(() {});
          },
          inactive: _isLoading,
        ),
        SettingsTile(
          title: l10n.mediaPlayerPitch,
          subtitle: _getPitchSemitonesString(
            _mediaPlayerBlock.pitchSemitones,
            l10n.mediaPlayerSemitones(_mediaPlayerBlock.pitchSemitones.round()),
          ),
          leadingIcon: Icons.height,
          // refactor into onConform, onChange, onCancel callback like for SetVolume, no ffi in settings page
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
          // refactor into onConform, onChange, onCancel callback like for SetVolume, no ffi in settings page
          settingPage: const SetSpeed(),
          block: _mediaPlayerBlock,
          callOnReturn: (value) => setState(() {}),
          inactive: _isLoading,
        ),
      ],
    );
  }
}
