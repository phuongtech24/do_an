class LsasSubmissionModel {
  final String? id;
  final String patientId;
  final String submissionType;
  final int fearTotal;
  final int avoidanceTotal;
  final int totalScore;
  final String? createDate;

  const LsasSubmissionModel({
    this.id,
    required this.patientId,
    required this.submissionType,
    required this.fearTotal,
    required this.avoidanceTotal,
    required this.totalScore,
    this.createDate,
  });

  factory LsasSubmissionModel.fromJson(Map<String, dynamic> json) {
    return LsasSubmissionModel(
      id: json['id']?.toString(),
      patientId: json['patientId']?.toString() ?? '',
      submissionType: json['submissionType']?.toString() ?? 'PERIODIC',
      fearTotal: (json['fearTotal'] as num?)?.toInt() ?? 0,
      avoidanceTotal: (json['avoidanceTotal'] as num?)?.toInt() ?? 0,
      totalScore: (json['totalScore'] as num?)?.toInt() ?? 0,
      createDate: json['createDate']?.toString(),
    );
  }
}
