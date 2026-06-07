class TherapistAssignmentStatusModel {
  final String patientId;
  final bool assigned;
  final String? therapistId;
  final String? therapistName;
  final String? message;
  final String? carePhaseCode;
  final String? carePhaseLabel;
  final String? recommendedFrequencyLabel;
  final String? recommendedPlanSummary;
  final String? durationGuidance;
  final String? recommendedPurposeCode;
  final bool allowOverride;

  TherapistAssignmentStatusModel({
    required this.patientId,
    required this.assigned,
    required this.therapistId,
    required this.therapistName,
    required this.message,
    required this.carePhaseCode,
    required this.carePhaseLabel,
    required this.recommendedFrequencyLabel,
    required this.recommendedPlanSummary,
    required this.durationGuidance,
    required this.recommendedPurposeCode,
    required this.allowOverride,
  });

  factory TherapistAssignmentStatusModel.fromJson(Map<String, dynamic> json) {
    return TherapistAssignmentStatusModel(
      patientId: (json['patientId'] ?? '').toString(),
      assigned: json['assigned'] == true,
      therapistId: (json['therapistId'] ?? '').toString().isEmpty ? null : (json['therapistId'] ?? '').toString(),
      therapistName: (json['therapistName'] ?? '').toString().isEmpty ? null : (json['therapistName'] ?? '').toString(),
      message: (json['message'] ?? '').toString().isEmpty ? null : (json['message'] ?? '').toString(),
      carePhaseCode: (json['carePhaseCode'] ?? '').toString().isEmpty ? null : (json['carePhaseCode'] ?? '').toString(),
      carePhaseLabel: (json['carePhaseLabel'] ?? '').toString().isEmpty ? null : (json['carePhaseLabel'] ?? '').toString(),
      recommendedFrequencyLabel: (json['recommendedFrequencyLabel'] ?? '').toString().isEmpty
          ? null
          : (json['recommendedFrequencyLabel'] ?? '').toString(),
      recommendedPlanSummary: (json['recommendedPlanSummary'] ?? '').toString().isEmpty
          ? null
          : (json['recommendedPlanSummary'] ?? '').toString(),
      durationGuidance: (json['durationGuidance'] ?? '').toString().isEmpty ? null : (json['durationGuidance'] ?? '').toString(),
      recommendedPurposeCode: (json['recommendedPurposeCode'] ?? '').toString().isEmpty
          ? null
          : (json['recommendedPurposeCode'] ?? '').toString(),
      allowOverride: json['allowOverride'] == true,
    );
  }
}
