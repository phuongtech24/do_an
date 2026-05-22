import 'package:flutter/material.dart';
import 'package:reconnect_app/features/auth/data/models/login_request.dart';
import 'package:reconnect_app/features/auth/data/models/login_response.dart';
import 'package:reconnect_app/features/auth/data/repositories/auth_repository.dart';

enum AuthStatus { idle, loading, success, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  AuthStatus _status = AuthStatus.idle;
  String _errorMessage = '';
  LoginResponse? _loginResponse;

  // Getters
  AuthStatus get status => _status;
  String get errorMessage => _errorMessage;
  LoginResponse? get loginResponse => _loginResponse;
  String? get token => _loginResponse?.token;
  bool get isLoggedIn => _loginResponse != null;

  // ========================================
  // ĐĂNG NHẬP
  // ========================================
  Future<void> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final request = LoginRequest(email: email, password: password);
      _loginResponse = await _repository.login(request);
      _status = AuthStatus.success;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  // ========================================
  // ĐĂNG KÝ
  // ========================================
  Future<bool> register(String email, String password,
      {String? nickname, String? avatarIcon, bool isAnonymous = false}) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      await _repository.register(
        email: email,
        password: password,
        nickname: nickname,
        avatarIcon: avatarIcon,
        isAnonymous: isAnonymous,
      );
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ========================================
  // ĐĂNG NHẬP ẨN DANH
  // ========================================
  Future<bool> loginAnonymous(String deviceId) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _repository.loginAnonymous(deviceId);
      _loginResponse = response; 
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ========================================
  // ĐĂNG XUẤT
  // ========================================
  void logout() {
    _loginResponse = null;
    _status = AuthStatus.idle;
    notifyListeners();
  }
}
