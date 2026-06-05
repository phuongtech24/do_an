class OnboardingStatusModel {
  final String patientId;
  final bool hasBaselineLsas;
  final bool hasGoals;
  final bool hasCompletedPsychoeducation;
  final bool hasSelectedTherapist;

  OnboardingStatusModel({
    required this.patientId,
    required this.hasBaselineLsas,
    required this.hasGoals,
    required this.hasCompletedPsychoeducation,
    required this.hasSelectedTherapist,
  });

  factory OnboardingStatusModel.fromJson(Map<String, dynamic> json) {
    return OnboardingStatusModel(
      patientId: json['patientId']?.toString() ?? '',
      hasBaselineLsas: json['hasBaselineLsas'] == true,
      hasGoals: json['hasGoals'] == true,
      hasCompletedPsychoeducation: json['hasCompletedPsychoeducation'] == true,
      hasSelectedTherapist: json['hasSelectedTherapist'] == true,
    );
  }

  bool get isComplete =>
      hasBaselineLsas && hasGoals && hasCompletedPsychoeducation && hasSelectedTherapist;

  String get nextRoute {
    if (!hasBaselineLsas) return '/lsas';
    if (!hasGoals) return '/goal-setting';
    if (!hasCompletedPsychoeducation) return '/psycho-education';
    if (!hasSelectedTherapist) return '/therapist-matching';
    return '/home';
  }
}
