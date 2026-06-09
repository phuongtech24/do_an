class OnboardingStatusModel {
  final String patientId;
  final bool hasBaselineLsas;
  final bool hasGoals;
  final bool hasCompletedPsychoeducation;
  final bool hasSelectedTherapist;
  final bool requiresTherapistSelection;
  final String lsasClinicalRoute;

  OnboardingStatusModel({
    required this.patientId,
    required this.hasBaselineLsas,
    required this.hasGoals,
    required this.hasCompletedPsychoeducation,
    required this.hasSelectedTherapist,
    required this.requiresTherapistSelection,
    required this.lsasClinicalRoute,
  });

  factory OnboardingStatusModel.fromJson(Map<String, dynamic> json) {
    return OnboardingStatusModel(
      patientId: json['patientId']?.toString() ?? '',
      hasBaselineLsas: json['hasBaselineLsas'] == true,
      hasGoals: json['hasGoals'] == true,
      hasCompletedPsychoeducation: json['hasCompletedPsychoeducation'] == true,
      hasSelectedTherapist: json['hasSelectedTherapist'] == true,
      requiresTherapistSelection: json['requiresTherapistSelection'] == true,
      lsasClinicalRoute: json['lsasClinicalRoute']?.toString() ?? 'REASSURANCE',
    );
  }

  bool get isComplete =>
      hasBaselineLsas &&
      hasGoals &&
      (!requiresTherapistSelection || hasSelectedTherapist) &&
      hasCompletedPsychoeducation;

  String get nextRoute {
    if (!hasBaselineLsas) return '/lsas';
    if (!hasGoals) return '/goal-setting';
    if (requiresTherapistSelection && !hasSelectedTherapist) return '/therapist-matching';
    if (!hasCompletedPsychoeducation) return '/psycho-education';
    return '/home';
  }
}
