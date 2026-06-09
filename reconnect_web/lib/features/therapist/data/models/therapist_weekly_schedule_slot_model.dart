class TherapistWeeklyScheduleSlotModel {
  final String dayOfWeek;
  final String startTime;
  final String status;

  TherapistWeeklyScheduleSlotModel({
    required this.dayOfWeek,
    required this.startTime,
    required this.status,
  });

  bool get isOpen => status == 'OPEN';

  factory TherapistWeeklyScheduleSlotModel.fromJson(Map<String, dynamic> json) {
    return TherapistWeeklyScheduleSlotModel(
      dayOfWeek: (json['dayOfWeek'] ?? '').toString(),
      startTime: (json['startTime'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
    );
  }
}
