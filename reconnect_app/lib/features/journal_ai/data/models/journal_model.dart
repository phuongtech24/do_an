class JournalModel {
  final String? id;
  final String? patientId;
  final String journalType;
  final String? createDate;
  final String? createdBy;
  final int? aiRiskScore;
  final String? severityLevel;

  final String? situation;
  final String? worstPrediction;
  final String? automaticThought;
  final String? emotion;
  final int? emotionScore;
  final List<String>? bodySymptoms;
  final String? selfFocusThought;
  final String? negativeSelfImage;
  final List<String>? safetyBehaviors;
  final List<String>? distortions;
  final String? adaptiveResponse;
  final String? safetyBehaviorCommitment;
  final int? reRatedScore;
  final int? reRatedBeliefScore;
  final String? behavioralExperimentIdea;

  final String? content;

  JournalModel({
    this.id,
    this.patientId,
    required this.journalType,
    this.createDate,
    this.createdBy,
    this.aiRiskScore,
    this.severityLevel,
    this.situation,
    this.worstPrediction,
    this.automaticThought,
    this.emotion,
    this.emotionScore,
    this.bodySymptoms,
    this.selfFocusThought,
    this.negativeSelfImage,
    this.safetyBehaviors,
    this.distortions,
    this.adaptiveResponse,
    this.safetyBehaviorCommitment,
    this.reRatedScore,
    this.reRatedBeliefScore,
    this.behavioralExperimentIdea,
    this.content,
  });

  factory JournalModel.fromJson(Map<String, dynamic> json) {
    List<String>? toStringList(dynamic value) {
      if (value is! List) return null;
      final items = value.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
      return items.isEmpty ? null : items;
    }

    return JournalModel(
      id: json['id']?.toString(),
      patientId: json['patientId']?.toString(),
      journalType: json['journalType']?.toString() ?? 'THOUGHT_RECORD',
      createDate: json['createDate']?.toString(),
      createdBy: json['createdBy']?.toString(),
      aiRiskScore: (json['aiRiskScore'] as num?)?.toInt(),
      severityLevel: json['severityLevel']?.toString(),
      situation: json['situation']?.toString(),
      worstPrediction: json['worstPrediction']?.toString(),
      automaticThought: json['automaticThought']?.toString(),
      emotion: json['emotion']?.toString(),
      emotionScore: (json['emotionScore'] as num?)?.toInt(),
      bodySymptoms: toStringList(json['bodySymptoms']),
      selfFocusThought: json['selfFocusThought']?.toString(),
      negativeSelfImage: json['negativeSelfImage']?.toString(),
      safetyBehaviors: toStringList(json['safetyBehaviors']),
      distortions: toStringList(json['distortions']),
      adaptiveResponse: json['adaptiveResponse']?.toString(),
      safetyBehaviorCommitment: json['safetyBehaviorCommitment']?.toString(),
      reRatedScore: (json['reRatedScore'] as num?)?.toInt(),
      reRatedBeliefScore: (json['reRatedBeliefScore'] as num?)?.toInt(),
      behavioralExperimentIdea: json['behavioralExperimentIdea']?.toString(),
      content: json['content']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (patientId != null) 'patientId': patientId,
      'journalType': journalType,
      if (createDate != null) 'createDate': createDate,
      if (createdBy != null) 'createdBy': createdBy,
      if (aiRiskScore != null) 'aiRiskScore': aiRiskScore,
      if (severityLevel != null) 'severityLevel': severityLevel,
      if (situation != null) 'situation': situation,
      if (worstPrediction != null) 'worstPrediction': worstPrediction,
      if (automaticThought != null) 'automaticThought': automaticThought,
      if (emotion != null) 'emotion': emotion,
      if (emotionScore != null) 'emotionScore': emotionScore,
      if (bodySymptoms != null) 'bodySymptoms': bodySymptoms,
      if (selfFocusThought != null) 'selfFocusThought': selfFocusThought,
      if (negativeSelfImage != null) 'negativeSelfImage': negativeSelfImage,
      if (safetyBehaviors != null) 'safetyBehaviors': safetyBehaviors,
      if (distortions != null) 'distortions': distortions,
      if (adaptiveResponse != null) 'adaptiveResponse': adaptiveResponse,
      if (safetyBehaviorCommitment != null) 'safetyBehaviorCommitment': safetyBehaviorCommitment,
      if (reRatedScore != null) 'reRatedScore': reRatedScore,
      if (reRatedBeliefScore != null) 'reRatedBeliefScore': reRatedBeliefScore,
      if (behavioralExperimentIdea != null) 'behavioralExperimentIdea': behavioralExperimentIdea,
      if (content != null) 'content': content,
    };
  }
}
