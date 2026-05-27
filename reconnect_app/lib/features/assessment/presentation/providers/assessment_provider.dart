import 'package:flutter/material.dart';
import 'package:reconnect_app/features/assessment/data/models/phq9_question_model.dart';
import 'package:reconnect_app/features/assessment/data/models/phq9_submission_model.dart';
import 'package:reconnect_app/features/assessment/data/models/user_mood_model.dart';
import 'package:reconnect_app/features/assessment/data/repositories/assessment_repository.dart';

enum AssessmentStatus { idle, loading, success, error }

class AssessmentProvider extends ChangeNotifier {
  final AssessmentRepository _repository = AssessmentRepository();

  AssessmentStatus _status = AssessmentStatus.idle;
  String _errorMessage = '';
  Phq9QuestionnaireModel? _questionnaire;
  bool _isCooldown = false;
  Phq9SubmissionModel? _lastSubmission;
  UserMoodModel? _lastMood;

  // Getters
  AssessmentStatus get status => _status;
  String get errorMessage => _errorMessage;
  Phq9QuestionnaireModel? get questionnaire => _questionnaire;
  bool get isCooldown => _isCooldown;
  Phq9SubmissionModel? get lastSubmission => _lastSubmission;
  UserMoodModel? get lastMood => _lastMood;

  // ======================================================
  // LẤY BỘ CÂU HỎI & ĐÁP ÁN PHQ-9 ĐỘNG
  // ======================================================
  Future<void> loadQuestionnaire({String? token}) async {
    _status = AssessmentStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _questionnaire = await _repository.getPhq9Questionnaire(token: token);
      _status = AssessmentStatus.success;
    } catch (e) {
      _status = AssessmentStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  // ======================================================
  // KIỂM TRA COOLDOWN 14 NGÀY CỦA BỆNH NHÂN
  // ======================================================
  Future<void> checkCooldown(String patientId, {String? token}) async {
    _status = AssessmentStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _isCooldown = await _repository.isPhq9OnCooldown(patientId, token: token);
      _status = AssessmentStatus.success;
    } catch (e) {
      _status = AssessmentStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  // ======================================================
  // NỘP KẾT QUẢ BÀI TEST PHQ-9
  // ======================================================
  Future<bool> submitPhq9(
    String patientId,
    List<int> answers, {
    String? token,
    String submissionType = 'PERIODIC',
    int? functionalDifficultyScore,
  }) async {
    _status = AssessmentStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final submission = Phq9SubmissionModel(
        patientId: patientId,
        answers: answers,
        submissionType: submissionType,
        functionalDifficultyScore: functionalDifficultyScore,
      );
      _lastSubmission = await _repository.submitPhq9(submission, token: token);
      _isCooldown = true; // Tự động khóa nút làm bài test
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

  // ======================================================
  // GHI NHẬN TÂM TRẠNG HÀNG NGÀY
  // ======================================================
  Future<bool> submitUserMood(String patientId, int moodScore, String dailyAgenda, {String? token}) async {
    _status = AssessmentStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final mood = UserMoodModel(
        patientId: patientId,
        moodScore: moodScore,
        dailyAgenda: dailyAgenda,
      );
      _lastMood = await _repository.submitUserMood(mood, token: token);
      _status = AssessmentStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('AssessmentProvider: Error submitting user mood: $e');
      _status = AssessmentStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
