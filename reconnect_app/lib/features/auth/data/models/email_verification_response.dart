class EmailVerificationResponse {
  final String email;
  final bool verificationRequired;
  final int? expiresInSeconds;
  final String? nextStep;

  EmailVerificationResponse({
    required this.email,
    required this.verificationRequired,
    this.expiresInSeconds,
    this.nextStep,
  });

  factory EmailVerificationResponse.fromJson(Map<String, dynamic> json) {
    return EmailVerificationResponse(
      email: json['email']?.toString() ?? '',
      verificationRequired: json['verificationRequired'] ?? false,
      expiresInSeconds: (json['expiresInSeconds'] as num?)?.toInt(),
      nextStep: json['nextStep']?.toString(),
    );
  }
}

