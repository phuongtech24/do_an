class AppointmentModel {
  final String id;
  final String patientId;
  final String therapistId;
  final DateTime startAt;
  final DateTime endAt;
  final String status;
  final String purpose;
  final bool isAnonymous;
  final String? meetingLink;
  final String? patientDisplayName;
  final String? therapistDisplayName;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.therapistId,
    required this.startAt,
    required this.endAt,
    required this.status,
    required this.purpose,
    required this.isAnonymous,
    required this.meetingLink,
    required this.patientDisplayName,
    required this.therapistDisplayName,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: (json['id'] ?? '').toString(),
      patientId: (json['patientId'] ?? '').toString(),
      therapistId: (json['therapistId'] ?? '').toString(),
      startAt: DateTime.tryParse((json['startAt'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0),
      endAt: DateTime.tryParse((json['endAt'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0),
      status: (json['status'] ?? '').toString(),
      purpose: (json['purpose'] ?? '').toString(),
      isAnonymous: json['isAnonymous'] == true,
      meetingLink: (json['meetingLink'] ?? '').toString().isEmpty ? null : (json['meetingLink'] ?? '').toString(),
      patientDisplayName: (json['patientDisplayName'] ?? '').toString().isEmpty ? null : (json['patientDisplayName'] ?? '').toString(),
      therapistDisplayName: (json['therapistDisplayName'] ?? '').toString().isEmpty ? null : (json['therapistDisplayName'] ?? '').toString(),
    );
  }
}
