import 'patient_quest_model.dart';
import 'roadmap_program_module_model.dart';

class RoadmapProgramStateModel {
  final int? programWeek;
  final String programPhaseCode;
  final String programPhaseLabel;
  final String nextRecommendedIntervention;
  final String? therapyProgramStartedAt;
  final String? weekStartDate;
  final String? weekEndDate;
  final String? nextRerateAt;
  final List<RoadmapProgramModuleModel> unlockedModules;
  final List<RoadmapProgramModuleModel> lockedModules;
  final List<PatientQuestModel> todayAssignments;

  const RoadmapProgramStateModel({
    required this.programWeek,
    required this.programPhaseCode,
    required this.programPhaseLabel,
    required this.nextRecommendedIntervention,
    required this.therapyProgramStartedAt,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.nextRerateAt,
    required this.unlockedModules,
    required this.lockedModules,
    required this.todayAssignments,
  });

  static const empty = RoadmapProgramStateModel(
    programWeek: null,
    programPhaseCode: '',
    programPhaseLabel: '',
    nextRecommendedIntervention: '',
    therapyProgramStartedAt: null,
    weekStartDate: null,
    weekEndDate: null,
    nextRerateAt: null,
    unlockedModules: [],
    lockedModules: [],
    todayAssignments: [],
  );

  factory RoadmapProgramStateModel.fromJson(Map<String, dynamic> json) {
    final unlocked = (json['unlockedModules'] as List<dynamic>? ?? [])
        .map((item) => RoadmapProgramModuleModel.fromJson(item as Map<String, dynamic>))
        .toList();
    final locked = (json['lockedModules'] as List<dynamic>? ?? [])
        .map((item) => RoadmapProgramModuleModel.fromJson(item as Map<String, dynamic>))
        .toList();
    final assignments = (json['todayAssignments'] as List<dynamic>? ?? [])
        .map((item) => PatientQuestModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return RoadmapProgramStateModel(
      programWeek: (json['programWeek'] as num?)?.toInt(),
      programPhaseCode: json['programPhaseCode']?.toString() ?? '',
      programPhaseLabel: json['programPhaseLabel']?.toString() ?? '',
      nextRecommendedIntervention: json['nextRecommendedIntervention']?.toString() ?? '',
      therapyProgramStartedAt: json['therapyProgramStartedAt']?.toString(),
      weekStartDate: json['weekStartDate']?.toString(),
      weekEndDate: json['weekEndDate']?.toString(),
      nextRerateAt: json['nextRerateAt']?.toString(),
      unlockedModules: unlocked,
      lockedModules: locked,
      todayAssignments: assignments,
    );
  }
}
