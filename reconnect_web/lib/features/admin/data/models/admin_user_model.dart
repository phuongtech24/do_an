class AdminUserModel {
  final String id;
  final String email;
  final String? username;
  final String role; // PATIENT/THERAPIST/ADMIN
  final bool isAnonymous;
  final bool isActive;

  AdminUserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
    required this.isAnonymous,
    required this.isActive,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString(),
      role: json['role']?.toString() ?? 'PATIENT',
      isAnonymous: json['isAnonymous'] == true,
      isActive: json['isActive'] != false,
    );
  }

  AdminUserModel copyWith({String? role, bool? isActive}) {
    return AdminUserModel(
      id: id,
      email: email,
      username: username,
      role: role ?? this.role,
      isAnonymous: isAnonymous,
      isActive: isActive ?? this.isActive,
    );
  }
}

