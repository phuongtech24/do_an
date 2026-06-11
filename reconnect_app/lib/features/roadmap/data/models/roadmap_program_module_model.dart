class RoadmapProgramModuleModel {
  final String moduleCode;
  final String title;
  final String programPhaseCode;
  final String programPhaseLabel;
  final int? weekFrom;
  final int? weekTo;
  final String interventionType;
  final String prerequisiteCodesJson;
  final bool hardLocked;
  final bool unlocked;
  final String unlockType;
  final String lockReason;
  final bool therapistOnlyAssignable;
  final String? expectedUnlockAt;

  const RoadmapProgramModuleModel({
    required this.moduleCode,
    required this.title,
    required this.programPhaseCode,
    required this.programPhaseLabel,
    required this.weekFrom,
    required this.weekTo,
    required this.interventionType,
    required this.prerequisiteCodesJson,
    required this.hardLocked,
    required this.unlocked,
    required this.unlockType,
    required this.lockReason,
    required this.therapistOnlyAssignable,
    required this.expectedUnlockAt,
  });

  factory RoadmapProgramModuleModel.fromJson(Map<String, dynamic> json) {
    return RoadmapProgramModuleModel(
      moduleCode: json['moduleCode']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      programPhaseCode: json['programPhaseCode']?.toString() ?? '',
      programPhaseLabel: json['programPhaseLabel']?.toString() ?? '',
      weekFrom: (json['weekFrom'] as num?)?.toInt(),
      weekTo: (json['weekTo'] as num?)?.toInt(),
      interventionType: json['interventionType']?.toString() ?? '',
      prerequisiteCodesJson: json['prerequisiteCodesJson']?.toString() ?? '[]',
      hardLocked: json['hardLocked'] == true,
      unlocked: json['unlocked'] == true,
      unlockType: json['unlockType']?.toString() ?? '',
      lockReason: json['lockReason']?.toString() ?? '',
      therapistOnlyAssignable: json['therapistOnlyAssignable'] == true,
      expectedUnlockAt: json['expectedUnlockAt']?.toString(),
    );
  }
}
