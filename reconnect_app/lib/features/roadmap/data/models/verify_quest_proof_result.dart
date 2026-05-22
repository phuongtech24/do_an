class VerifyQuestProofResult {
  final bool accepted;
  final String? proofImageUrl;
  final String? reason;
  final int? score;
  final double? confidence;

  VerifyQuestProofResult({
    required this.accepted,
    this.proofImageUrl,
    this.reason,
    this.score,
    this.confidence,
  });

  factory VerifyQuestProofResult.fromJson(Map<String, dynamic> json) {
    final vision = json['vision'] as Map<String, dynamic>?;
    return VerifyQuestProofResult(
      accepted: json['accepted'] == true,
      proofImageUrl: json['proofImageUrl']?.toString(),
      reason: vision?['reason']?.toString(),
      score: (vision?['score'] as num?)?.toInt(),
      confidence: (vision?['confidence'] as num?)?.toDouble(),
    );
  }
}

