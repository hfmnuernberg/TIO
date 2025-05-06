import 'dart:collection';
import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:flutter/foundation.dart';
import 'package:tiomusic/models/project.dart';

part 'project_library.g.dart';

@JsonSerializable(explicitToJson: true)
class ProjectLibrary extends ChangeNotifier {
  late List<Project> _projects;
  @JsonKey(defaultValue: [])
  UnmodifiableListView<Project> get projects => UnmodifiableListView(_projects);
  set projects(List<Project> newProjects) => _projects = newProjects;

  late int _visitedToolsCounter;
  @JsonKey(defaultValue: 0)
  int get visitedToolsCounter => _visitedToolsCounter;
  set visitedToolsCounter(int newValue) {
    _visitedToolsCounter = newValue;
  }

  late bool _neverShowSurveyAgain;
  @JsonKey(defaultValue: false)
  bool get neverShowSurveyAgain => _neverShowSurveyAgain;
  set neverShowSurveyAgain(bool newValue) {
    _neverShowSurveyAgain = newValue;
  }

  late int _idxCheckShowSurvey;
  @JsonKey(defaultValue: 0)
  int get idxCheckShowSurvey => _idxCheckShowSurvey;
  set idxCheckShowSurvey(int newValue) {
    _idxCheckShowSurvey = newValue;
  }

  final List<int> showSurveyAtVisits = [10, 50, 100];

  @JsonKey(defaultValue: true)
  late bool showHomepageTutorial; // on homepage
  @JsonKey(defaultValue: true)
  late bool showProjectPageTutorial; // on project page

  @JsonKey(defaultValue: true)
  late bool showQuickToolTutorial; // on parent tool if quick tool
  @JsonKey(defaultValue: true)
  late bool showToolTutorial; // on parent tool if not quick tool

  @JsonKey(defaultValue: true)
  late bool showIslandTutorial; // on parent tool

  @JsonKey(defaultValue: true)
  late bool showTunerTutorial;
  @JsonKey(defaultValue: true)
  late bool showMetronomeTutorial;
  @JsonKey(defaultValue: true)
  late bool showMediaPlayerTutorial;
  @JsonKey(defaultValue: true)
  late bool showPianoTutorial;
  @JsonKey(defaultValue: true)
  late bool showImageTutorial;

  @JsonKey(defaultValue: true)
  late bool showWaveformTip;
  @JsonKey(defaultValue: true)
  late bool showBeatToggleTip;

  ProjectLibrary(
    List<Project> projects,
    int visitedToolsCounter,
    int idxCheckShowSurvey,
    bool neverShowSurveyAgain,
    this.showHomepageTutorial,
    this.showProjectPageTutorial,
    this.showToolTutorial,
    this.showQuickToolTutorial,
    this.showIslandTutorial,
    this.showTunerTutorial,
    this.showMetronomeTutorial,
    this.showMediaPlayerTutorial,
    this.showPianoTutorial,
    this.showImageTutorial,
    this.showWaveformTip,
    this.showBeatToggleTip,
  ) {
    _projects = projects;
    _visitedToolsCounter = visitedToolsCounter;
    _idxCheckShowSurvey = idxCheckShowSurvey;
    _neverShowSurveyAgain = neverShowSurveyAgain;
  }

  ProjectLibrary.withDefaults() {
    _projects = List.empty(growable: true);
    _visitedToolsCounter = 0;
    _idxCheckShowSurvey = 0;
    _neverShowSurveyAgain = false;
    showHomepageTutorial = true;
    showProjectPageTutorial = true;
    showToolTutorial = true;
    showQuickToolTutorial = true;
    showIslandTutorial = true;
    showTunerTutorial = true;
    showMetronomeTutorial = true;
    showMediaPlayerTutorial = true;
    showPianoTutorial = true;
    showImageTutorial = true;
    showWaveformTip = true;
    showBeatToggleTip = true;
  }

  factory ProjectLibrary.fromJson(Map<String, dynamic> json) => _$ProjectLibraryFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectLibraryToJson(this);

  void resetAllTutorials() {
    showHomepageTutorial = true;
    showProjectPageTutorial = true;
    showToolTutorial = true;
    showQuickToolTutorial = true;
    showIslandTutorial = true;
    showTunerTutorial = true;
    showMetronomeTutorial = true;
    showMediaPlayerTutorial = true;
    showPianoTutorial = true;
    showImageTutorial = true;
    showWaveformTip = true;
    showBeatToggleTip = true;
  }

  void dismissAllTutorials() {
    showHomepageTutorial = false;
    showProjectPageTutorial = false;
    showToolTutorial = false;
    showQuickToolTutorial = false;
    showIslandTutorial = false;
    showTunerTutorial = false;
    showMetronomeTutorial = false;
    showMediaPlayerTutorial = false;
    showPianoTutorial = false;
    showImageTutorial = false;
    showWaveformTip = false;
    showBeatToggleTip = false;
  }

  void addProject(Project newProject) {
    _projects.insert(0, newProject);
    notifyListeners();
  }

  void removeProject(Project project) {
    _projects.remove(project);
    notifyListeners();
  }

  void clearProjects() {
    _projects.clear();
    notifyListeners();
  }
}
