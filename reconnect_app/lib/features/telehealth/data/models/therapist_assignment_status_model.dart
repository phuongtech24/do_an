class TherapistAssignmentStatusModel {
  final String patientId;
  final bool assigned;
  final String? therapistId;
  final String? therapistName;
  final String? message;

  TherapistAssignmentStatusModel({
    required this.patientId,
    required this.assigned,
    required this.therapistId,
    required this.therapistName,
    required this.message,
  });

  factory TherapistAssignmentStatusModel.fromJson(Map<String, dynamic> json) {
    return TherapistAssignmentStatusModel(
      patientId: (json['patientId'] ?? '').toString(),
      assigned: json['assigned'] == true,
      therapistId: (json['therapistId'] ?? '').toString().isEmpty ? null : (json['therapistId'] ?? '').toString(),
      therapistName: (json['therapistName'] ?? '').toString().isEmpty ? null : (json['therapistName'] ?? '').toString(),
      message: (json['message'] ?? '').toString().isEmpty ? null : (json['message'] ?? '').toString(),
    );
  }
}

