class JournalModel {
  final String? id;
  final String? patientId;
  final String journalType; // 'THOUGHT_RECORD' or 'CREDIT_LIST'
  final String? createDate;
  final String? createdBy;
  final int? aiRiskScore;
  final String? severityLevel;

  // Thought Record 6 steps fields
  final String? situation;
  final String? automaticThought;
  final String? emotion;
  final int? emotionScore;
  final String? adaptiveResponse;
  final int? reRatedScore;
  final List<String>? distortions;

  // Credit List fields
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
    this.automaticThought,
    this.emotion,
    this.emotionScore,
    this.adaptiveResponse,
    this.reRatedScore,
    this.distortions,
    this.content,
  });

  factory JournalModel.fromJson(Map<String, dynamic> json) {
    return JournalModel(
      id: json['id']?.toString(),
      patientId: json['patientId']?.toString(),
      journalType: json['journalType'] ?? 'THOUGHT_RECORD',
      createDate: json['createDate']?.toString(),
      createdBy: json['createdBy']?.toString(),
      aiRiskScore: (json['aiRiskScore'] as num?)?.toInt(),
      severityLevel: json['severityLevel']?.toString(),
      situation: json['situation']?.toString(),
      automaticThought: json['automaticThought']?.toString(),
      emotion: json['emotion']?.toString(),
      emotionScore: (json['emotionScore'] as num?)?.toInt(),
      adaptiveResponse: json['adaptiveResponse']?.toString(),
      reRatedScore: (json['reRatedScore'] as num?)?.toInt(),
      distortions: (json['distortions'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      content: json['content']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'patientId': patientId,
      'journalType': journalType,
      if (createDate != null) 'createDate': createDate,
      if (createdBy != null) 'createdBy': createdBy,
      if (aiRiskScore != null) 'aiRiskScore': aiRiskScore,
      if (severityLevel != null) 'severityLevel': severityLevel,
      if (situation != null) 'situation': situation,
      if (automaticThought != null) 'automaticThought': automaticThought,
      if (emotion != null) 'emotion': emotion,
      if (emotionScore != null) 'emotionScore': emotionScore,
      if (adaptiveResponse != null) 'adaptiveResponse': adaptiveResponse,
      if (reRatedScore != null) 'reRatedScore': reRatedScore,
      if (distortions != null) 'distortions': distortions,
      if (content != null) 'content': content,
    };
  }
}
