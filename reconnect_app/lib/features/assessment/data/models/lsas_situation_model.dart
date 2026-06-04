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
    return LsasSituationModel(
      id: json['id']?.toString() ?? '',
      situationNumber: (json['situationNumber'] as num?)?.toInt() ?? 0,
      group: json['group']?.toString() ?? 'SOCIAL_INTERACTION',
      title: json['title']?.toString() ?? '',
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
