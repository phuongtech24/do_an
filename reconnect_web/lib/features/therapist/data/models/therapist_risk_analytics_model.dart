class TherapistRiskAnalyticsModel {
  final String patientId;
  final int days;
  final int? latestRiskScore;
  final double? averageRiskScore;
  final int? maxRiskScore;
  final int redFlagDays;
  final bool latestRedFlagActive;
  final String trend;
  final List<TherapistRiskPointModel> points;

  TherapistRiskAnalyticsModel({
    required this.patientId,
    required this.days,
    required this.latestRiskScore,
    required this.averageRiskScore,
    required this.maxRiskScore,
    required this.redFlagDays,
    required this.latestRedFlagActive,
    required this.trend,
    required this.points,
  });

  factory TherapistRiskAnalyticsModel.fromJson(Map<String, dynamic> json) {
    final rawPoints = json['points'] as List<dynamic>? ?? [];
    return TherapistRiskAnalyticsModel(
      patientId: json['patientId']?.toString() ?? '',
      days: (json['days'] as num?)?.toInt() ?? 14,
      latestRiskScore: (json['latestRiskScore'] as num?)?.toInt(),
      averageRiskScore: (json['averageRiskScore'] as num?)?.toDouble(),
      maxRiskScore: (json['maxRiskScore'] as num?)?.toInt(),
      redFlagDays: (json['redFlagDays'] as num?)?.toInt() ?? 0,
      latestRedFlagActive: json['latestRedFlagActive'] == true,
      trend: json['trend']?.toString() ?? 'NO_DATA',
      points: rawPoints.map((item) => TherapistRiskPointModel.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }
}

class TherapistRiskPointModel {
  final DateTime? riskDate;
  final int riskScore;
  final int scorePhq9;
  final int scoreAi;
  final int scoreMood;
  final bool overrideTriggered;
  final bool redFlagActive;

  TherapistRiskPointModel({
    required this.riskDate,
    required this.riskScore,
    required this.scorePhq9,
    required this.scoreAi,
    required this.scoreMood,
    required this.overrideTriggered,
    required this.redFlagActive,
  });

  factory TherapistRiskPointModel.fromJson(Map<String, dynamic> json) {
    return TherapistRiskPointModel(
      riskDate: _parseDate(json['riskDate']),
      riskScore: (json['riskScore'] as num?)?.toInt() ?? 0,
      scorePhq9: (json['scorePhq9'] as num?)?.toInt() ?? 0,
      scoreAi: (json['scoreAi'] as num?)?.toInt() ?? 0,
      scoreMood: (json['scoreMood'] as num?)?.toInt() ?? 0,
      overrideTriggered: json['overrideTriggered'] == true,
      redFlagActive: json['redFlagActive'] == true,
    );
  }

  static DateTime? _parseDate(Object? raw) {
    final value = raw?.toString();
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
