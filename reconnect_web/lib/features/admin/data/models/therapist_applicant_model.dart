class TherapistApplicantModel {
  final String therapistId;
  final String fullName;
  final String email;
  final String? hometown;
  final int? birthYear;
  final String? voiceDescription;
  final String? specialization;
  final String? therapyStyle;
  final String? bio;
  final String? meetingLink;
  final String? avatarUrl;
  final String approvalStatus; // PENDING/ACTIVE/REJECTED
  final int credentialCount;
  final bool active;
  final int caseloadCount;
  final int caseloadLimit;
  final bool caseloadFull;

  TherapistApplicantModel({
    required this.therapistId,
    required this.fullName,
    required this.email,
    required this.hometown,
    required this.birthYear,
    required this.voiceDescription,
    required this.specialization,
    required this.therapyStyle,
    required this.bio,
    required this.meetingLink,
    required this.avatarUrl,
    required this.approvalStatus,
    required this.credentialCount,
    required this.active,
    required this.caseloadCount,
    required this.caseloadLimit,
    required this.caseloadFull,
  });

  factory TherapistApplicantModel.fromJson(Map<String, dynamic> json) {
    return TherapistApplicantModel(
      therapistId: json['therapistId']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      hometown: json['hometown']?.toString(),
      birthYear: (json['birthYear'] as num?)?.toInt(),
      voiceDescription: json['voiceDescription']?.toString(),
      specialization: json['specialization']?.toString(),
      therapyStyle: json['therapyStyle']?.toString(),
      bio: json['bio']?.toString(),
      meetingLink: json['meetingLink']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      approvalStatus: json['approvalStatus']?.toString() ?? 'PENDING',
      credentialCount: (json['credentialCount'] as num?)?.toInt() ?? 0,
      active: (json['active'] as bool?) ?? true,
      caseloadCount: (json['caseloadCount'] as num?)?.toInt() ?? 0,
      caseloadLimit: (json['caseloadLimit'] as num?)?.toInt() ?? 20,
      caseloadFull: (json['caseloadFull'] as bool?) ?? false,
    );
  }
}
