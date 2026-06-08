class PatientProfileModel {
  final String patientId;
  final String nickname;
  final String avatarIcon;
  final bool anonymousModeEnabled;
  final String? realFullName;
  final String? dateOfBirth;
  final String? gender;
  final String? phoneNumber;
  final String? emergencyContactPhone;
  final String? educationLevel;
  final String? occupation;
  final String? relationshipStatus;
  final String? medicalHistory;
  final bool lsasDemoCompleted;
  final bool safetyGateCompleted;
  final bool medicalProfileCompleted;

  const PatientProfileModel({
    required this.patientId,
    required this.nickname,
    required this.avatarIcon,
    required this.anonymousModeEnabled,
    this.realFullName,
    this.dateOfBirth,
    this.gender,
    this.phoneNumber,
    this.emergencyContactPhone,
    this.educationLevel,
    this.occupation,
    this.relationshipStatus,
    this.medicalHistory,
    required this.lsasDemoCompleted,
    required this.safetyGateCompleted,
    required this.medicalProfileCompleted,
  });

  factory PatientProfileModel.fromJson(Map<String, dynamic> json) {
    String? nullableString(dynamic value) {
      final text = value?.toString().trim();
      return (text == null || text.isEmpty) ? null : text;
    }

    return PatientProfileModel(
      patientId: json['patientId']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '',
      avatarIcon: json['avatarIcon']?.toString() ?? 'avatar_boy_1',
      anonymousModeEnabled: json['anonymousModeEnabled'] != false,
      realFullName: nullableString(json['realFullName']),
      dateOfBirth: nullableString(json['dateOfBirth']),
      gender: nullableString(json['gender']),
      phoneNumber: nullableString(json['phoneNumber']),
      emergencyContactPhone: nullableString(json['emergencyContactPhone']),
      educationLevel: nullableString(json['educationLevel']),
      occupation: nullableString(json['occupation']),
      relationshipStatus: nullableString(json['relationshipStatus']),
      medicalHistory: nullableString(json['medicalHistory']),
      lsasDemoCompleted: json['lsasDemoCompleted'] == true,
      safetyGateCompleted: json['safetyGateCompleted'] == true,
      medicalProfileCompleted: json['medicalProfileCompleted'] == true,
    );
  }
}
