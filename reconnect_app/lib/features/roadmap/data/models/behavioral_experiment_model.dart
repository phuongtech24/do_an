import 'fear_ladder_item_model.dart';

class BehavioralExperimentModel {
  final String id;
  final String patientId;
  final FearLadderItemModel ladderItem;
  final String sourceType;
  final String status;
  final String? prediction;
  final int? predictionBelief;
  final int? predictionBeliefBefore;
  final int? predictionBeliefAfter;
  final String? safetyBehaviorsJson;
  final String? outcome;
  final String? learning;
  final String? executionNotes;
  final String? proofImageUrl;
  final String? debrief;
  final int? postFearScore;
  final int? postAvoidanceScore;
  final String? assignedAt;
  final String? dueDate;
  final String? setupCompletedAt;
  final String? startedAt;
  final bool focusReminderShown;
  final String? completedAt;

  const BehavioralExperimentModel({
    required this.id,
    required this.patientId,
    required this.ladderItem,
    required this.sourceType,
    required this.status,
    this.prediction,
    this.predictionBelief,
    this.predictionBeliefBefore,
    this.predictionBeliefAfter,
    this.safetyBehaviorsJson,
    this.outcome,
    this.learning,
    this.executionNotes,
    this.proofImageUrl,
    this.debrief,
    this.postFearScore,
    this.postAvoidanceScore,
    this.assignedAt,
    this.dueDate,
    this.setupCompletedAt,
    this.startedAt,
    this.focusReminderShown = false,
    this.completedAt,
  });

  factory BehavioralExperimentModel.fromJson(Map<String, dynamic> json) {
    return BehavioralExperimentModel(
      id: json['id']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      ladderItem: FearLadderItemModel.fromJson(
        (json['ladderItem'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      ),
      sourceType: json['sourceType']?.toString() ?? 'SYSTEM',
      status: json['status']?.toString() ?? 'PLANNED',
      prediction: json['prediction']?.toString(),
      predictionBelief: (json['predictionBelief'] as num?)?.toInt(),
      predictionBeliefBefore: (json['predictionBeliefBefore'] as num?)?.toInt(),
      predictionBeliefAfter: (json['predictionBeliefAfter'] as num?)?.toInt(),
      safetyBehaviorsJson: json['safetyBehaviorsJson']?.toString(),
      outcome: json['outcome']?.toString(),
      learning: json['learning']?.toString(),
      executionNotes: json['executionNotes']?.toString(),
      proofImageUrl: json['proofImageUrl']?.toString(),
      debrief: json['debrief']?.toString(),
      postFearScore: (json['postFearScore'] as num?)?.toInt(),
      postAvoidanceScore: (json['postAvoidanceScore'] as num?)?.toInt(),
      assignedAt: json['assignedAt']?.toString(),
      dueDate: json['dueDate']?.toString(),
      setupCompletedAt: json['setupCompletedAt']?.toString(),
      startedAt: json['startedAt']?.toString(),
      focusReminderShown: json['focusReminderShown'] == true,
      completedAt: json['completedAt']?.toString(),
    );
  }
}
