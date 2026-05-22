class Phq9SubmissionModel {
  final String? id;
  final String patientId;
  final List<int> answers;
  final String submissionType; // BASELINE, PERIODIC, TRIGGERED
  final int? totalScore;
  final String? severityLevel;
  final bool? graduatedNow;
  final String? taperingStage; // NONE/WEEKLY/MONTHLY/QUARTERLY

  Phq9SubmissionModel({
    this.id,
    required this.patientId,
    required this.answers,
    this.submissionType = 'PERIODIC',
    this.totalScore,
    this.severityLevel,
    this.graduatedNow,
    this.taperingStage,
  });

  factory Phq9SubmissionModel.fromJson(Map<String, dynamic> json) {
    return Phq9SubmissionModel(
      id: json['id'],
      patientId: json['patientId'] ?? '',
      answers: List<int>.from(json['answers'] ?? []),
      submissionType: json['submissionType'] ?? 'PERIODIC',
      totalScore: json['totalScore'],
      severityLevel: json['severityLevel'],
      graduatedNow: json['graduatedNow'] == true,
      taperingStage: json['taperingStage']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'answers': answers,
      'submissionType': submissionType,
    };
  }
}
