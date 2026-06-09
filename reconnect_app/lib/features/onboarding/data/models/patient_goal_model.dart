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
    return PatientGoalModel(
      id: json['id']?.toString(),
      patientId: json['patientId']?.toString() ?? '',
      goalType: json['goalType']?.toString() ?? 'GENERAL',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'ACTIVE',
    );
  }
}
