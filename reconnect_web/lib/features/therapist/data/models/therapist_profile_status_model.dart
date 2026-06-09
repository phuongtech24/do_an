class TherapistProfileStatusModel {
  final String approvalStatus; // PENDING/ACTIVE/REJECTED
  final int credentialCount;

  TherapistProfileStatusModel({
    required this.approvalStatus,
    required this.credentialCount,
  });

  factory TherapistProfileStatusModel.fromJson(Map<String, dynamic> json) {
    return TherapistProfileStatusModel(
      approvalStatus: json['approvalStatus']?.toString() ?? 'PENDING',
      credentialCount: (json['credentialCount'] as num?)?.toInt() ?? 0,
    );
  }
}

