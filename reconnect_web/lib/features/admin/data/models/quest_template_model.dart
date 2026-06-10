class QuestTemplateModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final String moduleCode;
  final int? programWeek;
  final String programPhaseCode;
  final String interventionType;
  final bool therapistOnlyAssignable;
  final bool hardLocked;

  QuestTemplateModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.moduleCode,
    required this.programWeek,
    required this.programPhaseCode,
    required this.interventionType,
    required this.therapistOnlyAssignable,
    required this.hardLocked,
  });

  factory QuestTemplateModel.fromJson(Map<String, dynamic> json) {
    return QuestTemplateModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'COGNITIVE',
      difficulty: json['difficulty']?.toString() ?? 'EASY',
      moduleCode: json['moduleCode']?.toString() ?? '',
      programWeek: (json['programWeek'] as num?)?.toInt(),
      programPhaseCode: json['programPhaseCode']?.toString() ?? '',
      interventionType: json['interventionType']?.toString() ?? '',
      therapistOnlyAssignable: json['therapistOnlyAssignable'] == true,
      hardLocked: json['hardLocked'] == true,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'moduleCode': moduleCode,
      'programWeek': programWeek,
      'programPhaseCode': programPhaseCode,
      'interventionType': interventionType,
      'therapistOnlyAssignable': therapistOnlyAssignable,
      'hardLocked': hardLocked,
    };
  }

  QuestTemplateModel copyWith({
    String? title,
    String? description,
    String? category,
    String? difficulty,
    String? moduleCode,
    int? programWeek,
    String? programPhaseCode,
    String? interventionType,
    bool? therapistOnlyAssignable,
    bool? hardLocked,
  }) {
    return QuestTemplateModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      moduleCode: moduleCode ?? this.moduleCode,
      programWeek: programWeek ?? this.programWeek,
      programPhaseCode: programPhaseCode ?? this.programPhaseCode,
      interventionType: interventionType ?? this.interventionType,
      therapistOnlyAssignable: therapistOnlyAssignable ?? this.therapistOnlyAssignable,
      hardLocked: hardLocked ?? this.hardLocked,
    );
  }
}
