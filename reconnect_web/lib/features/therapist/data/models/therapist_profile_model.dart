class TherapistProfileModel {
  final String therapistId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? hometown;
  final int? birthYear;
  final String? voiceDescription;
  final String? specialization;
  final String? therapyStyle;
  final String? bio;
  final String? meetingLink;
  final String? avatarUrl;
  final String approvalStatus;
  final bool active;

  TherapistProfileModel({
    required this.therapistId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.hometown,
    required this.birthYear,
    required this.voiceDescription,
    required this.specialization,
    required this.therapyStyle,
    required this.bio,
    required this.meetingLink,
    required this.avatarUrl,
    required this.approvalStatus,
    required this.active,
  });

  factory TherapistProfileModel.fromJson(Map<String, dynamic> json) {
    String? nullableString(Object? value) {
      final text = value?.toString();
      return text == null || text.isEmpty ? null : text;
    }

    return TherapistProfileModel(
      therapistId: json['therapistId']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString(),
      hometown: nullableString(json['hometown']),
      birthYear: (json['birthYear'] as num?)?.toInt(),
      voiceDescription: nullableString(json['voiceDescription']),
      specialization: nullableString(json['specialization']),
      therapyStyle: nullableString(json['therapyStyle']),
      bio: nullableString(json['bio']),
      meetingLink: nullableString(json['meetingLink']),
      avatarUrl: nullableString(json['avatarUrl']),
      approvalStatus: json['approvalStatus']?.toString() ?? 'PENDING',
      active: (json['active'] as bool?) ?? true,
    );
  }
}
