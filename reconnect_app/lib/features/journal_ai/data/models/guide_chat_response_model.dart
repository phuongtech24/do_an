class GuideChatSuggestedActionModel {
  final String label;
  final String route;

  const GuideChatSuggestedActionModel({
    required this.label,
    required this.route,
  });

  factory GuideChatSuggestedActionModel.fromJson(Map<String, dynamic> json) {
    return GuideChatSuggestedActionModel(
      label: json['label']?.toString() ?? '',
      route: json['route']?.toString() ?? '',
    );
  }
}

class GuideChatResponseModel {
  final String answer;
  final List<GuideChatSuggestedActionModel> suggestedActions;
  final String relatedTopicCode;
  final bool usedFallback;
  final bool safetyEscalation;
  final bool handoffRecommended;

  const GuideChatResponseModel({
    required this.answer,
    required this.suggestedActions,
    required this.relatedTopicCode,
    required this.usedFallback,
    required this.safetyEscalation,
    required this.handoffRecommended,
  });

  factory GuideChatResponseModel.fromJson(Map<String, dynamic> json) {
    final actions = (json['suggestedActions'] as List<dynamic>? ?? [])
        .map((item) => GuideChatSuggestedActionModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return GuideChatResponseModel(
      answer: json['answer']?.toString() ?? '',
      suggestedActions: actions,
      relatedTopicCode: json['relatedTopicCode']?.toString() ?? '',
      usedFallback: json['usedFallback'] == true,
      safetyEscalation: json['safetyEscalation'] == true,
      handoffRecommended: json['handoffRecommended'] == true,
    );
  }
}
