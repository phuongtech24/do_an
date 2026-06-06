class UserMoodModel {
  final String? id;
  final String patientId;
  final int? moodScore;
  final int anxietyScore;
  final int avoidanceUrgeScore;
  final int anticipatoryAnxietyScore;
  final int postEventRuminationScore;
  final String dailyAgenda;

  UserMoodModel({
    this.id,
    required this.patientId,
    this.moodScore,
    required this.anxietyScore,
    required this.avoidanceUrgeScore,
    required this.anticipatoryAnxietyScore,
    required this.postEventRuminationScore,
    required this.dailyAgenda,
  });

  factory UserMoodModel.fromJson(Map<String, dynamic> json) {
    return UserMoodModel(
      id: json['id']?.toString(),
      patientId: json['patientId']?.toString() ?? '',
      moodScore: (json['moodScore'] as num?)?.toInt(),
      anxietyScore: (json['anxietyScore'] as num?)?.toInt() ?? 0,
      avoidanceUrgeScore: (json['avoidanceUrgeScore'] as num?)?.toInt() ?? 0,
      anticipatoryAnxietyScore: (json['anticipatoryAnxietyScore'] as num?)?.toInt() ?? 0,
      postEventRuminationScore: (json['postEventRuminationScore'] as num?)?.toInt() ?? 0,
      dailyAgenda: json['dailyAgenda']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'moodScore': moodScore ?? (100 - anxietyScore).clamp(0, 100),
      'anxietyScore': anxietyScore,
      'avoidanceUrgeScore': avoidanceUrgeScore,
      'anticipatoryAnxietyScore': anticipatoryAnxietyScore,
      'postEventRuminationScore': postEventRuminationScore,
      'dailyAgenda': dailyAgenda,
    };
  }
}
