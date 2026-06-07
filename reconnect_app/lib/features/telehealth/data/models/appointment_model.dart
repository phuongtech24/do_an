class AppointmentModel {
  final String id;
  final String patientId;
  final String therapistId;
  final DateTime startAt;
  final DateTime endAt;
  final String status;
  final String purpose;
  final String? clinicalPurposeCode;
  final String? carePhaseCode;
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
    this.clinicalPurposeCode,
    this.carePhaseCode,
    required this.isAnonymous,
    this.meetingLink,
    this.patientDisplayName,
    this.therapistDisplayName,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      therapistId: json['therapistId']?.toString() ?? '',
      startAt: DateTime.parse(json['startAt']?.toString() ?? DateTime.now().toIso8601String()),
      endAt: DateTime.parse(json['endAt']?.toString() ?? DateTime.now().toIso8601String()),
      status: json['status']?.toString() ?? 'BOOKED',
      purpose: json['purpose']?.toString() ?? 'CBT_SESSION',
      clinicalPurposeCode: (json['clinicalPurposeCode'] ?? '').toString().isEmpty ? null : json['clinicalPurposeCode']?.toString(),
      carePhaseCode: (json['carePhaseCode'] ?? '').toString().isEmpty ? null : json['carePhaseCode']?.toString(),
      isAnonymous: json['isAnonymous'] == true,
      meetingLink: (json['meetingLink'] ?? '').toString().isEmpty ? null : json['meetingLink']?.toString(),
      patientDisplayName: (json['patientDisplayName'] ?? '').toString().isEmpty ? null : json['patientDisplayName']?.toString(),
      therapistDisplayName: (json['therapistDisplayName'] ?? '').toString().isEmpty ? null : json['therapistDisplayName']?.toString(),
    );
  }
}
