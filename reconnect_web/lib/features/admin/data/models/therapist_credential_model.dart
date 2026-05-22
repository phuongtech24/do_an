class AdminTherapistCredentialModel {
  final String id;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
  final String uploadedAt;

  AdminTherapistCredentialModel({
    required this.id,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    required this.uploadedAt,
  });

  factory AdminTherapistCredentialModel.fromJson(Map<String, dynamic> json) {
    return AdminTherapistCredentialModel(
      id: json['id']?.toString() ?? '',
      fileName: json['fileName']?.toString() ?? '',
      mimeType: json['mimeType']?.toString() ?? 'application/octet-stream',
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
      uploadedAt: json['uploadedAt']?.toString() ?? '',
    );
  }
}

