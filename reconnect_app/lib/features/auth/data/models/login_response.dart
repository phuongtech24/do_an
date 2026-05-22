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
}

class LoginResponse {
  final UserDto user;
  final String token;

  LoginResponse({required this.user, required this.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      user: UserDto.fromJson(json['user']),
      token: json['token'] ?? '',
    );
  }
}
