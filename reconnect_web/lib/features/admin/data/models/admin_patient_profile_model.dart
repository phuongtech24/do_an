class AdminPatientProfileModel {
  final String patientId;
  final String? email;
  final String? nickname;
  final String? status;
  final int? currentRiskScore;
  final bool? redFlagActive;
  final String? graduatedAt;
  final bool? active;
  final String? therapistId;
  final String? therapistName;
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

  AdminPatientProfileModel({
    required this.patientId,
    this.email,
    this.nickname,
    this.status,
    this.currentRiskScore,
    this.redFlagActive,
    this.graduatedAt,
    this.active,
    this.therapistId,
    this.therapistName,
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

  factory AdminPatientProfileModel.fromJson(Map<String, dynamic> json) {
    return AdminPatientProfileModel(
      patientId: json['patientId']?.toString() ?? '',
      email: json['email']?.toString(),
      nickname: json['nickname']?.toString(),
      status: json['status']?.toString(),
      currentRiskScore: json['currentRiskScore'] is num ? (json['currentRiskScore'] as num).toInt() : null,
      redFlagActive: json['redFlagActive'] is bool ? json['redFlagActive'] as bool : null,
      graduatedAt: json['graduatedAt']?.toString(),
      active: json['active'] is bool ? json['active'] as bool : null,
      therapistId: json['therapistId']?.toString(),
      therapistName: json['therapistName']?.toString(),
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

  AdminPatientProfileModel copyWith({
    bool? active,
    String? therapistId,
    String? therapistName,
    String? avatarIcon,
    bool? anonymousModeEnabled,
    String? realFullName,
    String? phoneNumber,
    String? emergencyContactPhone,
    String? dateOfBirth,
    String? gender,
    String? educationLevel,
    String? occupation,
    String? relationshipStatus,
    String? medicalHistory,
  }) {
    return AdminPatientProfileModel(
      patientId: patientId,
      email: email,
      nickname: nickname,
      status: status,
      currentRiskScore: currentRiskScore,
      redFlagActive: redFlagActive,
      graduatedAt: graduatedAt,
      active: active ?? this.active,
      therapistId: therapistId ?? this.therapistId,
      therapistName: therapistName ?? this.therapistName,
      avatarIcon: avatarIcon ?? this.avatarIcon,
      anonymousModeEnabled: anonymousModeEnabled ?? this.anonymousModeEnabled,
      realFullName: realFullName ?? this.realFullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      educationLevel: educationLevel ?? this.educationLevel,
      occupation: occupation ?? this.occupation,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      medicalHistory: medicalHistory ?? this.medicalHistory,
    );
  }
}
