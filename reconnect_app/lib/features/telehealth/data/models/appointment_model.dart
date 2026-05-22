class AppointmentModel {
  final String id;
  final String patientId;
  final String therapistId;
  final DateTime startAt;
  final DateTime endAt;
  final String status;
  final bool isAnonymous;
  final String? meetingLink;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.therapistId,
    required this.startAt,
    required this.endAt,
    required this.status,
    required this.isAnonymous,
    this.meetingLink,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      therapistId: json['therapistId']?.toString() ?? '',
      startAt: DateTime.parse(json['startAt']?.toString() ?? DateTime.now().toIso8601String()),
      endAt: DateTime.parse(json['endAt']?.toString() ?? DateTime.now().toIso8601String()),
      status: json['status']?.toString() ?? 'BOOKED',
      isAnonymous: json['isAnonymous'] == true,
      meetingLink: json['meetingLink']?.toString(),
    );
  }
}

