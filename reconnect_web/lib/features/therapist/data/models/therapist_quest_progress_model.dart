class TherapistQuestProgressModel {
  final String patientId;
  final int totalAssigned;
  final int completed;
  final double completionRate;
  final int systemAssigned;
  final int therapistAssigned;
  final double? averageMastery;
  final double? averagePleasure;
  final List<TherapistQuestProgressItemModel> recentQuests;

  TherapistQuestProgressModel({
    required this.patientId,
    required this.totalAssigned,
    required this.completed,
    required this.completionRate,
    required this.systemAssigned,
    required this.therapistAssigned,
    required this.averageMastery,
    required this.averagePleasure,
    required this.recentQuests,
  });

  factory TherapistQuestProgressModel.fromJson(Map<String, dynamic> json) {
    final rawRecent = json['recentQuests'] as List<dynamic>? ?? [];
    return TherapistQuestProgressModel(
      patientId: json['patientId']?.toString() ?? '',
      totalAssigned: (json['totalAssigned'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0,
      systemAssigned: (json['systemAssigned'] as num?)?.toInt() ?? 0,
      therapistAssigned: (json['therapistAssigned'] as num?)?.toInt() ?? 0,
      averageMastery: (json['averageMastery'] as num?)?.toDouble(),
      averagePleasure: (json['averagePleasure'] as num?)?.toDouble(),
      recentQuests: rawRecent
          .map((item) => TherapistQuestProgressItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TherapistQuestProgressItemModel {
  final String questId;
  final String title;
  final String category;
  final String sourceType;
  final String status;
  final int? masteryScore;
  final int? pleasureScore;
  final DateTime? assignedAt;
  final DateTime? dueDate;
  final DateTime? completedAt;

  TherapistQuestProgressItemModel({
    required this.questId,
    required this.title,
    required this.category,
    required this.sourceType,
    required this.status,
    required this.masteryScore,
    required this.pleasureScore,
    required this.assignedAt,
    required this.dueDate,
    required this.completedAt,
  });

  factory TherapistQuestProgressItemModel.fromJson(Map<String, dynamic> json) {
    return TherapistQuestProgressItemModel(
      questId: json['questId']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Bài tập CBT',
      category: json['category']?.toString() ?? '',
      sourceType: json['sourceType']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      masteryScore: (json['masteryScore'] as num?)?.toInt(),
      pleasureScore: (json['pleasureScore'] as num?)?.toInt(),
      assignedAt: _parseDate(json['assignedAt']),
      dueDate: _parseDate(json['dueDate']),
      completedAt: _parseDate(json['completedAt']),
    );
  }

  static DateTime? _parseDate(Object? raw) {
    final value = raw?.toString();
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
