class LoginRequest {
  final String email;
  final String password;
  final bool rememberMe;

  LoginRequest({
    required this.email,
    required this.password,
    this.rememberMe = true,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'rememberMe': rememberMe,
      };
}
