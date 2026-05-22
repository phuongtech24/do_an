class AvailableSlotModel {
  final DateTime startAt;
  final bool available;

  AvailableSlotModel({
    required this.startAt,
    required this.available,
  });

  factory AvailableSlotModel.fromJson(Map<String, dynamic> json) {
    return AvailableSlotModel(
      startAt: DateTime.parse(json['startAt']?.toString() ?? DateTime.now().toIso8601String()),
      available: json['available'] == true,
    );
  }
}

