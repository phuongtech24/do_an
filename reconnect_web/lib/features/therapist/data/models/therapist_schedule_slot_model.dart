class TherapistScheduleSlotModel {
  final String slotDate; // YYYY-MM-DD
  final String startTime; // HH:mm:ss
  final String startAt; // ISO datetime
  final String status; // OPEN/CLOSED/BOOKED
  final String? patientNickname;
  final String? appointmentId;

  TherapistScheduleSlotModel({
    required this.slotDate,
    required this.startTime,
    required this.startAt,
    required this.status,
    this.patientNickname,
    this.appointmentId,
  });

  bool get isBooked => status == 'BOOKED';
  bool get isOpen => status == 'OPEN';

  factory TherapistScheduleSlotModel.fromJson(Map<String, dynamic> json) {
    return TherapistScheduleSlotModel(
      slotDate: (json['slotDate'] ?? '').toString(),
      startTime: (json['startTime'] ?? '').toString(),
      startAt: (json['startAt'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      patientNickname: (json['patientNickname'] ?? '').toString().isEmpty ? null : (json['patientNickname'] ?? '').toString(),
      appointmentId: (json['appointmentId'] ?? '').toString().isEmpty ? null : (json['appointmentId'] ?? '').toString(),
    );
  }
}

