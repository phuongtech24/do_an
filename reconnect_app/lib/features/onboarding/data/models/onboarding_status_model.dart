class OnboardingStatusModel {
  final String patientId;
  final bool hasBaselinePhq9;
  final bool hasGoals;
  final bool hasCompletedPsychoeducation;

  OnboardingStatusModel({
    required this.patientId,
    required this.hasBaselinePhq9,
    required this.hasGoals,
    required this.hasCompletedPsychoeducation,
  });

  factory OnboardingStatusModel.fromJson(Map<String, dynamic> json) {
    return OnboardingStatusModel(
      patientId: json['patientId']?.toString() ?? '',
      hasBaselinePhq9: json['hasBaselinePhq9'] == true,
      hasGoals: json['hasGoals'] == true,
      hasCompletedPsychoeducation: json['hasCompletedPsychoeducation'] == true,
    );
  }

  bool get isComplete => hasBaselinePhq9 && hasGoals && hasCompletedPsychoeducation;

  String get nextRoute {
    if (!hasBaselinePhq9) return '/phq9';
    if (!hasGoals) return '/goal-setting';
    if (!hasCompletedPsychoeducation) return '/psycho-education';
    return '/home';
  }
}

