import 'package:flutter/material.dart';
import 'package:reconnect_app/features/auth/data/models/email_verification_response.dart';
import 'package:reconnect_app/features/auth/data/models/guest_profile_model.dart';
import 'package:reconnect_app/features/auth/data/models/login_request.dart';
import 'package:reconnect_app/features/auth/data/models/login_response.dart';
import 'package:reconnect_app/features/auth/data/models/patient_profile_model.dart';
import 'package:reconnect_app/features/auth/data/repositories/auth_repository.dart';
import 'package:reconnect_app/features/auth/data/repositories/patient_profile_repository.dart';
import 'package:reconnect_app/features/auth/data/repositories/guest_profile_repository.dart';
import 'package:reconnect_app/features/auth/data/repositories/auth_session_storage.dart';

enum AuthStatus { idle, loading, restoring, success, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  final PatientProfileRepository _patientProfileRepository = PatientProfileRepository();
  final GuestProfileRepository _guestProfileRepository = GuestProfileRepository();
  final AuthSessionStorage _sessionStorage = AuthSessionStorage();

  AuthStatus _status = AuthStatus.idle;
  String _errorMessage = '';
  LoginResponse? _loginResponse;
  PatientProfileModel? _patientProfile;
  GuestProfileModel? _guestProfile;
  bool _pendingDailyCheckinAfterLogin = false;

  // Getters
  AuthStatus get status => _status;
  String get errorMessage => _errorMessage;
  LoginResponse? get loginResponse => _loginResponse;
  PatientProfileModel? get patientProfile => _patientProfile;
  GuestProfileModel? get guestProfile => _guestProfile;
  String? get token => _loginResponse?.token;
  bool get isLoggedIn => _loginResponse != null;
  bool get isGuest => _loginResponse?.user.role == 'GUEST';
  bool get pendingDailyCheckinAfterLogin => _pendingDailyCheckinAfterLogin;

  Future<void> restoreSession() async {
    _status = AuthStatus.restoring;
    _errorMessage = '';
    notifyListeners();

    try {
      _loginResponse = await _sessionStorage.readSession();
      if (_loginResponse != null &&
          _loginResponse!.hasRefreshToken &&
          _isTokenExpired(_loginResponse!.accessTokenExpiresAt)) {
        _loginResponse = await _repository.refreshToken(_loginResponse!.refreshToken);
        await _sessionStorage.saveSessionWithPreference(_loginResponse!, rememberMe: true);
      }
      if (_loginResponse?.user.role == 'PATIENT') {
        await loadPatientProfile();
      } else if (_loginResponse?.user.role == 'GUEST') {
        await loadGuestProfile();
      }
      _status = _loginResponse == null ? AuthStatus.idle : AuthStatus.success;
    } catch (e) {
      _loginResponse = null;
      _status = AuthStatus.idle;
      _errorMessage = '';
    }
    notifyListeners();
  }

  // ========================================
  // ĐĂNG NHẬP
  // ========================================
  Future<void> login(String email, String password, {bool rememberMe = true}) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final request = LoginRequest(email: email, password: password, rememberMe: rememberMe);
      _loginResponse = await _repository.login(request);
      await _sessionStorage.saveSessionWithPreference(_loginResponse!, rememberMe: rememberMe);
      if (_loginResponse?.user.role == 'PATIENT') {
        await loadPatientProfile();
        _pendingDailyCheckinAfterLogin = true;
      } else if (_loginResponse?.user.role == 'GUEST') {
        await loadGuestProfile();
      }
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
      {String? nickname,
      String? avatarIcon,
      bool isAnonymous = false,
      bool anonymousModeEnabled = true,
      String? realFullName,
      String? dateOfBirth,
      String? gender,
      String? phoneNumber,
      String? emergencyContactPhone,
      String? educationLevel,
      String? occupation,
      String? relationshipStatus,
      String? medicalHistory}) async {
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
        anonymousModeEnabled: anonymousModeEnabled,
        realFullName: realFullName,
        dateOfBirth: dateOfBirth,
        gender: gender,
        phoneNumber: phoneNumber,
        emergencyContactPhone: emergencyContactPhone,
        educationLevel: educationLevel,
        occupation: occupation,
        relationshipStatus: relationshipStatus,
        medicalHistory: medicalHistory,
      );
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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
      await _sessionStorage.saveSessionWithPreference(response, rememberMe: true);
      await loadGuestProfile();
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ========================================
  // ĐĂNG XUẤT
  // ========================================
  void logout() {
    _loginResponse = null;
    _patientProfile = null;
    _guestProfile = null;
    _pendingDailyCheckinAfterLogin = false;
    _sessionStorage.clearSession();
    _status = AuthStatus.idle;
    notifyListeners();
  }

  Future<void> loadPatientProfile() async {
    final patientId = _loginResponse?.user.id ?? '';
    if (patientId.isEmpty || _loginResponse?.user.role != 'PATIENT') {
      _patientProfile = null;
      return;
    }
    try {
      _patientProfile = await _patientProfileRepository.getProfile(patientId, token: token);
    } catch (_) {
      _patientProfile = null;
    }
    notifyListeners();
  }

  Future<void> loadGuestProfile() async {
    final guestId = _loginResponse?.user.id ?? '';
    if (guestId.isEmpty || _loginResponse?.user.role != 'GUEST') {
      _guestProfile = null;
      return;
    }
    try {
      _guestProfile = await _guestProfileRepository.getProfile(guestId, token: token);
    } catch (_) {
      _guestProfile = null;
    }
    notifyListeners();
  }

  Future<bool> updatePatientProfile(Map<String, dynamic> body) async {
    final patientId = _loginResponse?.user.id ?? '';
    if (patientId.isEmpty) return false;
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();
    try {
      body['patientId'] = patientId;
      _patientProfile = await _patientProfileRepository.updateProfile(body, token: token);
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateGuestProfile(Map<String, dynamic> body) async {
    final guestId = _loginResponse?.user.id ?? '';
    if (guestId.isEmpty || _loginResponse?.user.role != 'GUEST') return false;
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();
    try {
      body['guestId'] = guestId;
      _guestProfile = await _guestProfileRepository.updateProfile(body, token: token);
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> completePatientSafetyGate({
    required String realFullName,
    required String phoneNumber,
  }) async {
    final patientId = _loginResponse?.user.id ?? '';
    if (patientId.isEmpty) return false;
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();
    try {
      _patientProfile = await _patientProfileRepository.completeSafetyGate(
        patientId: patientId,
        realFullName: realFullName,
        phoneNumber: phoneNumber,
        token: token,
      );
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<EmailVerificationResponse?> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _repository.verifyEmailOtp(email: email, otp: otp);
      _status = AuthStatus.success;
      notifyListeners();
      return response;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<EmailVerificationResponse?> resendEmailOtp(String email) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _repository.resendEmailOtp(email);
      _status = AuthStatus.success;
      notifyListeners();
      return response;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<bool> linkGuestAccount({
    required String email,
    required String password,
    required String realFullName,
    required String phoneNumber,
  }) async {
    final guestId = _loginResponse?.user.id ?? '';
    if (guestId.isEmpty || _loginResponse?.user.role != 'GUEST') return false;
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();
    try {
      await _repository.linkGuestAccount(
        guestId: guestId,
        email: email,
        password: password,
        realFullName: realFullName,
        phoneNumber: phoneNumber,
        token: token,
      );
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void consumePendingDailyCheckinFlag() {
    _pendingDailyCheckinAfterLogin = false;
    notifyListeners();
  }

  Future<bool> requestPasswordReset(String email) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();
    try {
      await _repository.requestPasswordReset(email);
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    final patientId = _loginResponse?.user.id ?? '';
    final authToken = token;
    if (patientId.isEmpty || authToken == null || authToken.isEmpty) return false;

    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      await _repository.deletePatientAccount(patientId: patientId, token: authToken);
      logout();
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();
    try {
      await _repository.resetPassword(resetToken: resetToken, newPassword: newPassword);
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  bool _isTokenExpired(String? isoString) {
    if (isoString == null || isoString.isEmpty) {
      return false;
    }
    final expiresAt = DateTime.tryParse(isoString)?.toUtc();
    if (expiresAt == null) {
      return false;
    }
    return DateTime.now().toUtc().isAfter(expiresAt.subtract(const Duration(seconds: 30)));
  }
}
