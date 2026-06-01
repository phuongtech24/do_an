class Phq9SubmissionModel {
  final String? id;
  final String patientId;
  final List<int> answers;
  final String submissionType; // BASELINE, PERIODIC, TRIGGERED
  final int? functionalDifficultyScore;
  final int? totalScore;
  final int? q2Score;
  final int? q9Score;
  final String? severityLevel;
  final String? createDate;
  final String? unlockedAt;
  final bool? graduatedNow;
  final String? taperingStage; // NONE/WEEKLY/MONTHLY/QUARTERLY

  Phq9SubmissionModel({
    this.id,
    required this.patientId,
    required this.answers,
    this.submissionType = 'PERIODIC',
    this.functionalDifficultyScore,
    this.totalScore,
    this.q2Score,
    this.q9Score,
    this.severityLevel,
    this.createDate,
    this.unlockedAt,
    this.graduatedNow,
    this.taperingStage,
  });

  factory Phq9SubmissionModel.fromJson(Map<String, dynamic> json) {
    return Phq9SubmissionModel(
      id: json['id'],
      patientId: json['patientId'] ?? '',
      answers: List<int>.from(json['answers'] ?? []),
      submissionType: json['submissionType'] ?? 'PERIODIC',
      functionalDifficultyScore: json['functionalDifficultyScore'],
      totalScore: json['totalScore'],
      q2Score: json['q2Score'],
      q9Score: json['q9Score'],
      severityLevel: json['severityLevel'],
      createDate: json['createDate']?.toString(),
      unlockedAt: json['unlockedAt']?.toString(),
      graduatedNow: json['graduatedNow'] == true,
      taperingStage: json['taperingStage']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'answers': answers,
      'submissionType': submissionType,
      if (functionalDifficultyScore != null) 'functionalDifficultyScore': functionalDifficultyScore,
    };
  }
}
