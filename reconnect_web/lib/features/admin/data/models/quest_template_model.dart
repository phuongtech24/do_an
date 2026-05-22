class QuestTemplateModel {
  final String id;
  final String title;
  final String description;
  final String category; // BEHAVIORAL/COGNITIVE/EMOTIONAL/SOCIAL
  final String difficulty; // EASY/MEDIUM/HARD

  QuestTemplateModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
  });

  factory QuestTemplateModel.fromJson(Map<String, dynamic> json) {
    return QuestTemplateModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'COGNITIVE',
      difficulty: json['difficulty']?.toString() ?? 'EASY',
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'difficulty': difficulty,
    };
  }

  QuestTemplateModel copyWith({
    String? title,
    String? description,
    String? category,
    String? difficulty,
  }) {
    return QuestTemplateModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}

