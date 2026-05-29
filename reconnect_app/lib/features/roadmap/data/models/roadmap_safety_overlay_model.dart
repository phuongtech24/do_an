class RoadmapSafetyOverlayModel {
  const RoadmapSafetyOverlayModel({
    required this.active,
    required this.riskScore,
    required this.redFlagActive,
    required this.message,
    required this.recommendedAction,
  });

  final bool active;
  final int riskScore;
  final bool redFlagActive;
  final String message;
  final String recommendedAction;

  factory RoadmapSafetyOverlayModel.fromJson(Map<String, dynamic> json) {
    return RoadmapSafetyOverlayModel(
      active: json['active'] == true,
      riskScore: (json['riskScore'] as num?)?.toInt() ?? 0,
      redFlagActive: json['redFlagActive'] == true,
      message: json['message']?.toString() ?? '',
      recommendedAction: json['recommendedAction']?.toString() ?? 'NONE',
    );
  }

  static const inactive = RoadmapSafetyOverlayModel(
    active: false,
    riskScore: 0,
    redFlagActive: false,
    message: '',
    recommendedAction: 'NONE',
  );
}
