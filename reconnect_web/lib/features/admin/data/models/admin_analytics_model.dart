class AdminAnalyticsModel {
  final int totalPatients;
  final int activePatients;
  final int redFlagPatients;
  final int graduatedPatients;
  final double graduationRate;
  final int totalTherapists;
  final int pendingTherapists;
  final int totalAppointments;

  AdminAnalyticsModel({
    required this.totalPatients,
    required this.activePatients,
    required this.redFlagPatients,
    required this.graduatedPatients,
    required this.graduationRate,
    required this.totalTherapists,
    required this.pendingTherapists,
    required this.totalAppointments,
  });

  factory AdminAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AdminAnalyticsModel(
      totalPatients: (json['totalPatients'] as num?)?.toInt() ?? 0,
      activePatients: (json['activePatients'] as num?)?.toInt() ?? 0,
      redFlagPatients: (json['redFlagPatients'] as num?)?.toInt() ?? 0,
      graduatedPatients: (json['graduatedPatients'] as num?)?.toInt() ?? 0,
      graduationRate: (json['graduationRate'] as num?)?.toDouble() ?? 0.0,
      totalTherapists: (json['totalTherapists'] as num?)?.toInt() ?? 0,
      pendingTherapists: (json['pendingTherapists'] as num?)?.toInt() ?? 0,
      totalAppointments: (json['totalAppointments'] as num?)?.toInt() ?? 0,
    );
  }
}

