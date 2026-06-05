import 'package:flutter/material.dart';

import '../../data/models/onboarding_status_model.dart';
import '../../data/models/therapist_directory_item_model.dart';
import '../../data/repositories/onboarding_repository.dart';

enum OnboardingStatus { idle, loading, success, error }

class OnboardingProvider extends ChangeNotifier {
  final OnboardingRepository _repository = OnboardingRepository();

  OnboardingStatus _status = OnboardingStatus.idle;
  String _errorMessage = '';
  List<String> _savedGoals = const [];
  String? _savedGoalType;
  OnboardingStatusModel? _onboardingStatus;
  List<TherapistDirectoryItemModel> _therapists = const [];
  String? _selectedTherapistId;

  OnboardingStatus get status => _status;
  String get errorMessage => _errorMessage;
  List<String> get savedGoals => _savedGoals;
  String? get savedGoalType => _savedGoalType;
  OnboardingStatusModel? get onboardingStatus => _onboardingStatus;
  List<TherapistDirectoryItemModel> get therapists => _therapists;
  String? get selectedTherapistId => _selectedTherapistId;
  bool get isOnboardingComplete => _onboardingStatus?.isComplete == true;
  String get nextOnboardingRoute => _onboardingStatus?.nextRoute ?? '/lsas';

  Future<bool> saveGoal(String patientId, String goalType, String description, {String? token}) async {
    _status = OnboardingStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final goal = await _repository.saveGoal(patientId, goalType, description, token: token);
      _savedGoals = [goal.description];
      _savedGoalType = goal.goalType;
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
      final goals = await _repository.getGoals(patientId, token: token);
      _savedGoals = goals.map((goal) => goal.description).toList();
      _savedGoalType = goals.isEmpty ? null : goals.first.goalType;
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

  Future<bool> loadTherapists({String? token}) async {
    _status = OnboardingStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _therapists = await _repository.getTherapists(token: token);
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

  Future<bool> selectTherapist(String patientId, String therapistId, {String? token}) async {
    _status = OnboardingStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      await _repository.selectTherapist(patientId, therapistId, token: token);
      _selectedTherapistId = therapistId;
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
