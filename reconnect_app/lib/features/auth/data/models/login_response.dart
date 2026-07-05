class UserDto {
  final String id;
  final String email;
  final String? username;
  final String role;
  final bool isAnonymous;

  UserDto({
    required this.id,
    required this.email,
    this.username,
    required this.role,
    required this.isAnonymous,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'],
      role: json['role'] ?? '',
      isAnonymous: json['isAnonymous'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'role': role,
      'isAnonymous': isAnonymous,
    };
  }
}

class LoginResponse {
  final UserDto user;
  final String accessToken;
  final String refreshToken;
  final String? accessTokenExpiresAt;
  final String? refreshTokenExpiresAt;
  final int? expiresIn;
  final int? refreshExpiresIn;

  LoginResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    this.accessTokenExpiresAt,
    this.refreshTokenExpiresAt,
    this.expiresIn,
    this.refreshExpiresIn,
  });

  String get token => accessToken;

  bool get hasRefreshToken => refreshToken.isNotEmpty;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      user: UserDto.fromJson(json['user']),
      accessToken: json['accessToken']?.toString() ?? json['token']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      accessTokenExpiresAt: json['accessTokenExpiresAt']?.toString(),
      refreshTokenExpiresAt: json['refreshTokenExpiresAt']?.toString(),
      expiresIn: (json['expiresIn'] as num?)?.toInt(),
      refreshExpiresIn: (json['refreshExpiresIn'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'accessTokenExpiresAt': accessTokenExpiresAt,
      'refreshTokenExpiresAt': refreshTokenExpiresAt,
      'expiresIn': expiresIn,
      'refreshExpiresIn': refreshExpiresIn,
      'token': accessToken,
    };
  }
}
