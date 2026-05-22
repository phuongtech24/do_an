class TherapistApplicantModel {
  final String therapistId;
  final String fullName;
  final String email;
  final String? specialization;
  final String approvalStatus; // PENDING/ACTIVE/REJECTED

  TherapistApplicantModel({
    required this.therapistId,
    required this.fullName,
    required this.email,
    required this.specialization,
    required this.approvalStatus,
  });

  factory TherapistApplicantModel.fromJson(Map<String, dynamic> json) {
    return TherapistApplicantModel(
      therapistId: json['therapistId']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      specialization: json['specialization']?.toString(),
      approvalStatus: json['approvalStatus']?.toString() ?? 'PENDING',
    );
  }
}

