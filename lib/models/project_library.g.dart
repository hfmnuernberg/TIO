// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_library.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectLibrary _$ProjectLibraryFromJson(Map<String, dynamic> json) =>
    ProjectLibrary(
      (json['projects'] as List<dynamic>?)
              ?.map((e) => Project.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      (json['visitedToolsCounter'] as num?)?.toInt() ?? 0,
      (json['idxCheckShowSurvey'] as num?)?.toInt() ?? 0,
      json['neverShowSurveyAgain'] as bool? ?? false,
      json['showHomepageTutorial'] as bool? ?? true,
      json['showProjectPageTutorial'] as bool? ?? true,
      json['showToolTutorial'] as bool? ?? true,
      json['showQuickToolTutorial'] as bool? ?? true,
      json['showTunerIslandTutorial'] as bool? ?? true,
      json['showTunerTutorial'] as bool? ?? true,
      json['showMetronomeIslandTutorial'] as bool? ?? true,
      json['showMetronomeSimpleTutorial'] as bool? ?? true,
      json['showMetronomeAdvancedTutorial'] as bool? ?? true,
      json['showMetronomeTutorial'] as bool? ?? true,
      json['showMediaPlayerIslandTutorial'] as bool? ?? true,
      json['showMediaPlayerTutorial'] as bool? ?? true,
      json['showPianoIslandTutorial'] as bool? ?? true,
      json['showPianoTutorial'] as bool? ?? true,
      json['showImageTutorial'] as bool? ?? true,
      json['showWaveformTip'] as bool? ?? true,
      json['showBeatToggleTip'] as bool? ?? true,
      (json['seenFlashCards'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
    );

Map<String, dynamic> _$ProjectLibraryToJson(ProjectLibrary instance) =>
    <String, dynamic>{
      'projects': instance.projects.map((e) => e.toJson()).toList(),
      'seenFlashCards': instance.seenFlashCards,
      'visitedToolsCounter': instance.visitedToolsCounter,
      'neverShowSurveyAgain': instance.neverShowSurveyAgain,
      'idxCheckShowSurvey': instance.idxCheckShowSurvey,
      'showHomepageTutorial': instance.showHomepageTutorial,
      'showProjectPageTutorial': instance.showProjectPageTutorial,
      'showQuickToolTutorial': instance.showQuickToolTutorial,
      'showToolTutorial': instance.showToolTutorial,
      'showTunerIslandTutorial': instance.showTunerIslandTutorial,
      'showTunerTutorial': instance.showTunerTutorial,
      'showMetronomeIslandTutorial': instance.showMetronomeIslandTutorial,
      'showMetronomeTutorial': instance.showMetronomeTutorial,
      'showMetronomeAdvancedTutorial': instance.showMetronomeAdvancedTutorial,
      'showMetronomeSimpleTutorial': instance.showMetronomeSimpleTutorial,
      'showMediaPlayerIslandTutorial': instance.showMediaPlayerIslandTutorial,
      'showMediaPlayerTutorial': instance.showMediaPlayerTutorial,
      'showPianoIslandTutorial': instance.showPianoIslandTutorial,
      'showPianoTutorial': instance.showPianoTutorial,
      'showImageTutorial': instance.showImageTutorial,
      'showWaveformTip': instance.showWaveformTip,
      'showBeatToggleTip': instance.showBeatToggleTip,
    };
