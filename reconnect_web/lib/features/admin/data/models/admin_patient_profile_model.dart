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
    );
  }

  AdminPatientProfileModel copyWith({
    bool? active,
    String? therapistId,
    String? therapistName,
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
    );
  }
}

