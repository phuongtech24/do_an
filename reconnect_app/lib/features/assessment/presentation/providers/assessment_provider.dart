import 'package:flutter/material.dart';
import 'package:reconnect_app/features/assessment/data/models/lsas_situation_model.dart';
import 'package:reconnect_app/features/assessment/data/models/lsas_submission_model.dart';
import 'package:reconnect_app/features/assessment/data/models/user_mood_model.dart';
import 'package:reconnect_app/features/assessment/data/repositories/assessment_repository.dart';

enum AssessmentStatus { idle, loading, success, error }

class AssessmentProvider extends ChangeNotifier {
  final AssessmentRepository _repository = AssessmentRepository();

  AssessmentStatus _status = AssessmentStatus.idle;
  String _errorMessage = '';
  List<LsasSituationModel> _situations = [];
  bool _isCooldown = false;
  LsasSubmissionModel? _lastSubmission;
  List<LsasSubmissionModel> _lsasHistory = [];
  bool _historyLoading = false;
  UserMoodModel? _lastMood;

  AssessmentStatus get status => _status;
  String get errorMessage => _errorMessage;
  List<LsasSituationModel> get situations => _situations;
  bool get isCooldown => _isCooldown;
  LsasSubmissionModel? get lastSubmission => _lastSubmission;
  List<LsasSubmissionModel> get lsasHistory => _lsasHistory;
  bool get historyLoading => _historyLoading;
  UserMoodModel? get lastMood => _lastMood;

  Future<void> loadSituations({String? token}) async {
    _status = AssessmentStatus.loading;
    _errorMessage = '';
    notifyListeners();
    try {
      _situations = await _repository.getLsasSituations(token: token);
      _status = AssessmentStatus.success;
    } catch (e) {
      _status = AssessmentStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  Future<void> checkCooldown(String patientId, {String? token}) async {
    _status = AssessmentStatus.loading;
    _errorMessage = '';
    notifyListeners();
    try {
      _isCooldown = await _repository.isLsasOnCooldown(patientId, token: token);
      _status = AssessmentStatus.success;
    } catch (e) {
      _status = AssessmentStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  Future<bool> submitLsas(
    String patientId,
    List<LsasAnswerInput> answers, {
    String? token,
    String submissionType = 'PERIODIC',
  }) async {
    _status = AssessmentStatus.loading;
    _errorMessage = '';
    notifyListeners();
    try {
      _lastSubmission = await _repository.submitLsas(
        patientId: patientId,
        submissionType: submissionType,
        answers: answers,
        token: token,
      );
      _lsasHistory = await _repository.getLsasHistory(patientId, token: token);
      _isCooldown = true;
      _status = AssessmentStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AssessmentStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> loadLsasHistory(String patientId, {String? token}) async {
    _historyLoading = true;
    notifyListeners();
    try {
      _lsasHistory = await _repository.getLsasHistory(patientId, token: token);
    } catch (e) {
      debugPrint('AssessmentProvider: Error loading LSAS history: $e');
    } finally {
      _historyLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitUserMood(
    String patientId, {
    required int anxietyScore,
    required int avoidanceUrgeScore,
    required int anticipatoryAnxietyScore,
    required int postEventRuminationScore,
    required String dailyAgenda,
    String? token,
  }) async {
    _status = AssessmentStatus.loading;
    _errorMessage = '';
    notifyListeners();
    try {
      final mood = UserMoodModel(
        patientId: patientId,
        anxietyScore: anxietyScore,
        avoidanceUrgeScore: avoidanceUrgeScore,
        anticipatoryAnxietyScore: anticipatoryAnxietyScore,
        postEventRuminationScore: postEventRuminationScore,
        dailyAgenda: dailyAgenda,
      );
      _lastMood = await _repository.submitUserMood(mood, token: token);
      _status = AssessmentStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AssessmentStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
