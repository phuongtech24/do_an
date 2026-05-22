class Phq9QuestionModel {
  final String id;
  final int questionNumber;
  final String text;

  Phq9QuestionModel({
    required this.id,
    required this.questionNumber,
    required this.text,
  });

  factory Phq9QuestionModel.fromJson(Map<String, dynamic> json) {
    return Phq9QuestionModel(
      id: json['id'] ?? '',
      questionNumber: json['questionNumber'] ?? 0,
      text: json['text'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionNumber': questionNumber,
      'text': text,
    };
  }
}

class Phq9OptionModel {
  final int score;
  final String text;

  Phq9OptionModel({
    required this.score,
    required this.text,
  });

  factory Phq9OptionModel.fromJson(Map<String, dynamic> json) {
    return Phq9OptionModel(
      score: json['score'] ?? 0,
      text: json['text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'text': text,
    };
  }
}

class Phq9QuestionnaireModel {
  final List<Phq9QuestionModel> questions;
  final List<Phq9OptionModel> options;

  Phq9QuestionnaireModel({
    required this.questions,
    required this.options,
  });

  factory Phq9QuestionnaireModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> questionsJson = json['questions'] ?? [];
    final List<dynamic> optionsJson = json['options'] ?? [];

    return Phq9QuestionnaireModel(
      questions: questionsJson.map((q) => Phq9QuestionModel.fromJson(q)).toList(),
      options: optionsJson.map((o) => Phq9OptionModel.fromJson(o)).toList(),
    );
  }
}
