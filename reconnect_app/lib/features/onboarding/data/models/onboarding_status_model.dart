class OnboardingStatusModel {
  final String patientId;
  final bool hasBaselineLsas;
  final bool hasGoals;
  final bool hasCompletedPsychoeducation;

  OnboardingStatusModel({
    required this.patientId,
    required this.hasBaselineLsas,
    required this.hasGoals,
    required this.hasCompletedPsychoeducation,
  });

  factory OnboardingStatusModel.fromJson(Map<String, dynamic> json) {
    return OnboardingStatusModel(
      patientId: json['patientId']?.toString() ?? '',
      hasBaselineLsas: json['hasBaselineLsas'] == true,
      hasGoals: json['hasGoals'] == true,
      hasCompletedPsychoeducation: json['hasCompletedPsychoeducation'] == true,
    );
  }

  bool get isComplete => hasBaselineLsas && hasGoals && hasCompletedPsychoeducation;

  String get nextRoute {
    if (!hasBaselineLsas) return '/lsas';
    if (!hasGoals) return '/goal-setting';
    if (!hasCompletedPsychoeducation) return '/psycho-education';
    return '/home';
  }
}
