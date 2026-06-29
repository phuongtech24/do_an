class LsasProgressPointModel {
  final String weekLabel;
  final int totalScore;

  const LsasProgressPointModel({
    required this.weekLabel,
    required this.totalScore,
  });

  factory LsasProgressPointModel.fromJson(Map<String, dynamic> json) {
    return LsasProgressPointModel(
      weekLabel: json['weekLabel']?.toString() ?? '',
      totalScore: (json['totalScore'] as num?)?.toInt() ?? 0,
    );
  }
}

class LsasProgressResponseModel {
  final List<LsasProgressPointModel> chartData;
  final int startScore;
  final int currentScore;
  final String insightMessage;

  const LsasProgressResponseModel({
    required this.chartData,
    required this.startScore,
    required this.currentScore,
    required this.insightMessage,
  });

  factory LsasProgressResponseModel.fromJson(Map<String, dynamic> json) {
    final rawChartData = json['chartData'] as List<dynamic>? ?? const [];
    return LsasProgressResponseModel(
      chartData: rawChartData
          .map((item) => LsasProgressPointModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      startScore: (json['startScore'] as num?)?.toInt() ?? 0,
      currentScore: (json['currentScore'] as num?)?.toInt() ?? 0,
      insightMessage: json['insightMessage']?.toString() ?? '',
    );
  }
}
