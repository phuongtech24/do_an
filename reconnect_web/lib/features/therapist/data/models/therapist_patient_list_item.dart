class TherapistPatientListItem {
  final String patientId;
  final String nickname;
  final int currentRiskScore;
  final bool isRedFlagActive;

  TherapistPatientListItem({
    required this.patientId,
    required this.nickname,
    required this.currentRiskScore,
    required this.isRedFlagActive,
  });

  factory TherapistPatientListItem.fromJson(Map<String, dynamic> json) {
    return TherapistPatientListItem(
      patientId: json['patientId']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '',
      currentRiskScore: (json['currentRiskScore'] as num?)?.toInt() ?? 0,
      isRedFlagActive: json['isRedFlagActive'] == true,
    );
  }
}

