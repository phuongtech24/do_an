class TherapistDirectoryItemModel {
  final String therapistId;
  final String fullName;
  final String? phoneNumber;
  final String? hometown;
  final int? birthYear;
  final String? voiceDescription;
  final String? specialization;
  final String? therapyStyle;
  final String? bio;
  final String? avatarUrl;
  final String? email;
  final int credentialCount;
  final int caseloadCount;
  final int caseloadLimit;
  final bool caseloadFull;

  const TherapistDirectoryItemModel({
    required this.therapistId,
    required this.fullName,
    this.phoneNumber,
    this.hometown,
    this.birthYear,
    this.voiceDescription,
    this.specialization,
    this.therapyStyle,
    this.bio,
    this.avatarUrl,
    this.email,
    required this.credentialCount,
    required this.caseloadCount,
    required this.caseloadLimit,
    required this.caseloadFull,
  });

  factory TherapistDirectoryItemModel.fromJson(Map<String, dynamic> json) {
    String? nullableString(Object? value) {
      final text = value?.toString();
      return text == null || text.isEmpty ? null : text;
    }

    return TherapistDirectoryItemModel(
      therapistId: json['therapistId']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      phoneNumber: nullableString(json['phoneNumber']),
      hometown: nullableString(json['hometown']),
      birthYear: (json['birthYear'] as num?)?.toInt(),
      voiceDescription: nullableString(json['voiceDescription']),
      specialization: nullableString(json['specialization']),
      therapyStyle: nullableString(json['therapyStyle']),
      bio: nullableString(json['bio']),
      avatarUrl: nullableString(json['avatarUrl']),
      email: nullableString(json['email']),
      credentialCount: (json['credentialCount'] as num?)?.toInt() ?? 0,
      caseloadCount: (json['caseloadCount'] as num?)?.toInt() ?? 0,
      caseloadLimit: (json['caseloadLimit'] as num?)?.toInt() ?? 20,
      caseloadFull: json['caseloadFull'] == true,
    );
  }
}
