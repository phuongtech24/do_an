class TherapistDirectoryItemModel {
  final String therapistId;
  final String fullName;
  final String? specialization;
  final String? bio;
  final String? avatarUrl;
  final String? email;
  final int caseloadCount;
  final int caseloadLimit;
  final bool caseloadFull;

  const TherapistDirectoryItemModel({
    required this.therapistId,
    required this.fullName,
    this.specialization,
    this.bio,
    this.avatarUrl,
    this.email,
    required this.caseloadCount,
    required this.caseloadLimit,
    required this.caseloadFull,
  });

  factory TherapistDirectoryItemModel.fromJson(Map<String, dynamic> json) {
    return TherapistDirectoryItemModel(
      therapistId: json['therapistId']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      specialization: json['specialization']?.toString(),
      bio: json['bio']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      email: json['email']?.toString(),
      caseloadCount: (json['caseloadCount'] as num?)?.toInt() ?? 0,
      caseloadLimit: (json['caseloadLimit'] as num?)?.toInt() ?? 20,
      caseloadFull: json['caseloadFull'] == true,
    );
  }
}
