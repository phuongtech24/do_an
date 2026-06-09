class LsasSituationModel {
  final String id;
  final int situationNumber;
  final String group;
  final String title;
  final String description;

  const LsasSituationModel({
    required this.id,
    required this.situationNumber,
    required this.group,
    required this.title,
    required this.description,
  });

  factory LsasSituationModel.fromJson(Map<String, dynamic> json) {
    final text = json['text']?.toString() ?? '';
    final title = json['title']?.toString() ?? '';
    return LsasSituationModel(
      id: json['id']?.toString() ?? '',
      situationNumber: (json['situationNumber'] as num?)?.toInt() ?? 0,
      group: json['situationGroup']?.toString() ?? json['group']?.toString() ?? 'SOCIAL_INTERACTION',
      title: title.isNotEmpty ? title : text,
      description: json['description']?.toString() ?? '',
    );
  }
}

class LsasAnswerInput {
  final String situationId;
  final int fearScore;
  final int avoidanceScore;

  const LsasAnswerInput({
    required this.situationId,
    required this.fearScore,
    required this.avoidanceScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'situationId': situationId,
      'fearScore': fearScore,
      'avoidanceScore': avoidanceScore,
    };
  }
}
