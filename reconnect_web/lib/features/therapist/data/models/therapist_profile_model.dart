class TherapistProfileModel {
  final String therapistId;
  final String fullName;
  final String email;
  final String? specialization;
  final String? bio;
  final String? meetingLink;
  final String? avatarUrl;
  final String approvalStatus;
  final bool active;

  TherapistProfileModel({
    required this.therapistId,
    required this.fullName,
    required this.email,
    required this.specialization,
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
      specialization: nullableString(json['specialization']),
      bio: nullableString(json['bio']),
      meetingLink: nullableString(json['meetingLink']),
      avatarUrl: nullableString(json['avatarUrl']),
      approvalStatus: json['approvalStatus']?.toString() ?? 'PENDING',
      active: (json['active'] as bool?) ?? true,
    );
  }
}
