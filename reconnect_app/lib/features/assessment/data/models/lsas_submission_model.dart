class LsasSubmissionModel {
  final String? id;
  final String patientId;
  final String submissionType;
  final int fearTotal;
  final int avoidanceTotal;
  final int totalScore;
  final String? createDate;
  final String severityBand;
  final String severityLabel;
  final String clinicalRoute;
  final String summaryMessage;
  final String recommendedNextStep;
  final bool clinicalAttention;
  final bool redFlagTriggered;

  const LsasSubmissionModel({
    this.id,
    required this.patientId,
    required this.submissionType,
    required this.fearTotal,
    required this.avoidanceTotal,
    required this.totalScore,
    this.createDate,
    this.severityBand = '',
    this.severityLabel = '',
    this.clinicalRoute = '',
    this.summaryMessage = '',
    this.recommendedNextStep = '',
    this.clinicalAttention = false,
    this.redFlagTriggered = false,
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
      severityBand: json['severityBand']?.toString() ?? '',
      severityLabel: json['severityLabel']?.toString() ?? '',
      clinicalRoute: json['clinicalRoute']?.toString() ?? '',
      summaryMessage: json['summaryMessage']?.toString() ?? '',
      recommendedNextStep: json['recommendedNextStep']?.toString() ?? '',
      clinicalAttention: json['clinicalAttention'] == true,
      redFlagTriggered: json['redFlagTriggered'] == true,
    );
  }
}
