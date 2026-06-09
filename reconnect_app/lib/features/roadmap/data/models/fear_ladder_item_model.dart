class FearLadderItemModel {
  final String id;
  final String situationId;
  final int situationNumber;
  final String situationText;
  final String situationGroup;
  final int baselineTotalScore;
  final int currentFearScore;
  final int currentAvoidanceScore;
  final int currentTotalScore;
  final String bucket;
  final int ladderOrder;
  final String status;
  final bool goalMatch;
  final bool unlocked;

  const FearLadderItemModel({
    required this.id,
    required this.situationId,
    required this.situationNumber,
    required this.situationText,
    required this.situationGroup,
    required this.baselineTotalScore,
    required this.currentFearScore,
    required this.currentAvoidanceScore,
    required this.currentTotalScore,
    required this.bucket,
    required this.ladderOrder,
    required this.status,
    required this.goalMatch,
    required this.unlocked,
  });

  factory FearLadderItemModel.fromJson(Map<String, dynamic> json) {
    return FearLadderItemModel(
      id: json['id']?.toString() ?? '',
      situationId: json['situationId']?.toString() ?? '',
      situationNumber: (json['situationNumber'] as num?)?.toInt() ?? 0,
      situationText: json['situationText']?.toString() ?? '',
      situationGroup: json['situationGroup']?.toString() ?? '',
      baselineTotalScore: (json['baselineTotalScore'] as num?)?.toInt() ?? 0,
      currentFearScore: (json['currentFearScore'] as num?)?.toInt() ?? 0,
      currentAvoidanceScore: (json['currentAvoidanceScore'] as num?)?.toInt() ?? 0,
      currentTotalScore: (json['currentTotalScore'] as num?)?.toInt() ?? 0,
      bucket: json['bucket']?.toString() ?? 'EASY',
      ladderOrder: (json['ladderOrder'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'ACTIVE',
      goalMatch: json['goalMatch'] == true,
      unlocked: json['unlocked'] != false,
    );
  }
}
