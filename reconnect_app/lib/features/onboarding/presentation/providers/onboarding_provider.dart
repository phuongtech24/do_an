import 'package:flutter/material.dart';

import '../../data/repositories/onboarding_repository.dart';
import '../../data/models/onboarding_status_model.dart';

enum OnboardingStatus { idle, loading, success, error }

class OnboardingProvider extends ChangeNotifier {
  final OnboardingRepository _repository = OnboardingRepository();

  OnboardingStatus _status = OnboardingStatus.idle;
  String _errorMessage = '';
  List<String> _savedGoals = const [];
  OnboardingStatusModel? _onboardingStatus;

  OnboardingStatus get status => _status;
  String get errorMessage => _errorMessage;
  List<String> get savedGoals => _savedGoals;
  OnboardingStatusModel? get onboardingStatus => _onboardingStatus;
  bool get isOnboardingComplete => _onboardingStatus?.isComplete == true;
  String get nextOnboardingRoute => _onboardingStatus?.nextRoute ?? '/lsas';

  Future<bool> saveGoals(String patientId, List<String> goals, {String? token}) async {
    _status = OnboardingStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _savedGoals = await _repository.saveGoals(patientId, goals, token: token);
      _onboardingStatus = await _repository.getOnboardingStatus(patientId, token: token);
      _status = OnboardingStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = OnboardingStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> loadGoals(String patientId, {String? token}) async {
    _status = OnboardingStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _savedGoals = await _repository.getGoals(patientId, token: token);
      _status = OnboardingStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = OnboardingStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> loadOnboardingStatus(String patientId, {String? token}) async {
    _status = OnboardingStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _onboardingStatus = await _repository.getOnboardingStatus(patientId, token: token);
      _status = OnboardingStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = OnboardingStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> completePsychoeducation(String patientId, {String? token}) async {
    _status = OnboardingStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      await _repository.completePsychoeducation(patientId, token: token);
      _onboardingStatus = await _repository.getOnboardingStatus(patientId, token: token);
      _status = OnboardingStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = OnboardingStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
