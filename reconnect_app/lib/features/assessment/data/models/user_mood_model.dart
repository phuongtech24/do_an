class UserMoodModel {
  final String? id;
  final String patientId;
  final int moodScore; // 0 to 100
  final String dailyAgenda;

  UserMoodModel({
    this.id,
    required this.patientId,
    required this.moodScore,
    required this.dailyAgenda,
  });

  factory UserMoodModel.fromJson(Map<String, dynamic> json) {
    return UserMoodModel(
      id: json['id'],
      patientId: json['patientId'] ?? '',
      moodScore: json['moodScore'] ?? 0,
      dailyAgenda: json['dailyAgenda'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'moodScore': moodScore,
      'dailyAgenda': dailyAgenda,
    };
  }
}
