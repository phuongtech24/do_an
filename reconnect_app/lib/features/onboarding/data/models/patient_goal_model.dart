class PatientGoalModel {
  final String? id;
  final String patientId;
  final String goalType;
  final String description;
  final String status;

  const PatientGoalModel({
    this.id,
    required this.patientId,
    required this.goalType,
    required this.description,
    required this.status,
  });

  factory PatientGoalModel.fromJson(Map<String, dynamic> json) {
    final rawGoalType = json['goalType']?.toString() ?? 'SOCIAL';
    return PatientGoalModel(
      id: json['id']?.toString(),
      patientId: json['patientId']?.toString() ?? '',
      goalType: _normalizeGoalType(rawGoalType),
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'ACTIVE',
    );
  }

  static String _normalizeGoalType(String raw) {
    switch (raw.toUpperCase()) {
      case 'SOCIAL_INTERACTION':
      case 'GENERAL':
        return 'SOCIAL';
      case 'PERFORMANCE':
        return 'BEHAVIORAL';
      case 'COGNITIVE':
      case 'EMOTIONAL':
      case 'BEHAVIORAL':
      case 'SOCIAL':
        return raw.toUpperCase();
      default:
        return 'SOCIAL';
    }
  }
}
