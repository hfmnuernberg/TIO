// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_library.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectLibrary _$ProjectLibraryFromJson(Map<String, dynamic> json) => ProjectLibrary(
  (json['projects'] as List<dynamic>?)?.map((e) => Project.fromJson(e as Map<String, dynamic>)).toList() ?? [],
  (json['visitedToolsCounter'] as num?)?.toInt() ?? 0,
  (json['idxCheckShowSurvey'] as num?)?.toInt() ?? 0,
  json['neverShowSurveyAgain'] as bool? ?? false,
  json['showHomepageTutorial'] as bool? ?? true,
  json['showProjectPageTutorial'] as bool? ?? true,
  json['showToolTutorial'] as bool? ?? true,
  json['showQuickToolTutorial'] as bool? ?? true,
  json['showIslandTutorial'] as bool? ?? true,
  json['showTunerTutorial'] as bool? ?? true,
  json['showMetronomeTutorial'] as bool? ?? true,
  json['showMediaPlayerTutorial'] as bool? ?? true,
  json['showPianoTutorial'] as bool? ?? true,
  json['showImageTutorial'] as bool? ?? true,
  json['showWaveformTip'] as bool? ?? true,
  json['showBeatToggleTip'] as bool? ?? true,
);

Map<String, dynamic> _$ProjectLibraryToJson(ProjectLibrary instance) => <String, dynamic>{
  'projects': instance.projects.map((e) => e.toJson()).toList(),
  'visitedToolsCounter': instance.visitedToolsCounter,
  'neverShowSurveyAgain': instance.neverShowSurveyAgain,
  'idxCheckShowSurvey': instance.idxCheckShowSurvey,
  'showHomepageTutorial': instance.showHomepageTutorial,
  'showProjectPageTutorial': instance.showProjectPageTutorial,
  'showQuickToolTutorial': instance.showQuickToolTutorial,
  'showToolTutorial': instance.showToolTutorial,
  'showIslandTutorial': instance.showIslandTutorial,
  'showTunerTutorial': instance.showTunerTutorial,
  'showMetronomeTutorial': instance.showMetronomeTutorial,
  'showMediaPlayerTutorial': instance.showMediaPlayerTutorial,
  'showPianoTutorial': instance.showPianoTutorial,
  'showImageTutorial': instance.showImageTutorial,
  'showWaveformTip': instance.showWaveformTip,
  'showBeatToggleTip': instance.showBeatToggleTip,
};
