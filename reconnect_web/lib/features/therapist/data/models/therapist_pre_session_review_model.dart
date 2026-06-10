class TherapistPreSessionReviewModel {
  final int? baselineLsasScore;
  final int? currentLsasScore;
  final int? latestLsasScore;
  final String goalSummary;
  final int fearLadderTotalItems;
  final int fearLadderUnlockedItems;
  final int behavioralExperimentsLastWeek;
  final int thoughtRecordsLastWeek;
  final int dailyCheckinsLastWeek;
  final int recentHomeworkCompleted;
  final int? programWeek;
  final String programPhaseLabel;
  final int currentRiskScore;
  final bool redFlagActive;
  final String? upcomingAppointmentAt;
  final List<String> recentThoughtRecordSummaries;
  final List<String> recentBehavioralExperimentSummaries;
  final List<String> recentDailyCheckinSummaries;

  const TherapistPreSessionReviewModel({
    required this.baselineLsasScore,
    required this.currentLsasScore,
    required this.latestLsasScore,
    required this.goalSummary,
    required this.fearLadderTotalItems,
    required this.fearLadderUnlockedItems,
    required this.behavioralExperimentsLastWeek,
    required this.thoughtRecordsLastWeek,
    required this.dailyCheckinsLastWeek,
    required this.recentHomeworkCompleted,
    required this.programWeek,
    required this.programPhaseLabel,
    required this.currentRiskScore,
    required this.redFlagActive,
    required this.upcomingAppointmentAt,
    required this.recentThoughtRecordSummaries,
    required this.recentBehavioralExperimentSummaries,
    required this.recentDailyCheckinSummaries,
  });

  factory TherapistPreSessionReviewModel.fromJson(Map<String, dynamic> json) {
    return TherapistPreSessionReviewModel(
      baselineLsasScore: (json['baselineLsasScore'] as num?)?.toInt(),
      currentLsasScore: (json['currentLsasScore'] as num?)?.toInt(),
      latestLsasScore: (json['latestLsasScore'] as num?)?.toInt(),
      goalSummary: json['goalSummary']?.toString() ?? '',
      fearLadderTotalItems: (json['fearLadderTotalItems'] as num?)?.toInt() ?? 0,
      fearLadderUnlockedItems: (json['fearLadderUnlockedItems'] as num?)?.toInt() ?? 0,
      behavioralExperimentsLastWeek: (json['behavioralExperimentsLastWeek'] as num?)?.toInt() ?? 0,
      thoughtRecordsLastWeek: (json['thoughtRecordsLastWeek'] as num?)?.toInt() ?? 0,
      dailyCheckinsLastWeek: (json['dailyCheckinsLastWeek'] as num?)?.toInt() ?? 0,
      recentHomeworkCompleted: (json['recentHomeworkCompleted'] as num?)?.toInt() ?? 0,
      programWeek: (json['programWeek'] as num?)?.toInt(),
      programPhaseLabel: json['programPhaseLabel']?.toString() ?? '',
      currentRiskScore: (json['currentRiskScore'] as num?)?.toInt() ?? 0,
      redFlagActive: json['redFlagActive'] == true,
      upcomingAppointmentAt: json['upcomingAppointmentAt']?.toString(),
      recentThoughtRecordSummaries: (json['recentThoughtRecordSummaries'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      recentBehavioralExperimentSummaries: (json['recentBehavioralExperimentSummaries'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      recentDailyCheckinSummaries: (json['recentDailyCheckinSummaries'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}
