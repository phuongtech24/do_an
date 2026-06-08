class TherapistPatientListItem {
  final String patientId;
  final String nickname;
  final int currentRiskScore;
  final bool isRedFlagActive;
  final int currentLsasScore;
  final int baselineLsasScore;
  final String primaryGoal;
  final String therapistName;
  final String? avatarIcon;
  final bool anonymousModeEnabled;
  final String? realFullName;
  final String? phoneNumber;
  final String? emergencyContactPhone;
  final String? dateOfBirth;
  final String? gender;
  final String? educationLevel;
  final String? occupation;
  final String? relationshipStatus;
  final String? medicalHistory;

  TherapistPatientListItem({
    required this.patientId,
    required this.nickname,
    required this.currentRiskScore,
    required this.isRedFlagActive,
    required this.currentLsasScore,
    required this.baselineLsasScore,
    required this.primaryGoal,
    required this.therapistName,
    this.avatarIcon,
    this.anonymousModeEnabled = true,
    this.realFullName,
    this.phoneNumber,
    this.emergencyContactPhone,
    this.dateOfBirth,
    this.gender,
    this.educationLevel,
    this.occupation,
    this.relationshipStatus,
    this.medicalHistory,
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
      avatarIcon: json['avatarIcon']?.toString(),
      anonymousModeEnabled: json['anonymousModeEnabled'] != false,
      realFullName: json['realFullName']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      emergencyContactPhone: json['emergencyContactPhone']?.toString(),
      dateOfBirth: json['dateOfBirth']?.toString(),
      gender: json['gender']?.toString(),
      educationLevel: json['educationLevel']?.toString(),
      occupation: json['occupation']?.toString(),
      relationshipStatus: json['relationshipStatus']?.toString(),
      medicalHistory: json['medicalHistory']?.toString(),
    );
  }
}
