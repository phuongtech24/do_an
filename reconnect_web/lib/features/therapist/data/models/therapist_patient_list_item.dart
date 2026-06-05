class TherapistPatientListItem {
  final String patientId;
  final String nickname;
  final int currentRiskScore;
  final bool isRedFlagActive;
  final int currentLsasScore;
  final int baselineLsasScore;
  final String primaryGoal;
  final String therapistName;

  TherapistPatientListItem({
    required this.patientId,
    required this.nickname,
    required this.currentRiskScore,
    required this.isRedFlagActive,
    required this.currentLsasScore,
    required this.baselineLsasScore,
    required this.primaryGoal,
    required this.therapistName,
  });

  factory TherapistPatientListItem.fromJson(Map<String, dynamic> json) {
    return TherapistPatientListItem(
      patientId: json['patientId']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '',
      currentRiskScore: (json['currentRiskScore'] as num?)?.toInt() ?? 0,
      isRedFlagActive: json['isRedFlagActive'] == true,
      currentLsasScore: (json['currentLsasScore'] as num?)?.toInt() ?? 0,
      baselineLsasScore: (json['baselineLsasScore'] as num?)?.toInt() ?? 0,
      primaryGoal: json['primaryGoal']?.toString() ?? '',
      therapistName: json['therapistName']?.toString() ?? '',
    );
  }
}
