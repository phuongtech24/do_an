class UserMoodModel {
  final String? id;
  final String patientId;
  final int? moodScore;
  final int anxietyScore;
  final int avoidanceUrgeScore;
  final int sadnessScore;
  final int anticipatoryAnxietyScore;
  final int postEventRuminationScore;
  final String dailyAgenda;
  final bool safetyCheckRequired;
  final String? safetyResponse;
  final String? safetyRespondedAt;

  UserMoodModel({
    this.id,
    required this.patientId,
    this.moodScore,
    required this.anxietyScore,
    required this.avoidanceUrgeScore,
    required this.sadnessScore,
    required this.anticipatoryAnxietyScore,
    required this.postEventRuminationScore,
    required this.dailyAgenda,
    this.safetyCheckRequired = false,
    this.safetyResponse,
    this.safetyRespondedAt,
  });

  factory UserMoodModel.fromJson(Map<String, dynamic> json) {
    return UserMoodModel(
      id: json['id']?.toString(),
      patientId: json['patientId']?.toString() ?? '',
      moodScore: (json['moodScore'] as num?)?.toInt(),
      anxietyScore: (json['anxietyScore'] as num?)?.toInt() ?? 0,
      avoidanceUrgeScore: (json['avoidanceUrgeScore'] as num?)?.toInt() ?? 0,
      sadnessScore: (json['sadnessScore'] as num?)?.toInt() ?? 0,
      anticipatoryAnxietyScore: (json['anticipatoryAnxietyScore'] as num?)?.toInt() ?? 0,
      postEventRuminationScore: (json['postEventRuminationScore'] as num?)?.toInt() ?? 0,
      dailyAgenda: json['dailyAgenda']?.toString() ?? '',
      safetyCheckRequired: json['safetyCheckRequired'] == true,
      safetyResponse: json['safetyResponse']?.toString(),
      safetyRespondedAt: json['safetyRespondedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'moodScore': moodScore ?? (100 - anxietyScore).clamp(0, 100),
      'anxietyScore': anxietyScore,
      'avoidanceUrgeScore': avoidanceUrgeScore,
      'sadnessScore': sadnessScore,
      'anticipatoryAnxietyScore': anticipatoryAnxietyScore,
      'postEventRuminationScore': postEventRuminationScore,
      'dailyAgenda': dailyAgenda,
      'safetyCheckRequired': safetyCheckRequired,
      if (safetyResponse != null) 'safetyResponse': safetyResponse,
      if (safetyRespondedAt != null) 'safetyRespondedAt': safetyRespondedAt,
    };
  }
}
