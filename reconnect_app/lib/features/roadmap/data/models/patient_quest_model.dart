class PatientQuestModel {
  final String id;
  final String patientId;
  final String? questTemplateId;
  final String title;
  final String description;
  final String category; // EMOTIONAL/COGNITIVE/BEHAVIORAL/SOCIAL
  final String sourceType; // SYSTEM/THERAPIST
  final String status; // LOCKED/AVAILABLE/DONE
  final int? masteryScore;
  final int? pleasureScore;
  final String? proofImageUrl;
  final String? assignedAt;
  final String? dueDate;
  final String? completedAt;

  PatientQuestModel({
    required this.id,
    required this.patientId,
    required this.questTemplateId,
    required this.title,
    required this.description,
    required this.category,
    required this.sourceType,
    required this.status,
    this.masteryScore,
    this.pleasureScore,
    this.proofImageUrl,
    this.assignedAt,
    this.dueDate,
    this.completedAt,
  });

  factory PatientQuestModel.fromJson(Map<String, dynamic> json) {
    return PatientQuestModel(
      id: json['id']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      questTemplateId: json['questTemplateId']?.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'COGNITIVE',
      sourceType: json['sourceType']?.toString() ?? 'SYSTEM',
      status: json['status']?.toString() ?? 'LOCKED',
      masteryScore: (json['masteryScore'] as num?)?.toInt(),
      pleasureScore: (json['pleasureScore'] as num?)?.toInt(),
      proofImageUrl: json['proofImageUrl']?.toString(),
      assignedAt: json['assignedAt']?.toString(),
      dueDate: json['dueDate']?.toString(),
      completedAt: json['completedAt']?.toString(),
    );
  }
}
